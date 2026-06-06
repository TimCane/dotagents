---
name: astro-style
description: House conventions for my Astro content/SSR sites. Consult BEFORE scaffolding an Astro project or adding pages, layouts, content collections, or styling, so the Astro 5 + strict TS + Tailwind/SCSS setup and the Coolify deploy model stay consistent. Ships .prettierrc and a tsconfig template.
---

# Astro Style

Astro content and SSR site conventions.

These are defaults for a fresh site. A repo that is already structured
differently wins - apply these when scaffolding, do not restructure existing
code to match them.

## Stack

- **Astro 5**, static + SSR (hybrid) via `@astrojs/node` when server routes or
  middleware are needed.
- TypeScript **strict** (`astro/tsconfigs/strict`). No `any`, no `@ts-ignore`.
- Styling: Tailwind v4 (`@theme` tokens) OR SCSS with BEM - pick one per repo,
  don't mix. Self-host fonts via `@fontsource`.
- pnpm.
- Deploy on Coolify - Nixpacks auto-detect (reads `package.json` build/start) for
  simple sites, or multi-stage Docker for SSR.

## Structure

```
src/
  layouts/    # base shell + page layout
  pages/      # file-based routes
  components/
  content/    # content collections + config.ts (schemas)
  styles/
  lib/
docs/         # specs (source of truth)
```

## Conventions

- Path alias `@/*` -> `src/*`. Import via the alias except within the same folder.
- Keep client JS minimal: prefer zero-JS Astro components; add an island only
  when interactivity genuinely needs it.
- Content lives in content collections with Zod schemas in `src/content/config.ts`
  - a bad entry should fail the build.
- Read secrets from `process.env` in server-only modules, never
  `import.meta.env`.
- Health route (`/healthz` -> `{ok:true}`) for the platform health check.
- Formatting: Prettier with `prettier-plugin-astro` (copy `.prettierrc`: single
  quotes, no semicolons, 2-space). Run before committing.

## Deploy rules (Coolify + Nixpacks)

- For Nixpacks sites: no Dockerfile / compose / reverse-proxy config in the repo
  - the platform reads `package.json` scripts. Env vars are set in the Coolify
  dashboard. Add Docker only when the site needs SSR control Nixpacks can't give.

`tsconfig.json`: copy the template (extends `astro/tsconfigs/strict`, adds `@/*`).
`.gitignore`: use the default `pnpm create astro` emits - it covers `dist/`,
`.astro/`.
