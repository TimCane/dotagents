---
name: pr-style
description: House style for GitHub pull request titles and descriptions. Consult BEFORE running `gh pr create`/`gh pr edit` so the PR has a Conventional-Commits title and a small body of two terse sections - a bulleted Summary and a short Test plan - with no prose paragraphs and no AI attribution footer. The git-message-lint hook enforces this.
---

# PR Style

A PR description is a skim, not an essay. Reviewer reads it in ten seconds and knows
what changed and how it was checked. Two sections, bullets only.

## The rules

1. **Title = Conventional Commits**, same as a commit subject.
   - `type(scope): summary`, imperative, lowercase, no period, **<= 72 chars**.
   - For a single-commit PR, reuse the commit subject verbatim.

2. **Body has at most two sections, both bulleted:**

   ```markdown
   ## Summary
   - what changed, one bullet per logical change
   - the why, if not obvious

   ## Test plan
   - how you verified it (commands run, what you observed)
   - [ ] checkbox items for anything still to verify
   ```

   - **No prose paragraphs.** Every line is a bullet or a heading.
   - Drop `## Test plan` only if truly nothing to test (rare).
   - Keep it tight - if Summary has more than ~6 bullets, the PR is probably too big.

3. **No AI attribution footer.** Do **not** add a `Generated with Claude Code`
   line (with or without the robot emoji), `Co-Authored-By: Claude`, or similar.

4. **Link issues** with a closing keyword as a bullet when relevant
   (`- closes #3`), not as a paragraph.

5. **ASCII only.** Titles and bodies are printable ASCII - no em-dashes, curly
   quotes or emoji. See the `ascii-only` skill.

## Good

```markdown
## Summary
- add password reset flow with single-use email tokens
- closes #3

## Test plan
- `npm test` covers token issue, expiry, and reuse
- reset a test account end to end locally
```

## Bad

```markdown
This PR adds a password reset feature that emails a single-use token and
expires it after 15 minutes. I tested it by resetting a test account and it
worked fine. Let me know if anything needs changing.

[robot-emoji] Generated with Claude Code
```

Why it's bad: prose paragraphs instead of bullets, no clear Summary/Test plan split,
carries the AI footer, and the original used a non-ASCII emoji.

## Workflow

- Build the body as bullets from the commits on the branch.
- Pass it with `gh pr create --title "..." --body "..."` (or `--body-file`).
- The `git-message-lint` hook will block and explain if the title or body drifts.
