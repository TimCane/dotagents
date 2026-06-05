#!/usr/bin/env bash
# Run every test in this directory. Exit non-zero if any fail.
set -u
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
rc=0
for t in "$DIR"/test_*.sh; do
  bash "$t" || rc=1
done
exit "$rc"
