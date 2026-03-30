# Project: [Your Project Name]

## Build & Run

- Install: `pnpm install`
- Dev server: `pnpm dev` (runs on port 3000)
- Build: `pnpm build`
- Test all: `pnpm test`
- Test single file: `pnpm test -- path/to/file.test.ts`
- Lint: `pnpm lint`
- Lint fix: `pnpm lint --fix`
- Type check: `npx tsc --noEmit`

## Project Structure

- `src/` -- application source code
  - `src/api/` -- API route handlers
  - `src/components/` -- React components
  - `src/lib/` -- shared utilities and helpers
  - `src/db/` -- database models and migrations
- `tests/` -- test files (mirror src/ structure)
- `scripts/` -- build and deployment scripts

## Code Style

- TypeScript strict mode is enabled. Do not use `any` unless absolutely necessary.
- Use named exports, not default exports.
- Prefer `interface` over `type` for object shapes.
- Error handling: use `Result<T, E>` pattern from `src/lib/result.ts`, not try/catch for business logic.
- Imports: use `@/` path alias for src-relative imports.

## Database

- ORM: Drizzle. Schema lives in `src/db/schema/`.
- Never modify migration files after they have been committed.
- Generate migrations: `pnpm db:generate`
- Run migrations: `pnpm db:migrate`

## Testing

- Framework: Vitest.
- Tests must pass before committing. Run `pnpm test` to verify.
- Use `describe`/`it` blocks. Name tests as sentences: `it("returns 404 when user not found")`.
- Mock external services, never call real APIs in tests.

## Git Conventions

- Branch naming: `feat/short-description`, `fix/short-description`, `chore/short-description`.
- Commit messages: imperative mood, max 72 chars first line. Example: "Add user authentication endpoint".
- Always run tests before committing.

## Common Pitfalls

- The `AUTH_SECRET` env var must be set even in dev, or auth middleware will throw.
- Hot reload does not pick up changes to `src/db/schema/` -- restart the dev server.
- The CI uses Node 20. Do not use Node 22 features.
