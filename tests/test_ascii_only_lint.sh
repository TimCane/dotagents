#!/usr/bin/env bash
# Tests for .claude/hooks/ascii-only-lint.py
# Feeds hook-protocol JSON on stdin and asserts the exit code.
# Non-ASCII inputs are built with python chr() so this file stays ASCII.
set -u
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOOK="$DIR/../.claude/hooks/ascii-only-lint.py"
pass=0
fail=0

run() { # $1 = python dict expr -> json on stdin -> hook, prints exit code
  python3 -c "import json,sys; sys.stdout.write(json.dumps($1))" \
    | python3 "$HOOK" >/dev/null 2>&1
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

check "clean write passes" 0 \
  "$(run '{"tool_name":"Write","tool_input":{"file_path":"x","content":"hello world"}}')"
check "em-dash write blocked" 2 \
  "$(run '{"tool_name":"Write","tool_input":{"file_path":"x","content":"a " + chr(0x2014) + " b"}}')"
check "curly-quote edit blocked" 2 \
  "$(run '{"tool_name":"Edit","tool_input":{"file_path":"x","new_string":chr(0x201C) + "q" + chr(0x201D)}}')"
check "emoji write blocked" 2 \
  "$(run '{"tool_name":"Write","tool_input":{"file_path":"x","content":"hi " + chr(0x1F916)}}')"
check "non-write tool ignored" 0 \
  "$(run '{"tool_name":"Read","tool_input":{"file_path":"x"}}')"
check "empty content passes" 0 \
  "$(run '{"tool_name":"Write","tool_input":{"file_path":"x","content":""}}')"
check "multiedit with bad arrow blocked" 2 \
  "$(run '{"tool_name":"MultiEdit","tool_input":{"edits":[{"new_string":"ok"},{"new_string":"bad " + chr(0x2192)}]}}')"

echo "test_ascii_only_lint: $pass passed, $fail failed"
[ "$fail" -eq 0 ]
