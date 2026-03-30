# TeamApp Frontend

React + TypeScript SPA built with Vite, deployed to Vercel. Shared component library with feature-based organization under `src/`.

## Build & Run

```bash
# Install dependencies
npm install

# Run development server
npm run dev

# Run all tests
npm test

# Run a single test file
npx jest src/components/Button/Button.test.tsx

# Run tests in watch mode
npm run test:watch

# Lint
npm run lint

# Format
npx prettier --write .

# Type check
npx tsc --noEmit

# Build for production
npm run build

# Preview production build locally
npm run preview
```

## Code Style

- Language: TypeScript (strict mode)
- Formatting: Prettier (2-space indent, single quotes, trailing commas)
- Linting: ESLint with eslint-plugin-react-hooks, @typescript-eslint
- Naming: PascalCase for components and types, camelCase for functions/variables, UPPER_SNAKE for constants
- Imports: React/library imports first, then absolute `@/` imports, then relative. No barrel files in leaf directories.
- File naming: PascalCase for components (`UserCard.tsx`), camelCase for utilities (`formatDate.ts`)

## Architecture

```
src/
  components/       # Shared UI components (Button, Modal, Card, etc.)
  features/         # Feature modules (auth, dashboard, settings, etc.)
    auth/
      components/   # Feature-specific components
      hooks/        # Feature-specific hooks
      api.ts        # Feature API calls
      types.ts      # Feature types
  hooks/            # Shared custom hooks
  lib/              # Utilities, API client, helpers
    api/            # API client setup, interceptors, types
    utils/          # Pure utility functions
  pages/            # Route-level page components
  styles/           # Global styles, Tailwind config extensions
  types/            # Shared TypeScript types and interfaces
```

- **Components**: Shared components live in `src/components/`, feature-specific ones in `src/features/<name>/components/`.
- **Co-location**: Keep hooks, types, and tests next to the code they support. A feature's API calls, types, hooks, and components all live in that feature directory.
- **Pages are thin**: Page components wire together features and handle layout. Business logic lives in feature modules.

## Engineering Standards

### Component Patterns

Use functional components exclusively. Define a `Props` interface above the component, co-located in the same file. Export the component as a named export -- never use default exports (they make refactoring harder and imports less searchable).

Prefer composition over configuration. A component that takes 8+ props is a component that should be broken into smaller pieces. If you find yourself adding boolean props like `showHeader`, `withBorder`, `isCompact` -- stop and compose instead:

```tsx
// Do this
<Card>
  <Card.Header>...</Card.Header>
  <Card.Body>...</Card.Body>
</Card>

// Not this
<Card showHeader={true} headerTitle="..." withBorder={true} />
```

Keep components under 150 lines. If a component is growing beyond that, extract a custom hook for the logic or split it into sub-components. The render function should be readable at a glance.

Avoid `React.FC` -- just type the props directly: `function UserCard(props: UserCardProps)`. Destructure props in the function signature for simple components, in the body for complex ones.

### State Management

**Local state first.** Use `useState` and `useReducer` for component-level state. Most state is local -- resist the urge to hoist it.

**Server state is not app state.** Use React Query (TanStack Query) for all server data. It handles caching, background refetching, and stale-while-revalidate. Never store API responses in Redux or Zustand -- that's React Query's job.

**Global UI state** (theme, sidebar open/closed, current user) lives in Zustand stores. Keep these stores small and focused -- one store per concern, not one mega-store. A store with more than 10 fields is too big.

**URL is state too.** Pagination, filters, sort order, and active tabs belong in the URL via search params. This makes the state shareable and bookmarkable. Use the router's `useSearchParams` for this.

Decision tree: Can it live in the URL? Put it there. Is it server data? React Query. Is it local to one component? `useState`. Is it shared UI state across unrelated components? Zustand.

### API & Data Fetching

All HTTP calls go through the API client in `src/lib/api/client.ts`. This client wraps `fetch` with auth headers, base URL, response parsing, and error normalization. Never call `fetch` directly from components or hooks.

Structure API functions by feature in `src/features/<name>/api.ts`. Each function returns typed data:

```ts
// src/features/auth/api.ts
export async function loginUser(credentials: LoginRequest): Promise<AuthResponse> {
  return apiClient.post('/auth/login', credentials);
}
```

Use React Query hooks to connect API functions to components. Place these hooks in `src/features/<name>/hooks/`:

```ts
// src/features/auth/hooks/useLogin.ts
export function useLogin() {
  return useMutation({
    mutationFn: loginUser,
    onSuccess: (data) => { /* handle success */ },
  });
}
```

**Error handling**: The API client converts non-2xx responses into typed `ApiError` objects with `status`, `code`, and `message` fields. Components use React Query's `error` state to display errors -- never try/catch in components. For unexpected errors, the global error boundary catches and reports.

**Caching**: React Query manages all caching. Set sensible `staleTime` values per query (user profile: 5 min, dashboard data: 30 sec, static config: 1 hour). Never manually invalidate cache without reason -- prefer React Query's automatic invalidation after mutations.

### Validation

Use Zod for all runtime validation. Define schemas in the feature's `types.ts` file alongside the TypeScript types, and infer the TS types from the schemas:

```ts
export const loginSchema = z.object({
  email: z.string().email(),
  password: z.string().min(8),
});
export type LoginRequest = z.infer<typeof loginSchema>;
```

Validate at the boundary: form submissions, API responses, URL params, localStorage reads. Interior code can trust types -- validation happens at the edges.

For forms, use React Hook Form with `@hookform/resolvers/zod` to connect Zod schemas to form validation. Every form has a schema. No ad-hoc validation logic scattered through handlers.

### Error Handling

Use React Error Boundaries at three levels: root (catch-all with "something went wrong" page), feature-level (isolate feature failures from the rest of the app), and component-level for known-fragile UI (charts, third-party widgets).

Let errors propagate. Do not catch errors defensively just to swallow them. If a function can fail, let it fail -- the error boundary or React Query's error state will handle it. Catch only when you have a meaningful recovery action.

For async operations, React Query handles error states automatically. Show error UI based on the query/mutation `error` field, not with try/catch in event handlers.

Log errors to the console in development. In production, the error boundary sends errors to the monitoring service. Never `console.error` and continue as if nothing happened -- either recover meaningfully or let it bubble.

### Testing Philosophy

**Test behavior, not implementation.** A good test answers "does this feature work?" -- not "did this function get called with these args?" If you refactor the internals and the tests break but the feature still works, the tests were wrong.

**Do not mock what you do not own.** Mock the API layer (MSW for network-level mocking), but do not mock React Query, the router, Zustand stores, or DOM APIs. If a test needs React Query, wrap it in a `QueryClientProvider` with a test client. If it needs routing, wrap it in `MemoryRouter`. Testing with real infrastructure gives real confidence.

**Prefer integration-style component tests.** Render the component with its hooks and context, interact with it as a user would (click, type, wait), and assert on what the user sees. Use `@testing-library/react` and follow its guiding principle: test the way your software is used.

**What to test:**
- User-facing behavior (form submit, button click, navigation)
- Conditional rendering (error states, loading states, empty states)
- Edge cases that have caused bugs before
- Shared utility functions with tricky logic

**What not to test:**
- Implementation details (internal state shape, method calls, render counts)
- Third-party library behavior (trust that React Query caches, trust that Zod validates)
- Styles or CSS classes (they change constantly, tests add no value)
- Simple pass-through components with no logic

**Test data**: Build test data inline in each test for clarity. For repeated patterns, use factory functions in `src/test-utils/factories.ts` -- never use shared fixture files that create implicit dependencies between tests.

A well-tested component has 3-8 tests. If you need 20+ tests for one component, the component is doing too much.

## Testing

- Framework: Jest with React Testing Library
- Location: Tests co-located with source files (`Button.test.tsx` next to `Button.tsx`)
- Naming: `<ComponentName>.test.tsx` for components, `<utilName>.test.ts` for utilities
- Run specific: `npx jest src/path/to/File.test.tsx`
- Coverage: `npm run test:coverage` (enforced in CI, not locally)

## Commit Conventions

Conventional commits: `feat:`, `fix:`, `refactor:`, `test:`, `docs:`, `chore:`

Examples:
- `feat: add user avatar upload to profile settings`
- `fix: prevent duplicate form submission on slow networks`
- `refactor: extract shared pagination hook from feature modules`

## Dependencies & External Services

- **React 18** with concurrent features enabled
- **Vite** for build tooling and dev server
- **TanStack Query (React Query v5)** for server state management
- **Zustand** for global UI state
- **React Router v6** for routing
- **Zod** for runtime validation
- **React Hook Form** for form state
- **Tailwind CSS** for styling
- **MSW (Mock Service Worker)** for API mocking in tests
- **Vercel** for deployment (preview deploys on PRs, production on `main`)

Environment variables (set in `.env.local`, never commit):
- `VITE_API_BASE_URL` -- Backend API base URL
- `VITE_SENTRY_DSN` -- Error monitoring
- `VITE_POSTHOG_KEY` -- Analytics
