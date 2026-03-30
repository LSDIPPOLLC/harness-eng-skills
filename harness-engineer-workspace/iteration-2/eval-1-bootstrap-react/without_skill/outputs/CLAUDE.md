# Project Overview

React/TypeScript single-page application built with Vite, deployed to Vercel.

## Tech Stack

- **Framework:** React 18+ with TypeScript
- **Build Tool:** Vite
- **Linting:** ESLint (with TypeScript and React plugins)
- **Formatting:** Prettier
- **Testing:** Jest with React Testing Library
- **Deployment:** Vercel

## Project Structure

```
src/
  components/     # React components (PascalCase filenames)
  hooks/          # Custom React hooks (use* naming)
  utils/          # Utility/helper functions
  types/          # Shared TypeScript type definitions
  assets/         # Static assets (images, fonts, etc.)
  styles/         # Global styles and CSS modules
  pages/          # Page-level components / route views
  App.tsx         # Root application component
  main.tsx        # Application entry point
public/           # Static public assets
```

## Common Commands

- `npm run dev` -- Start the Vite development server
- `npm run build` -- Production build (runs `tsc && vite build`)
- `npm run preview` -- Preview the production build locally
- `npm run lint` -- Run ESLint across the project
- `npm run format` -- Run Prettier to format code
- `npm run test` -- Run the Jest test suite
- `npm run test:watch` -- Run tests in watch mode
- `npm run test:coverage` -- Run tests with coverage report

## Code Style and Conventions

- Use **functional components** with hooks; do not use class components.
- Components are named in **PascalCase** and live in files matching their name (e.g., `UserCard.tsx`).
- Custom hooks start with `use` (e.g., `useAuth.ts`).
- Use **named exports** for components; avoid default exports.
- Prefer **TypeScript interfaces** over type aliases for object shapes.
- Props interfaces are named `<ComponentName>Props` (e.g., `UserCardProps`).
- CSS Modules use `.module.css` or `.module.scss` suffix.
- Imports should be ordered: React, third-party libs, local modules, styles.
- All strings use single quotes (Prettier enforced).
- Semicolons are required (Prettier enforced).
- Max line width is 100 characters.

## Testing Guidelines

- Test files live next to the component they test: `Component.test.tsx`.
- Use React Testing Library -- query by role, label, or text, not by test IDs unless necessary.
- Each component should have at least one render test.
- Mock API calls and external dependencies; never make real network requests in tests.
- Run `npm run test` before committing to verify nothing is broken.

## Build and Deployment

- Vercel builds run `npm run build` and serve from `dist/`.
- Environment variables for Vercel are prefixed with `VITE_` so they are exposed to the client bundle.
- Do not commit `.env` files. Use `.env.example` as a template.
- The `vercel.json` file contains rewrite rules for SPA routing.

## Important Notes

- Do not modify `vite.config.ts` without team discussion.
- Keep bundle size in mind -- avoid importing entire libraries when a subpath import is available.
- All PRs must pass lint, format check, and tests before merge.
