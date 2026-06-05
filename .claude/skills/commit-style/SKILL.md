---
name: commit-style
description: House style for git commit messages. Consult BEFORE running `git commit` so the message is small, Conventional-Commits formatted, split into logical commits, with a terse bullet body (never prose paragraphs) and no AI attribution footer. The git-message-lint hook enforces this and will block non-conforming commits.
---

# Commit Style

Small, sharp commits. The reader skims `git log --oneline` and instantly knows what
each commit did. No walls of text, no AI footer.

## The rules

1. **Conventional Commits subject.** `type(scope): summary`
   - Types: `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `build`,
     `ci`, `chore`, `revert`. Breaking change: add `!` -> `feat!: ...`.
   - `scope` is optional but encouraged (the stack/service/dir touched).
   - Summary is imperative mood, lowercase start, no trailing period.
   - **<= 72 characters.** If you can't say it in 72 chars, the commit is doing too much - split it.

2. **Prefer many small commits over one big one.** Each commit is one logical change.
   - Refactor, then feature, then docs = three commits, not one.
   - `git add -p` to stage logical hunks separately when needed.
   - A commit should be revertable on its own without dragging unrelated work with it.

3. **Body is optional and terse - bullets, never paragraphs.**
   - Only add a body when the *why* isn't obvious from the subject.
   - Each line a `- ` bullet, one idea per bullet, wrapped ~72 chars.
   - No prose paragraphs. If you're writing sentences that flow, stop and bullet them.
   - Blank line between subject and body.

4. **No AI attribution footer.** Do **not** add a `Generated with Claude Code`
   line (with or without the robot emoji), `Co-Authored-By: Claude`, or similar.
   Keep the message clean.

5. **ASCII only.** Messages are printable ASCII - no em-dashes, curly quotes or
   emoji. See the `ascii-only` skill.

## Good

```
feat(auth): add password reset flow

- email a single-use token, valid for 15 minutes
- rate-limit reset requests per account
```

```
fix(api): return 404 instead of 500 for unknown user
```

```
refactor(db): extract query builder into its own module
```

## Bad

```
Added a password reset feature that emails a single-use token and expires
it after 15 minutes, also fixed a 500 error in the user API while I was in
here and updated the readme too.

[robot-emoji] Generated with Claude Code
Co-Authored-By: Claude <noreply@anthropic.com>
```

Why it's bad: not Conventional, one giant prose paragraph, bundles three unrelated
changes (should be 3 commits), carries the AI footer, and the original used a
non-ASCII emoji.

## Workflow

- Before committing, ask: *is this one logical change?* If no, split it.
- Write the subject first. If it needs `and`, it's two commits.
- Add a bullet body only if the reason isn't self-evident.
- The `git-message-lint` hook will block and explain if the message drifts from this style.
