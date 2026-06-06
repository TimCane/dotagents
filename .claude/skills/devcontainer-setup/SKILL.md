---
name: devcontainer-setup
description: How I set up devcontainers for new projects. Consult BEFORE adding or editing a .devcontainer so it matches my two archetypes (Node/TS image, or .NET via docker-compose) and includes my claude-code-passthrough feature and the .claude mount. Ships both devcontainer.json templates and a post-create script.
---

# Devcontainer Setup

Every project runs in a devcontainer. Pick the archetype that fits the stack.

## Archetype A: Node / TypeScript (default for JS/TS sites and SPAs)

Single image, no compose. Copy `node-ts/devcontainer.json`.

Key pieces:
- Image `mcr.microsoft.com/devcontainers/typescript-node`.
- `"runArgs": ["--net=host"]` so dev servers and tools reach the host network.
- My feature `ghcr.io/timcane/devcontainer-features/claude-code-passthrough`,
  which brings Claude Code into the container.
- `postCreateCommand` installs deps (and Playwright browsers when the repo has
  e2e tests).
- Add `forwardPorts` for the app port; add stack VS Code extensions
  (Astro/Tailwind/Prisma) per repo.

## Archetype B: .NET + backing services (compose-based)

Use when the project needs Postgres / Redis / MinIO alongside the app. Copy
`dotnet/devcontainer.json` plus `dotnet/post-create.sh`. The compose file is the
project's own `docker-compose.yml` with an `app` service.

Key pieces:
- `dockerComposeFile` + `service: app` + `shutdownAction: stopCompose`.
- `forwardPorts` for app + db + redis (e.g. 5000, 5432, 6379).
- Features: my `claude-code-passthrough` (same as archetype A) plus
  `ghcr.io/42atomys/devcontainers-features/redis-cli` for the redis CLI.
- C# VS Code extensions (`ms-dotnettools.csharp`, `csdevkit`).
- `postCreateCommand: bash .devcontainer/post-create.sh`.

## Notes

- Claude Code gets in via my `claude-code-passthrough` feature (from the
  `devcontainer-features` repo) in BOTH archetypes. Do not use a `.claude` bind
  mount - that is the deprecated method.
- Image and feature version tags in the templates are placeholders - bump them to
  current when scaffolding.
