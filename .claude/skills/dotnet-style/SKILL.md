---
name: dotnet-style
description: House conventions for my ASP.NET Core / C# backends. Consult BEFORE creating a new .NET solution or adding projects, controllers, EF Core entities, services, or tests, so layering, the Options pattern, EF/Npgsql usage, and the xUnit+Moq / Testcontainers split match my other repos (bot-game, dwello, household-manager). Ships Directory.Build.props and .editorconfig templates and documents central package management.
---

# .NET Style

ASP.NET Core backend conventions. The canonical shape across my repos: clean
layering, Controllers, EF Core + Postgres + Redis, no hardcoded config, and a
unit/integration test split.

## Solution layout

Clean / onion layering. Dependencies flow inward only.

```
src/
  <App>.Domain/          # entities, enums, interfaces. ZERO dependencies.
  <App>.Infrastructure/  # EF Core DbContext, migrations, services, jobs
  <App>.Api/             # controllers, DTOs, middleware, Program.cs
tests/
  <App>.Tests/           # xUnit unit tests
  <App>.IntegrationTests/ # Testcontainers + WebApplicationFactory
```

`Domain` references nothing. `Infrastructure` and `Api` reference inward. Domain
never references EF Core or ASP.NET types.

## API surface

- **Controllers**, attribute-routed, under `/api/`. Not Minimal APIs (the
  default; bbrts is the deliberate exception).
- DTOs for every request/response - never expose entities directly.
- RESTful, kebab-case routes. Version under `/api/v1/` when the surface is public.
- Return typed results; validate input and fail with the right status
  (400/401/404/409/429).
- Swagger/OpenAPI in dev; generate the frontend client with NSwag.

## Configuration

- **No hardcoded values.** Everything via the Options pattern (`IOptions<T>` /
  `IOptionsSnapshot<T>`) bound from `appsettings.json`.
- Secrets come from environment / user-secrets, never committed.
- Fail loud at startup if a required setting is missing.

## Data

- **EF Core + Npgsql + PostgreSQL.** Redis for cache / pub-sub / leaderboards.
- One `IEntityTypeConfiguration<T>` file per entity - no fluent config dumped in
  `OnModelCreating`.
- Enums over magic strings for domain concepts.
- Migrations live in `Infrastructure`. Generate with the startup project set:

  ```bash
  dotnet ef migrations add <Name> \
    --project src/<App>.Infrastructure --startup-project src/<App>.Api
  dotnet ef database update \
    --project src/<App>.Infrastructure --startup-project src/<App>.Api
  ```

- No in-memory mutable state; all state in Postgres / Redis.
- Multi-tenant apps: scope every query with an EF Core global query filter, and
  give every tenant-scoped entity the tenant FK.

## Testing

Two tiers:

- **Unit:** xUnit + Moq + FluentAssertions. Pure logic, mocked dependencies.
- **Integration:** Testcontainers (real Postgres/Redis) + `WebApplicationFactory`
  for end-to-end API tests. No in-memory provider standing in for Postgres.

## Project defaults

Copy the templates into the solution root:

- `Directory.Build.props` - `Nullable` + `ImplicitUsings` + `TreatWarningsAsErrors`
  + analyzers, applied to every project.
- `.editorconfig` (copy `editorconfig`) - C# formatting and analyzer severities.

Use Central Package Management: add a `Directory.Packages.props` with
`ManagePackageVersionsCentrally` (and transitive pinning) enabled, then declare
each package version there once so `.csproj` files reference IDs only. Add the
actual `PackageVersion` entries per solution - do not start from a curated list.

`.gitignore`: copy `../../templates/gitignore` (or `~/.claude/templates/gitignore`
once installed) - it already covers `bin/`, `obj/`, `*.dll`, `*.pdb`.

## Naming

- PascalCase types/methods/properties; camelCase locals and parameters.
- Services implement an interface declared in `Domain`.
- One class per file; small, focused files; no god services.
