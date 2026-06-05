---
name: compose-style
description: House style for docker-compose.yaml and .env.example files when this house style is in effect. Consult BEFORE writing or editing a compose or env-example file so service key order, comment placement, quoting and section layout stay consistent. Also defines the standardise procedure for reformatting an existing file (layout/comments only, never behaviour).
---

# Compose Style

Every `docker-compose.yaml` and `.env.example` follows one layout, so any compose
file reads like every other. This skill is the canonical spec plus a safe reformat
procedure. It is advisory (no enforcing hook yet).

Hard rule for reformatting: change ONLY layout, ordering, quoting, whitespace and
comments. Never change an image, tag, port, path, value, network name, or any
other semantic. Prove it with the equivalence check below.

Files are ASCII only - see the `ascii-only` skill.

## docker-compose.yaml

### File skeleton

```yaml
name: <project>

# Optional project header: role and any deploy caveats. Include ONLY when the
# project is not self-evident; do not just restate the name.
services:
  # Service description comment - what it is / why it exists. ABOVE the key.
  <service>:
    image: ...
    ...

networks:
  ...
volumes:
  ...
```

- `name: <project>` is line 1, matching the directory.
- One blank line between the header/`name:` and `services:`, and one blank line
  between each service.
- Top-level `networks:` / `volumes:` blocks go last. Never rename a network or
  volume during a reformat - only move the block.

### Service key order

Emit keys a service uses in exactly this order (omit any it does not use):

1. `build`
2. `image`
3. `container_name`
4. `hostname`
5. `user`
6. `restart`
7. `labels`        (see below)
8. `entrypoint`
9. `command`
10. `extends`
11. `network_mode`
12. `privileged`
13. `cap_add`
14. `devices`
15. `stdin_open`
16. `tty`
17. `shm_size`
18. `ports`
19. `environment`
20. `volumes`
21. `networks`
22. `extra_hosts`
23. `depends_on`
24. `healthcheck`  (or the `# Health:` marker, see below)

Identity keys (`build` through `user`) cluster at the top; `entrypoint` precedes
`command`; sidecars defined by a `command` still keep it here, not lower down.

### labels

Place `labels` right after `restart`, as an inline map. Do NOT use a YAML anchor,
even when several services share the same label - repeat the literal map per
service, and keep a why-comment when the label is not self-evident. For example,
opting a stateful service out of an auto-updater:

```yaml
    restart: unless-stopped
    labels:
      # Stateful - update manually, not via the auto-updater.
      com.centurylinklabs.watchtower.enable: "false"
```

### environment

- `TZ` first, always, when the image honours it (e.g. `TZ: Etc/UTC`).
- `PUID` / `PGID` next, if present (quoted: `"1000"`).
- Then app vars grouped by concern (keep `DB_*` together, etc.). No
  alphabetising - logical grouping wins.
- Secrets come in as `${VAR:?required}`.
- Quote every scalar that is a number or boolean as a string: `"5432"`, `"true"`,
  `"3306"`. This is purely cosmetic - it does not change `docker compose config`.

### healthcheck

- Key order: `test`, `interval`, `timeout`, `retries`, `start_period`.
- Add a comment above `test` ONLY when the probe is non-obvious (a bare
  `pg_isready` or `curl .../ping` needs none; a `/dev/tcp` probe or a port-dodge
  does).
- When relying on the image's built-in healthcheck, omit the block and leave a
  marker where it would go:
  `# Health: image ships a built-in HEALTHCHECK (<what it checks>).`

### Comments

- Spaced-hyphen asides: ` - ` (never an em-dash; see `ascii-only`).
- Service description: a `#` block ABOVE the service key, reading like a heading.
- Key rationale: a `#` line directly above the key it explains.
- `$$` in a `command`/`test` escapes compose interpolation so the container shell
  expands the var; keep the one-line note explaining it.

## .env.example

```
# 1-3 line header: what this project's env holds, and that static config
# (versions, ports, paths, schedules) lives in docker-compose.yaml.

# Section name (optional explanation of the group)
SECRET_VAR=
INSTANCE_VAR=example-value   # show a realistic value for non-secret instance vars

# Another section
# Generation hint inline, e.g. Generate: pwgen -s 40 1
SOME_KEY=

# --- One-time / server-side setup (not docker-compose) -----------------------
# Optional runbook footer: numbered manual steps that compose does not do.
```

- Always a header. Group vars into `# Section`s mirroring how they appear in the
  compose file.
- Secrets: empty (`VAR=`). Instance/example values: show the value.
- Put generation/derivation hints inline as comments.
- Every var here must be referenced by the compose file (and vice versa, every
  `${VAR:?...}` must appear here).

## Standardise procedure (reformatting an existing file)

Do this per compose file, one commit each (`style(<project>): standardise compose + env layout`).

1. Build a throwaway env that satisfies every `${VAR:?...}` in the compose file,
   e.g. extract the names and assign each a dummy value:
   ```sh
   cd <project-dir>
   grep -oE '\$\{[A-Z0-9_]+' docker-compose.yaml | tr -d '${' | sort -u \
     | sed 's/$/=x/' > /tmp/dummy.env
   ```
2. Capture the normalised config BEFORE editing:
   ```sh
   docker compose --env-file /tmp/dummy.env config > /tmp/before.yml
   ```
3. Reformat `docker-compose.yaml` and `.env.example` to the spec above
   (Read + Edit; layout/comments/quoting/order only).
4. Capture AFTER and diff - it MUST be empty:
   ```sh
   docker compose --env-file /tmp/dummy.env config > /tmp/after.yml
   diff /tmp/before.yml /tmp/after.yml
   ```
   `docker compose config` strips comments, resolves anchors, and renders env
   values as strings, so an empty diff proves only layout/comments changed. A
   non-empty diff means a real change slipped in - revert it.
5. Sanity-check the `.env.example` against the compose file: every `${VAR}` is
   present in env and every env var is referenced.
6. Commit the change.

Clean up `/tmp/dummy.env`, `/tmp/before.yml`, `/tmp/after.yml` when done.
