#!/usr/bin/env python3
"""PreToolUse hook: block file writes that contain non-ASCII characters.

Fires on Write / Edit / MultiEdit. Inspects only the text being written (the
new content, not the old), and exits 2 on any byte outside printable ASCII so
Claude Code feeds the reason back to the model and it rewrites the content.

Allowed: printable ASCII 0x20-0x7E plus tab (0x09), newline (0x0A) and carriage
return (0x0D). Everything else is rejected, including em-dash, curly quotes,
arrows, box-drawing characters and emoji.

House rule lives in the `ascii-only` skill; this is the teeth.
"""
import json
import sys
import unicodedata

ALLOWED_CONTROL = {0x09, 0x0A, 0x0D}  # tab, newline, carriage return


def new_text(tool_name, tool_input):
    """Return the text this call would write, or None if nothing to check."""
    if tool_name == "Write":
        return tool_input.get("content", "")
    if tool_name == "Edit":
        return tool_input.get("new_string", "")
    if tool_name == "MultiEdit":
        edits = tool_input.get("edits", []) or []
        return "\n".join(e.get("new_string", "") for e in edits)
    return None


def offenders(text):
    """Return [(line, col, char)] for each disallowed character, deduped order."""
    out, line, col = [], 1, 0
    for ch in text:
        col += 1
        o = ord(ch)
        if o == 0x0A:
            line, col = line + 1, 0
            continue
        if o < 0x20 or o > 0x7E:
            if o not in ALLOWED_CONTROL:
                out.append((line, col, ch))
    return out


def describe(ch):
    try:
        name = unicodedata.name(ch)
    except ValueError:
        name = "control character"
    return f"U+{ord(ch):04X} {name}"


def main():
    try:
        data = json.load(sys.stdin)
    except Exception:
        sys.exit(0)

    tool_name = data.get("tool_name", "")
    tool_input = data.get("tool_input", {})
    if not isinstance(tool_input, dict):
        sys.exit(0)

    text = new_text(tool_name, tool_input)
    if not text:
        sys.exit(0)

    bad = offenders(text)
    if not bad:
        sys.exit(0)

    path = tool_input.get("file_path", "the file")
    # One line per distinct codepoint, with the first location it appears at.
    seen, lines = {}, []
    for ln, col, ch in bad:
        if ch not in seen:
            seen[ch] = (ln, col)
            lines.append(f"  x {describe(ch)}  first at line {ln}, col {col}")

    msg = [
        f"NON-ASCII CONTENT blocked in {path} - rewrite before retrying "
        "(see the `ascii-only` skill):",
        *lines,
        "Only printable ASCII (0x20-0x7E) plus tab/newline is allowed. Common "
        "fixes: em-dash -> ' - ', curly quotes -> straight quotes, arrows -> "
        "'->', drop emoji and box-drawing characters.",
    ]
    print("\n".join(msg), file=sys.stderr)
    sys.exit(2)


if __name__ == "__main__":
    main()
