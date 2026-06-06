# dotagents

My shared Claude Code configuration: skills, slash commands, subagents, and
hooks I reuse across projects, plus a small house style. One repo, copied
into the global `~/.claude` so it applies everywhere.

## What is in here

```
.claude/
  CLAUDE.md      global house style (short, universal rules)
  skills/        on-demand capabilities and house-style specs
  commands/      custom slash commands (/<name>)
  agents/        custom subagents
  hooks/         PreToolUse lint scripts (python3)
settings.global.json   house preferences merged into ~/.claude/settings.json
install.sh             copy components + merge settings; also `enable-hooks`
tests/                 bash tests for the hooks + a repo-wide ASCII self-lint
```

## Global vs opt-in

- **Global (always available):** `skills/`, `commands/`, `agents/`, and the house
  `CLAUDE.md`. These are advisory or on-demand, so applying them everywhere is
  harmless.
- **Opt-in per project:** the lint **hooks**. Their scripts are copied globally so
  they have a stable path (`$HOME/.claude/hooks/...`), but they only *fire* in a
  project whose `.claude/settings.json` activates them. This keeps other people's
  repos (and ones that legitimately need unicode or different commit styles) free
  of the enforcement.

## Install

```sh
git clone https://github.com/timcane/dotagents
cd dotagents
./install.sh
```

`install.sh` is idempotent. It:

- copies `skills/`, `commands/`, `agents/`, `hooks/`, and `CLAUDE.md` into
  `~/.claude` (override the location with `CLAUDE_CONFIG_DIR`);
- drops any legacy symlink from an older install, and backs up real content
  already at those paths to `~/.claude/backups/dotagents-<ts>/` before replacing
  it;
- merges `settings.global.json` into `~/.claude/settings.json` (preserving your
  existing keys such as `theme` and `enabledPlugins`).

## Enable the lint hooks in a project

From inside the project you want to lint:

```sh
~/path/to/dotagents/install.sh enable-hooks
```

This merges the opt-in hook block into that project's `.claude/settings.json`,
pointing at the globally copied scripts. Re-running is safe (it will not add
duplicates).

## Hooks

- `ascii-only-lint.py` - blocks Write/Edit/MultiEdit content containing non-ASCII
  bytes. Pairs with the `ascii-only` skill.
- `git-message-lint.py` - blocks `git commit` / `gh pr create|edit` messages that
  break the house style (non-Conventional subject, over 72 chars, prose-paragraph
  bodies, AI attribution footer). Pairs with the `commit-style` and `pr-style`
  skills.

## House style

The global `CLAUDE.md` carries the short, universal defaults (Conventional
Commits, terse PR descriptions, no AI attribution footer). The detailed specs and
examples live in the `commit-style`, `pr-style`, `compose-style`, and `ascii-only`
skills. A repo's own conventions override these where they conflict; ASCII-only is
opt-in, never forced globally.

## Tests

```sh
bash tests/run.sh
```

Runs the hook tests and the repo-wide ASCII self-lint. CI (GitHub Actions) runs
the same on every push and pull request.

## Credits

The `grill-me` skill is adapted from Matt Pocock's version; see
`.claude/skills/grill-me/CREDITS.md`.

## License

MIT - see `LICENSE`.
