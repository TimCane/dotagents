#!/usr/bin/env bash
# Devcontainer post-create for the .NET archetype. Restore packages and tools so
# the container is ready to build and run on first attach.
set -euo pipefail

dotnet restore
dotnet tool restore 2>/dev/null || true

# Frontend, when the repo has one alongside the API.
if [ -f frontend/package.json ]; then
  (cd frontend && pnpm install)
fi
