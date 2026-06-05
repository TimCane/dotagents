#!/usr/bin/env python3
"""PreToolUse hook: lint git commit and gh pr messages against house style.

Stays silent (exit 0) when the message conforms or when no message is present
(e.g. `git commit` with an editor). On a clear violation it exits 2 - Claude
Code feeds stderr back to the model so it rewrites the message.

House style lives in the `commit-style` and `pr-style` skills; this only checks
the objective rules so it never blocks on taste.
"""
import json
import re
import shlex
import sys

CONVENTIONAL = re.compile(
    r"^(feat|fix|docs|style|refactor|perf|test|build|ci|chore|revert)"
    r"(\([^)]+\))?!?: .+"
)
# Robot emoji injected via escape so this file stays ASCII (see ascii-only skill).
ROBOT = "\U0001F916"
AI_FOOTER = re.compile(
    r"(Generated with Claude Code|Co-Authored-By:\s*Claude|" + ROBOT + ")",
    re.IGNORECASE,
)
SUBJECT_MAX = 72
# A body/description line longer than this that is NOT a bullet/heading/checkbox
# reads as a prose paragraph.
PROSE_MAX = 100
OPERATORS = {"&&", "||", ";", "|", "&", "\n"}


def read_command():
    try:
        data = json.load(sys.stdin)
    except Exception:
        sys.exit(0)
    if data.get("tool_name") != "Bash":
        sys.exit(0)
    return data.get("tool_input", {}).get("command", "") or ""


def tokenize(command):
    try:
        return shlex.split(command, comments=False, posix=True)
    except ValueError:
        # Unbalanced quotes etc. - can't reliably parse, don't block.
        sys.exit(0)


def segments(tokens):
    """Split a token stream into command segments on shell operators."""
    seg, out = [], []
    for t in tokens:
        if t in OPERATORS:
            if seg:
                out.append(seg)
            seg = []
        else:
            seg.append(t)
    if seg:
        out.append(seg)
    return out


def collect_opt_values(tokens, names):
    """Return all values passed to the given option names (-m, --body, ...)."""
    values, i = [], 0
    while i < len(tokens):
        t = tokens[i]
        matched = False
        for name in names:
            if t == name and i + 1 < len(tokens):
                values.append(tokens[i + 1])
                i += 2
                matched = True
                break
            if t.startswith(name + "="):
                values.append(t[len(name) + 1:])
                i += 1
                matched = True
                break
        if not matched:
            i += 1
    return values


def is_bulletish(line):
    s = line.strip()
    return (
        not s
        or s.startswith(("-", "*", "#", ">"))
        or s.startswith(("- [", "* ["))
        or re.match(r"^\d+[.)]\s", s)
        or re.match(r"^\[[ xX]\]", s)
    )


def lint_commit(seg):
    # Skip editor / file-based commits - no message to inspect.
    if any(o in seg for o in ("-F", "--file", "-C", "--reuse-message")):
        return []
    msgs = collect_opt_values(seg, ["-m", "--message"])
    if not msgs:
        return []  # editor commit
    full = "\n".join(msgs)
    subject = full.splitlines()[0] if full.splitlines() else ""
    body_lines = full.splitlines()[1:]

    errs = []
    if not CONVENTIONAL.match(subject):
        errs.append(
            'subject must be Conventional Commits "type(scope): summary" '
            f'(got: "{subject}")'
        )
    if len(subject) > SUBJECT_MAX:
        errs.append(f"subject is {len(subject)} chars; keep <= {SUBJECT_MAX}")
    if subject.endswith("."):
        errs.append("drop the trailing period on the subject")
    for ln in body_lines:
        if not is_bulletish(ln) and len(ln.strip()) > PROSE_MAX:
            errs.append(
                "body looks like a prose paragraph; use terse `- ` bullets instead"
            )
            break
    if AI_FOOTER.search(full):
        errs.append("remove the AI attribution footer (no 'Generated with'/Co-Authored-By Claude)")
    return errs


def lint_pr(seg):
    errs = []
    titles = collect_opt_values(seg, ["-t", "--title"])
    if titles:
        title = titles[0]
        if not CONVENTIONAL.match(title):
            errs.append(
                'PR title must be Conventional Commits "type(scope): summary" '
                f'(got: "{title}")'
            )
        if len(title) > SUBJECT_MAX:
            errs.append(f"PR title is {len(title)} chars; keep <= {SUBJECT_MAX}")
    bodies = collect_opt_values(seg, ["-b", "--body"])
    for body in bodies:
        for ln in body.splitlines():
            if not is_bulletish(ln) and len(ln.strip()) > PROSE_MAX:
                errs.append(
                    "PR body has a prose paragraph; use bulleted ## Summary and ## Test plan"
                )
                break
        if AI_FOOTER.search(body):
            errs.append("remove the AI attribution footer from the PR body")
    return errs


def main():
    command = read_command()
    if not command:
        sys.exit(0)
    tokens = tokenize(command)

    errs, kind, skill = [], None, None
    for seg in segments(tokens):
        if len(seg) >= 2 and seg[0] == "git" and "commit" in seg[1:]:
            # ensure 'commit' is the subcommand, not a value
            if seg[1] == "commit" or (seg[1].startswith("-") and "commit" in seg):
                e = lint_commit(seg)
                if e:
                    errs, kind, skill = e, "COMMIT", "commit-style"
                    break
        if len(seg) >= 3 and seg[0] == "gh" and seg[1] == "pr" and seg[2] in ("create", "edit"):
            e = lint_pr(seg)
            if e:
                errs, kind, skill = e, "PULL REQUEST", "pr-style"
                break

    if not errs:
        sys.exit(0)

    lines = [f"{kind} MESSAGE STYLE - rewrite before retrying (see the `{skill}` skill):"]
    lines += [f"  x {e}" for e in errs]
    lines.append(
        "House rules: small/logical commits, Conventional subject <= 72 chars, "
        "terse bullet body (no prose paragraphs), no AI footer."
    )
    print("\n".join(lines), file=sys.stderr)
    sys.exit(2)


if __name__ == "__main__":
    main()
