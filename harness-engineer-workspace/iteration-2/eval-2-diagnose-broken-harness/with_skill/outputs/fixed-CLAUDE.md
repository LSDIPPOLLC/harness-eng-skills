# TaskFlow

A task management API built with Node.js, TypeScript, Express, and PostgreSQL. Provides REST endpoints for creating, assigning, and tracking tasks across teams.

## Build & Run

```bash
# Install dependencies
npm install

# Start dev server (hot reload on port 3000)
npm run dev

# Run full test suite
npm test

# Run single test file
npx vitest run src/services/__tests__/task.test.ts

# Run tests in watch mode
npx vitest --watch

# Lint
npm run lint

# Format
npm run format

# Type check
npx tsc --noEmit

# Database migrations
npm run db:migrate

# Seed dev database
npm run db:seed
```

## Code Style

- TypeScript strict mode -- no `any` unless unavoidable (comment why)
- Follow `.eslintrc.json` and `.prettierrc` (do not duplicate their rules here)
- Naming: `camelCase` for variables/functions, `PascalCase` for types/classes, `UPPER_SNAKE` for constants
- Imports: Node built-ins first, then external packages, then internal modules (separated by blank line)
- Prefer `interface` over `type` for object shapes
- Use `readonly` on properties that should not be reassigned
- No default exports except for Express router files

## Architecture

```
src/
  index.ts              -- Entry point, server bootstrap
  routes/               -- Express route definitions (one file per resource)
  controllers/          -- Request handlers, input validation, response shaping
  services/             -- Business logic (no HTTP concepts here)
  repositories/         -- Database access layer (Knex queries)
  middleware/           -- Auth, error handling, request logging
  types/                -- Shared TypeScript interfaces and enums
  utils/                -- Pure utility functions
  __tests__/            -- Co-located test files mirror src/ structure

migrations/             -- Knex migration files (timestamped)
seeds/                  -- Dev seed data
```

Key boundaries:
- Routes call controllers. Controllers call services. Services call repositories.
- Never skip a layer (no route calling a repository directly).
- Services do not import from `express` -- they take typed inputs and return typed outputs.
- Repositories return domain objects, not raw SQL rows.

## Engineering Standards

### API Design

- RESTful resource naming: plural nouns (`/tasks`, `/users`), never verbs in URLs
- Use HTTP status codes correctly: 201 for creation, 204 for deletion, 422 for validation errors
- All endpoints return consistent envelope: `{ data, meta, errors }`
- Pagination via `?page=1&limit=20`, always include `meta.total` and `meta.pageCount`
- Filter and sort via query params: `?status=active&sort=-createdAt`
- Version API via URL prefix (`/v1/tasks`) not headers

### Validation

- Validate all inputs at the controller layer using Zod schemas
- Schemas live in `src/types/schemas/` alongside their corresponding interfaces
- Never trust client input past the controller -- services receive validated, typed data
- Return 422 with field-level error details: `{ errors: [{ field, message, code }] }`
- Reuse base schemas via `.extend()` and `.pick()` rather than duplicating fields

### Error Handling

- Custom error classes extend `AppError` (in `src/utils/errors.ts`)
- Each error has a `statusCode`, `code` (machine-readable), and `message` (human-readable)
- Services throw domain errors (`TaskNotFoundError`, `AssignmentConflictError`)
- The global error middleware in `src/middleware/errorHandler.ts` catches and formats all errors
- Never catch errors just to re-throw them. Only catch when you add context or handle recovery.
- Log errors with structured JSON (winston). Include `requestId`, `userId`, `errorCode`.

### Database & Repository Patterns

- Use Knex query builder, not raw SQL (except for performance-critical queries, commented why)
- Repositories expose domain methods (`findByAssignee`, `createTask`), not generic CRUD
- All writes use transactions when touching multiple tables
- Soft-delete by default (`deleted_at` timestamp). Hard-delete only for GDPR/compliance.
- Migrations are forward-only in production. To fix a bad migration, write a new one.

### Authentication & Authorization

- JWT-based auth. Tokens issued by the `/v1/auth/login` endpoint.
- Auth middleware in `src/middleware/auth.ts` validates token and attaches `req.user`
- Authorization checks happen in services, not middleware (business logic, not transport logic)
- Role-based: `admin`, `manager`, `member`. Check via `assertRole(user, 'manager')`

### Testing Philosophy

- **Integration tests over unit tests**. Most value comes from testing service + repository together against a real test database.
- **Do not mock the database**. Tests run against a dedicated test PostgreSQL instance (`npm run db:test:setup`). Each test file gets a transaction that rolls back after the suite.
- Mock only external HTTP services (use `msw` for API mocking).
- Test file naming: `<module>.test.ts`, co-located in `__tests__/` directories.
- Each test should be independent -- no shared mutable state between tests.
- Assertion style: test behavior ("creating a task with a past due date returns a 422"), not implementation ("the validate function was called").
- Aim for: 80%+ coverage on services, 60%+ on controllers, skip coverage on routes/middleware (tested via integration).

## Commit Conventions

Conventional commits: `type(scope): description`

Types: `feat`, `fix`, `refactor`, `test`, `docs`, `chore`
Scopes: `tasks`, `users`, `auth`, `db`, `api`, `ci`

Example: `feat(tasks): add bulk assignment endpoint`

## Environment Variables

Required (see `.env.example`):
- `DATABASE_URL` -- PostgreSQL connection string
- `JWT_SECRET` -- signing key for auth tokens
- `PORT` -- server port (default 3000)
- `NODE_ENV` -- `development`, `test`, or `production`
- `LOG_LEVEL` -- winston log level (default `info`)
