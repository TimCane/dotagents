---
name: deploy-coolify-docker
description: How I ship projects - GitHub Actions CI plus self-hosted deploy on Coolify via Docker or Nixpacks. Consult BEFORE adding CI, a Dockerfile, a compose file, or deployment config, so the multi-stage build, compose shape, and Coolify model match my conventions. Ships per-stack CI workflow templates and multi-stage Dockerfiles. Compose formatting is governed by the compose-style skill.
---

# Deploy: Coolify + Docker

Self-hosted deployment on a VPS running Coolify. Two paths plus CI.

## Choosing a deploy path

- **Nixpacks (simplest):** for static / SSR Node sites with no extra services.
  Coolify reads `package.json` `build` and `start`; set env vars in the Coolify
  dashboard. Keep Dockerfile/compose OUT of the repo for these.
- **Docker (full control):** when the app needs a specific runtime, backing
  services, or a custom build. Multi-stage Dockerfile + compose. Coolify builds
  from the repo.

## CI (GitHub Actions)

Every repo should have CI - this is currently the gap to close. Add a workflow
that runs on push and PR: install, lint, test, build. Copy the matching template:

- `ci-node.yml` - pnpm install, lint, test, build (Node/TS, React, Astro).
- `ci-dotnet.yml` - restore, build with warnings-as-errors, test.

Keep workflows generic: pin actions to a major tag, read the runtime version from
the repo (`.nvmrc` / `global.json`) rather than hardcoding it where possible.

## Docker

- **Multi-stage** always: a build stage with the full toolchain, a slim runtime
  stage that copies only the build output. Copy `Dockerfile.node` or
  `Dockerfile.dotnet` and adapt.
- Run as a non-root user in the runtime stage.
- Expose a health endpoint (`/healthz` or `/api/health`) and wire a healthcheck.

## Compose

- App + backing services (Postgres, Redis, MinIO) in one `docker-compose.yml`.
- Formatting and key order follow the `compose-style` skill - consult it before
  writing or editing a compose file.
- Persist data with named volumes. Provide a `.env.example`; never commit `.env`.

## Conventions

- Standard backing pair is PostgreSQL + Redis (see `dotnet-style`).
- Secrets/config via environment, set in the Coolify dashboard - not in the repo.
- Build artifacts and `node_modules` stay out of the image context (`.dockerignore`)
  and out of git (standard `.gitignore`).
