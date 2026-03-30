# CLAUDE.md

## Project Overview

React/TypeScript single-page application built with Vite. Deployed to Vercel.

## Tech Stack

- **Framework:** React 18+ with TypeScript
- **Bundler:** Vite
- **Testing:** Jest with React Testing Library
- **Linting:** ESLint
- **Formatting:** Prettier
- **Deployment:** Vercel

## Project Structure

```
src/
  components/       # React components (PascalCase filenames)
  hooks/            # Custom React hooks (useXxx naming)
  utils/            # Utility/helper functions
  types/            # Shared TypeScript type definitions
  assets/           # Static assets (images, fonts, etc.)
  styles/           # Global styles and theme
  App.tsx           # Root application component
  main.tsx          # Application entry point
public/             # Static public assets
```

## Common Commands

```bash
# Install dependencies
npm install

# Start dev server
npm run dev

# Run tests
npm test

# Run tests in watch mode
npm run test:watch

# Run a single test file
npx jest path/to/file.test.tsx

# Lint
npm run lint

# Fix lint issues
npm run lint:fix

# Format code
npm run format

# Type check (no emit)
npx tsc --noEmit

# Build for production
npm run build

# Preview production build locally
npm run preview
```

## Code Conventions

- Components use PascalCase filenames: `MyComponent.tsx`
- Component tests live alongside components: `MyComponent.test.tsx`
- Hooks use camelCase with `use` prefix: `useAuth.ts`
- Utility files use camelCase: `formatDate.ts`
- Types/interfaces use PascalCase and are defined in `.ts` files (not `.tsx`)
- Prefer named exports over default exports
- Use functional components with hooks (no class components)
- Props interfaces are named `{ComponentName}Props`

## TypeScript Guidelines

- Strict mode is enabled -- do not use `any` unless absolutely necessary
- Prefer `interface` for object shapes, `type` for unions/intersections
- Use `React.FC` sparingly; prefer explicit return types or props destructuring
- All new files must be `.ts` or `.tsx` (no `.js`/`.jsx`)

## Testing Guidelines

- Test files use the `.test.tsx` or `.test.ts` extension
- Tests are co-located with source files
- Use React Testing Library -- test behavior, not implementation
- Prefer `screen.getByRole` and accessible queries over `getByTestId`
- Run `npm test` before committing to verify nothing is broken

## Styling

- CSS Modules or styled-components (check existing patterns in `src/components/`)
- Follow existing naming conventions in stylesheets

## Important Notes

- Do NOT modify `vite.config.ts` without discussing with the team
- Do NOT update major dependency versions without team approval
- Environment variables must be prefixed with `VITE_` to be exposed to client code
- The `vercel.json` file controls deployment config -- changes affect production
- Run `npx tsc --noEmit` to catch type errors that Vite's dev server may not surface
