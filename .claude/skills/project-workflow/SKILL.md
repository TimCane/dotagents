---
name: project-workflow
description: How I structure non-trivial projects - docs/ as source of truth, a standard CLAUDE.md skeleton, phased builds (one PR per phase), and review as the final step. Consult BEFORE starting a new project, writing a project CLAUDE.md, or planning a multi-step build, so the structure matches my other repos. Ships a CLAUDE.md skeleton template.
---

# Project Workflow

How I run any non-trivial project. The defining habit: specs live in `docs/` and
the build follows them in phases.

## docs/ is the source of truth

- Every non-trivial project has a `docs/` tree holding the real specs
  (architecture, domain model, API surface, data model, conventions). The repo
  CLAUDE.md is a thin pointer into it, not a duplicate.
- Read the relevant doc before implementing a feature.
- Code and docs must not drift: if an edit contradicts a doc, update the doc
  first, then write the code.
- Start a docs tree with a `docs/README.md` index when it grows past a few files.

## CLAUDE.md skeleton

Every repo's CLAUDE.md follows the same shape so any project is legible at a
glance. Scaffold from `~/.claude/templates/CLAUDE.md`:

Overview -> Tech Stack (table) -> Project Structure -> Commands -> Code
Conventions -> Documentation -> Workflow.

Keep stack rules in the matching house skill (`dotnet-style`, `react-style`,
`astro-style`); the repo CLAUDE.md restates only what is project-specific.

## Phased builds

- Break the build into numbered phases with a dependency order; capture them in
  `docs/` (e.g. `milestones.md` / `implementation-order.md`).
- **One PR per phase.** Phase boundaries are firm: if work belongs to a later
  phase, note it and defer.
- Don't skip CI, don't `--no-verify`, don't force-push main. Fix root causes.

## Review as the final step

After completing a task, run a read-only review pass over the changed files for
duplication, simplification, and convention drift before considering it done.
Use the `code-review` skill / review agent. Review never uses worktree isolation
(it makes no edits).

## Parallelism (optional)

For independent work across areas (e.g. backend + frontend, or several unrelated
fixes), run worktree-isolated agents in parallel, then merge each branch back.
Skip isolation for single-agent tasks and for the read-only review.

## Agent teams (optional, for larger repos)

My biggest repos use per-domain agent teams: one agent owns each package/layer,
the main session is team lead and delegates, and agents coordinate as peers.
Agent definitions live in `.claude/agents/`. This depends on experimental
features - treat it as an add-on, not the baseline.
