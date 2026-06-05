#!/usr/bin/env bash
# Repo-wide ASCII self-lint: fail if any tracked file has a non-ASCII byte.
# The PreToolUse hook checks one write at a time; this checks the whole tree.
set -u
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DIR/.."

bad="$(git ls-files | while IFS= read -r f; do
  [ -f "$f" ] || continue
  if LC_ALL=C grep -qP '[^\x09\x0A\x0D\x20-\x7E]' -- "$f" 2>/dev/null; then
    printf '%s\n' "$f"
  fi
done)"

if [ -n "$bad" ]; then
  echo "test_repo_ascii: non-ASCII bytes found in:"
  printf '%s\n' "$bad" | sed 's/^/  /'
  exit 1
fi

echo "test_repo_ascii: all tracked files are ASCII-clean"
