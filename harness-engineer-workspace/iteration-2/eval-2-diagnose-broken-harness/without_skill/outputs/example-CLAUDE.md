# Project Instructions

## Overview

- This is a [TypeScript/Python/Go/etc.] project using [framework].
- Monorepo managed with [pnpm/npm/yarn].

## Build and Test

- Install: `pnpm install`
- Dev server: `pnpm dev`
- Build: `pnpm build`
- Test all: `pnpm test`
- Test single file: `pnpm test -- path/to/file.test.ts`
- Lint: `pnpm lint`
- Type check: `pnpm typecheck`

## Code Style

- Use TypeScript strict mode. No `any` types without a comment explaining why.
- Prefer named exports over default exports.
- Use functional components with hooks, not class components.
- File naming: kebab-case for files, PascalCase for components.
- Imports: group by (1) external packages, (2) internal modules, (3) relative imports. Blank line between groups.

## Architecture

- `src/api/` -- API route handlers
- `src/components/` -- Shared UI components
- `src/lib/` -- Utility functions and shared logic
- `src/types/` -- TypeScript type definitions
- `tests/` -- Test files, mirroring src/ structure

## Conventions

- All new code must have tests.
- Prefer composition over inheritance.
- Error messages should be user-friendly, log technical details separately.
- Database queries go through the repository pattern in `src/lib/db/`.

## My Preferences

- Be concise in explanations. Skip obvious details.
- When fixing a bug, explain the root cause before showing the fix.
- Always run tests after making changes.
- Prefer small, focused commits over large ones.
