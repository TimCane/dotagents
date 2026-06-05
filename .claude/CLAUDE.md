# House style

Defaults I want in every project. A repo's own conventions (its CONTRIBUTING
file, existing git history, .editorconfig) override these wherever they conflict.

## Git

- Default branch is `main`.
- Never commit directly to `main` - work on a feature branch and open a PR.
- PRs are squash-merged into `main`, so the PR title is the single commit that
  lands there: keep it a clean Conventional Commits subject. The per-branch
  commits are for review and do not survive the squash.
- Commits follow Conventional Commits: `type(scope): summary`, imperative mood,
  lowercase start, no trailing period, subject <= 72 chars. Split unrelated work
  into separate commits.
- Commit bodies are optional and terse: `- ` bullets, one idea each, never prose
  paragraphs. Add a body only when the why is not obvious from the subject.
- PR descriptions are two bulleted sections, `## Summary` and `## Test plan`. No
  prose paragraphs.
- Never add an AI attribution footer (no "Generated with Claude Code", no
  "Co-Authored-By: Claude").

See the `commit-style` and `pr-style` skills for the full spec and examples.

## Writing

- Terse and direct. Prefer bullets over paragraphs. Cut filler.

## ASCII

- ASCII-only files are a per-repo opt-in, NOT a global default - forcing ASCII
  breaks repos that legitimately need unicode (i18n, fixtures, docs). A repo that
  wants it enables the `ascii-only` skill and hook; do not strip unicode in repos
  that have not opted in.
