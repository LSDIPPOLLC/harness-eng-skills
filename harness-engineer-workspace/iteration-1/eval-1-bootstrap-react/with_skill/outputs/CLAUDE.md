# React TypeScript Application

Single-page React application built with TypeScript and Vite. Deployed to Vercel.

## Build & Run

```bash
# Install dependencies
npm install

# Run development server
npm run dev

# Build for production
npm run build

# Preview production build
npm run preview

# Run tests
npm test

# Run single test file
npm test -- --testPathPattern=<file>

# Run tests in watch mode
npm test -- --watch

# Lint
npm run lint

# Format
npm run format

# Type check
npx tsc --noEmit
```

## Code Style

- Language: TypeScript (strict mode)
- Formatting: Prettier (follow `.prettierrc`)
- Linting: ESLint (follow `eslint.config.*`)
- Naming: PascalCase for components and types, camelCase for functions/variables, UPPER_SNAKE_CASE for constants
- Imports: React/library imports first, then absolute project imports, then relative imports. One blank line between groups.
- Components: Functional components with arrow functions. Use named exports, not default exports.
- Hooks: Custom hooks in `src/hooks/`, prefixed with `use`
- Types: Co-locate component prop types in the component file. Shared types in `src/types/`

## Architecture

```
src/
  components/     # React components organized by feature
    common/       # Shared/reusable components (Button, Modal, etc.)
    layout/       # Layout components (Header, Footer, Sidebar)
    features/     # Feature-specific component groups
  hooks/          # Custom React hooks
  types/          # Shared TypeScript types and interfaces
  utils/          # Utility functions
  services/       # API client and service layer
  assets/         # Static assets (images, fonts)
  styles/         # Global styles and theme
  App.tsx         # Root component
  main.tsx        # Entry point (Vite)
```

- State management: React Context + hooks (no Redux)
- Routing: React Router
- API calls: Centralized in `src/services/`, return typed responses
- Styling: CSS Modules or styled-components (check project convention)

## Testing

- Framework: Jest with React Testing Library
- Location: Co-located `__tests__/` directories or `*.test.tsx` files alongside source
- Naming: `<ComponentName>.test.tsx` or `<util>.test.ts`
- Run specific: `npm test -- --testPathPattern=ComponentName`
- Patterns: Prefer `screen.getByRole` over `getByTestId`. Test behavior, not implementation.
- Mocking: Use `jest.mock()` for services. Never mock React hooks directly.

## Deployment

- Platform: Vercel
- Config: `vercel.json` in project root
- Preview deployments: Automatic on PR branches
- Production: Deploys from `main` branch
- Environment variables: Managed in Vercel dashboard, prefixed with `VITE_` for client-side access

## Commit Conventions

Use conventional commits:
```
feat: add user profile page
fix: resolve routing issue on refresh
refactor: extract form validation logic
test: add coverage for auth service
chore: update dependencies
```
