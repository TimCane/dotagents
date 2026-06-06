#!/usr/bin/env bash
# Install dotagents into the global Claude config.
#
# Usage:
#   ./install.sh                copy components + merge global settings
#   ./install.sh enable-hooks   turn on the opt-in lint hooks in the CURRENT project
#
# Idempotent: re-running re-copies and re-merges without duplicating anything.
# A legacy symlink from an older install is dropped; an existing real file/dir
# with different content is moved to a timestamped backup under
# <claude-dir>/backups/ before being replaced with a fresh copy.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC="$REPO_DIR/.claude"
CLAUDE_DIR="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"

# Components copied into the global config: the content dirs plus the global
# house-style CLAUDE.md. Hook SCRIPTS are copied so they have a stable path, but
# they are NOT activated globally - activate them per project via `enable-hooks`.
COMPONENTS="skills commands agents hooks templates CLAUDE.md"

log() { printf '%s\n' "$*"; }

copy_components() {
  mkdir -p "$CLAUDE_DIR"
  local backup_dir="" ts src dst name
  for name in $COMPONENTS; do
    src="$SRC/$name"
    dst="$CLAUDE_DIR/$name"
    if [ ! -e "$src" ]; then
      log "skip $name (not in repo)"
      continue
    fi
    if [ -e "$dst" ] && [ ! -L "$dst" ] && diff -rq "$src" "$dst" >/dev/null 2>&1; then
      log "ok   $name (already current)"
      continue
    fi
    if [ -L "$dst" ]; then
      rm -f "$dst"  # legacy symlink from an older install - just drop it
      log "drop legacy symlink $name"
    elif [ -e "$dst" ]; then
      if [ -z "$backup_dir" ]; then
        ts="$(date +%Y%m%d-%H%M%S)"
        backup_dir="$CLAUDE_DIR/backups/dotagents-$ts"
        mkdir -p "$backup_dir"
      fi
      mv "$dst" "$backup_dir/"
      log "move existing $name -> $backup_dir/"
    fi
    cp -R "$src" "$dst"
    log "copy $name -> $dst"
  done
  if [ -n "$backup_dir" ]; then
    log "backed up replaced entries to $backup_dir"
  fi
}

merge_global_settings() {
  local fragment="$REPO_DIR/settings.global.json"
  local target="$CLAUDE_DIR/settings.json"
  if [ ! -f "$fragment" ]; then
    log "no settings.global.json - skipping settings merge"
    return 0
  fi
  python3 - "$fragment" "$target" <<'PY'
import json, os, sys
fragment_path, target_path = sys.argv[1], sys.argv[2]
with open(fragment_path) as f:
    fragment = json.load(f)
target = {}
if os.path.exists(target_path):
    with open(target_path) as f:
        try:
            target = json.load(f)
        except ValueError:
            target = {}
target.update(fragment)  # house keys win; existing keys (theme, plugins) kept
with open(target_path, "w") as f:
    json.dump(target, f, indent=2)
    f.write("\n")
print("merged settings.global.json -> " + target_path)
PY
}

enable_hooks() {
  local target="$PWD/.claude/settings.json"
  mkdir -p "$PWD/.claude"
  python3 - "$target" <<'PY'
import json, os, sys
target_path = sys.argv[1]
settings = {}
if os.path.exists(target_path):
    with open(target_path) as f:
        try:
            settings = json.load(f)
        except ValueError:
            settings = {}

wanted = [
    ("Bash", 'python3 "$HOME/.claude/hooks/git-message-lint.py"'),
    ("Write|Edit|MultiEdit", 'python3 "$HOME/.claude/hooks/ascii-only-lint.py"'),
    ("Write|Edit|MultiEdit", 'python3 "$HOME/.claude/hooks/build-artifact-guard.py"'),
]

pre = settings.setdefault("hooks", {}).setdefault("PreToolUse", [])

def present(matcher, command):
    for entry in pre:
        if entry.get("matcher") != matcher:
            continue
        for h in entry.get("hooks", []):
            if h.get("command") == command:
                return True
    return False

added = 0
for matcher, command in wanted:
    if present(matcher, command):
        continue
    pre.append({"matcher": matcher,
                "hooks": [{"type": "command", "command": command}]})
    added += 1

with open(target_path, "w") as f:
    json.dump(settings, f, indent=2)
    f.write("\n")
print("enabled %d hook(s) in %s" % (added, target_path))
PY
}

case "${1:-install}" in
  install)
    copy_components
    merge_global_settings
    log "done"
    ;;
  enable-hooks)
    enable_hooks
    ;;
  -h|--help|help)
    log "usage: $0 [install|enable-hooks]"
    ;;
  *)
    log "unknown command: $1"
    log "usage: $0 [install|enable-hooks]"
    exit 2
    ;;
esac
