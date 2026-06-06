#!/usr/bin/env bash
# Tests for .claude/hooks/build-artifact-guard.py
# Feeds hook-protocol JSON on stdin and asserts the exit code.
set -u
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOOK="$DIR/../.claude/hooks/build-artifact-guard.py"
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

check "normal source passes" 0 \
  "$(run '{"tool_name":"Write","tool_input":{"file_path":"src/index.ts","content":"x"}}')"
check "node_modules blocked" 2 \
  "$(run '{"tool_name":"Write","tool_input":{"file_path":"node_modules/foo/index.js","content":"x"}}')"
check "dist dir blocked" 2 \
  "$(run '{"tool_name":"Edit","tool_input":{"file_path":"app/dist/bundle.js","new_string":"x"}}')"
check "bin dir blocked" 2 \
  "$(run '{"tool_name":"Write","tool_input":{"file_path":"src/App.Api/bin/Debug/App.dll","content":"x"}}')"
check "obj dir blocked" 2 \
  "$(run '{"tool_name":"Write","tool_input":{"file_path":"obj/project.assets.json","content":"x"}}')"
check "dll extension blocked" 2 \
  "$(run '{"tool_name":"Write","tool_input":{"file_path":"libs/Foo.dll","content":"x"}}')"
check "next dir blocked" 2 \
  "$(run '{"tool_name":"Write","tool_input":{"file_path":".next/static/x.js","content":"x"}}')"
check "substring dir not over-matched" 0 \
  "$(run '{"tool_name":"Write","tool_input":{"file_path":"src/distance/calc.ts","content":"x"}}')"
check "non-write tool ignored" 0 \
  "$(run '{"tool_name":"Read","tool_input":{"file_path":"node_modules/foo.js"}}')"

echo "test_build_artifact_guard: $pass passed, $fail failed"
[ "$fail" -eq 0 ]
