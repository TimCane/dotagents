---
name: ascii-only
description: House rule that every file must contain only printable ASCII when this house style is in effect. Consult BEFORE writing or editing any file so no em-dashes, curly quotes, arrows, box-drawing characters or emoji slip in. The ascii-only-lint hook enforces this on Write/Edit/MultiEdit and will block non-conforming content.
---

# ASCII Only

Under this house style, every file is plain printable ASCII. No em-dashes, no curly quotes, no
arrows, no box-drawing characters, no emoji. This keeps diffs clean, greppable,
and free of the usual AI tells.

(This doc names the banned characters instead of pasting them, because the hook
below would block the file otherwise.)

## The rule

Allowed bytes only:

- printable ASCII `0x20`-`0x7E` (space through `~`)
- tab `0x09`, newline `0x0A`, carriage return `0x0D`

Everything else is banned, including in code, comments, strings, README prose,
and commit/PR messages.

## Common offenders and fixes

| Don't use | Use instead |
|-----------|-------------|
| em-dash (U+2014) | ` - ` (spaced hyphen), or split into two sentences |
| en-dash (U+2013) | `-` |
| curly quotes (U+201C/201D/2018/2019) | straight `"` and `'` |
| arrows (U+2192, U+21D2) | `->` |
| ellipsis (U+2026) | `...` |
| box-drawing banners (U+2500, U+2502, U+251C) | a plain `# comment` |
| emoji (check mark, warning sign, robot face) | a plain word (`OK:`, `WARNING:`) or nothing |
| math symbols (U+2264, U+2265, U+00D7) | `<=`, `>=`, `x` |
| non-breaking space (U+00A0) | a normal space |

## Enforcement

`.claude/hooks/ascii-only-lint.py` runs as a PreToolUse hook on Write, Edit and
MultiEdit. It scans the content being written and exits non-zero on any
disallowed character, naming the codepoint and location so it can be fixed
before the write lands. If you genuinely need a non-ASCII byte in source (rare),
inject it via an escape (e.g. `"\U0001F916"` in Python) so the file text stays
ASCII.
