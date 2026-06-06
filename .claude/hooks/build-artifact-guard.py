#!/usr/bin/env python3
"""PreToolUse hook: block writes to build artifacts and dependency dirs.

Fires on Write / Edit / MultiEdit. Exits 2 when the target path is something
that should never be committed (build output, compiled binaries, vendored
dependencies), so Claude Code feeds the reason back to the model.

House rule lives in the global CLAUDE.md `Stack` section and the standard
.gitignore template; this is the teeth. Only fires in projects that opt in via
`install.sh enable-hooks`.
"""
import json
import re
import sys

# Path segments that mark a build-output or dependency directory. Matched as a
# full path component so `src/distance/` (a real source dir) is not caught.
BLOCKED_DIRS = {
    "node_modules",
    "dist",
    "build",
    "bin",
    "obj",
    ".next",
    ".astro",
    "coverage",
    ".venv",
    "__pycache__",
}

# File extensions that are compiled output, never hand-edited.
BLOCKED_EXTS = (".dll", ".pdb", ".pyc", ".tsbuildinfo")


def reason(path):
    """Return why this path is blocked, or None if it is allowed."""
    norm = path.replace("\\", "/")
    parts = [p for p in norm.split("/") if p]
    for part in parts:
        if part in BLOCKED_DIRS:
            return "lives in a build/dependency dir (%s/)" % part
    if norm.lower().endswith(BLOCKED_EXTS):
        return "is compiled output (%s)" % norm.rsplit(".", 1)[-1]
    return None


def target_path(tool_name, tool_input):
    if tool_name in ("Write", "Edit", "MultiEdit"):
        return tool_input.get("file_path", "")
    return ""


def main():
    try:
        data = json.load(sys.stdin)
    except Exception:
        sys.exit(0)

    tool_name = data.get("tool_name", "")
    tool_input = data.get("tool_input", {})
    if not isinstance(tool_input, dict):
        sys.exit(0)

    path = target_path(tool_name, tool_input)
    if not path:
        sys.exit(0)

    why = reason(path)
    if not why:
        sys.exit(0)

    msg = [
        "BUILD ARTIFACT blocked: %s %s." % (path, why),
        "These are generated, not authored - do not write or commit them.",
        "Edit the source that produces this output, or add the path to "
        ".gitignore (see the standard template).",
    ]
    print("\n".join(msg), file=sys.stderr)
    sys.exit(2)


if __name__ == "__main__":
    main()
