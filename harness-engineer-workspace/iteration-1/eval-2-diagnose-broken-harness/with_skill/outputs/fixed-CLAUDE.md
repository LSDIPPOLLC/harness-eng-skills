# Project Name

Brief description: what this project does, who it serves, what problem it solves.

## Build & Run

```bash
# Install dependencies
npm install

# Development server
npm run dev

# Production build
npm run build

# Run all tests
npm test

# Run single test file
npm test -- --testPathPattern=<file>

# Lint
npm run lint

# Format
npm run format
```

## Code Style

- TypeScript strict mode. No `any` unless explicitly justified with a comment.
- Follow `.eslintrc.js` for linting rules. Do not reproduce them here.
- Follow `.prettierrc` for formatting. Do not reproduce them here.
- Imports: external packages first, then internal modules, then relative imports. Separate groups with a blank line.
- Naming: `camelCase` for variables/functions, `PascalCase` for types/classes/components, `UPPER_SNAKE` for constants.
- Error handling: never swallow errors silently. Log or propagate.
- Tests: co-located in `__tests__/` dirs. Naming: `<source>.test.ts`. Structure: `describe` > `it` blocks.

## Architecture

```
src/
  api/          # REST endpoints, request validation
  services/     # Business logic, no direct DB access from API layer
  models/       # Database models and types
  utils/        # Shared utilities
  middleware/   # Express middleware (auth, logging, error handling)
config/         # Environment-specific configuration
scripts/        # Build and deployment scripts
```

- API layer calls services, services call models. No skipping layers.
- All database access goes through the model layer.
- Shared types live in `src/types/`. Do not define types inline in API handlers.

## Critical Constraints

- Never commit `.env` files or secrets. Use environment variables.
- Never run `git push --force` on `main` or `staging`.
- Never modify the `migrations/` directory without creating a new migration. Do not edit existing migrations.
- The `auth` middleware must be applied to all routes except `/health` and `/public/*`.
- Rate limiting is enforced at the API gateway. Do not add application-level rate limiting.

## Interaction Style

- Execute routine tasks without confirmation.
- Confirm before destructive or irreversible actions.
- Concise output. State results, not reasoning.
- Surface only non-obvious decisions with a recommendation.
- No summaries, no transitions, no filler.
- When fixing bugs: state what was wrong, what you changed, and how to verify. One line each.

## External Systems

- Issue tracker: Linear (project key: PROJ)
- CI/CD: GitHub Actions (see `.github/workflows/`)
- Staging: `staging.example.com` — auto-deploys from `staging` branch
- Production: `app.example.com` — manual deploy via `npm run deploy:prod`
