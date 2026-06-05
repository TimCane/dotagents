#!/usr/bin/env bash
# Tests for .claude/hooks/git-message-lint.py
# Feeds a Bash tool-call (the git/gh command) on stdin and asserts the exit code.
set -u
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOOK="$DIR/../.claude/hooks/git-message-lint.py"
pass=0
fail=0

run() { # $1 = shell command string -> hook, prints exit code
  python3 - "$1" <<'PY' | python3 "$HOOK" >/dev/null 2>&1
import json, sys
print(json.dumps({"tool_name": "Bash", "tool_input": {"command": sys.argv[1]}}))
PY
  echo $?
}

check() { # desc expected actual
  if [ "$2" = "$3" ]; then
    pass=$((pass + 1))
  else
    fail=$((fail + 1))
    echo "FAIL: $1 (expected exit $2, got $3)"
  fi
}

longsub="feat: $(yes a | head -70 | tr -d '\n')"

check "conventional commit passes" 0 \
  "$(run 'git commit -m "feat: add thing"')"
check "scoped conventional passes" 0 \
  "$(run 'git commit -m "fix(api): handle nil"')"
check "non-conventional blocked" 2 \
  "$(run 'git commit -m "added a thing"')"
check "trailing period blocked" 2 \
  "$(run 'git commit -m "feat: add thing."')"
check "over-72-char subject blocked" 2 \
  "$(run "git commit -m '$longsub'")"
check "AI footer blocked" 2 \
  "$(run 'git commit -m "feat: x" -m "Co-Authored-By: Claude <noreply@anthropic.com>"')"
check "editor commit ignored" 0 \
  "$(run 'git commit')"
check "non-git command ignored" 0 \
  "$(run 'ls -la')"
check "good pr title passes" 0 \
  "$(run 'gh pr create --title "feat: add thing" --body "## Summary"')"
check "bad pr title blocked" 2 \
  "$(run 'gh pr create --title "stuff" --body "## Summary"')"

echo "test_git_message_lint: $pass passed, $fail failed"
[ "$fail" -eq 0 ]
