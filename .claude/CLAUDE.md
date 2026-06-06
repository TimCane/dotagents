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

## Authoring

Comments and generated prose are written by ME, to another developer reading the
code later - not by an assistant narrating to me.

- Write in my voice, about the code: what it does and why. Do not narrate your
  own work ("I've added", "now we wire up"), address me as an assistant would
  ("you can drop more agents here"), or describe the edit ("no longer symlinks",
  "changed to copy"). The diff carries the change story; the comment states the
  current state.
- User-facing instructions in docs are fine - a README saying "Run ./install.sh"
  is the author addressing a user, not the AI addressing me.
- Do not manufacture artifacts. No files, dirs, doc sections, or comments whose
  only job is to explain, pad, or scaffold for hypothetical future use
  (placeholder READMEs, "how to add more X" guides, speculative empty dirs -
  .gitkeep included). If I would not add it unprompted, do not add it.

Example:

    # bad  - AI narrating the edit, addressed to me
    # We no longer symlink; now we copy so your other tools don't break.

    # good - my voice, current state, to a peer
    # Copy rather than symlink: some tooling follows the link and breaks.

## ASCII

- ASCII-only files are a per-repo opt-in, NOT a global default - forcing ASCII
  breaks repos that legitimately need unicode (i18n, fixtures, docs). A repo that
  wants it enables the `ascii-only` skill and hook; do not strip unicode in repos
  that have not opted in.
