---
name: react-style
description: House conventions for my React + TypeScript frontends. Consult BEFORE scaffolding a React app or adding components, hooks, routes, data fetching, or tests, so the Vite-SPA default, strict TS, Tailwind, TanStack Query, and naming/import rules match my other repos (flag-quiz, dwello frontend, dashboards). Ships .prettierrc and a strict tsconfig template.
---

# React Style

TypeScript React frontend conventions.

## Stack

Default to a **Vite SPA**. Reach for **Next.js (App Router)** only when you
actually need SSR / RSC / server routes (scout-bingo is the one Next repo).

- React + TypeScript **strict mode** + Vite
- Tailwind CSS, with shadcn/ui for primitives and Lucide for icons
- **TanStack Query** for server state; React Router 7 for routing
- **Zod** for runtime validation (share schemas with the backend where possible)
- **Vitest** + React Testing Library for tests
- pnpm

## TypeScript

- `strict: true`, no `any`, no non-null assertions. Copy the `tsconfig.json`
  template (strict, bundler resolution, `@/*` -> `src/*`).
- Prefer `type` over `interface`.
- Booleans read as predicates (`isOpen`, `hasError`, `shouldRetry`).

## Components

- PascalCase filenames. Named exports only - no default exports for components.
- Props destructured in the function signature.
- Extract a `useX` hook only when a component has real complexity (3+ pieces of
  interactive state, multiple interacting effects, heavy derived state, or reused
  logic). Otherwise keep state and handlers inline. Do not tunnel a single
  context lookup through a custom hook for the sake of consistency.
- Server/RSC components stay thin (validate, render a client component); client
  components own interactivity and state.

## Imports

- `@/` alias for `src/`. Import via the alias except within the same folder.
- Order: external packages first, then internal `@/` imports.

## State and data

- Server state lives in TanStack Query hooks, grouped by domain under
  `src/hooks/`.
- Local UI state with `useState` / `useReducer`. Reach for `useReducer` +
  Context when state has many interacting transitions.

## Styling

- Tailwind utility classes; design tokens in the Tailwind config. Avoid CSS
  modules unless a repo already uses them.

## Formatting

- Prettier only (copy `.prettierrc`: single quotes, no semicolons, 2-space).
  Add ESLint per repo if wanted; Prettier is the baseline.

`.gitignore`: copy `~/.claude/templates/gitignore` - it covers `dist/`,
`node_modules/`, `.next/`.
