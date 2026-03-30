# Harness Bootstrap Summary

## What was done

Full Claude Code harness bootstrap for a React/TypeScript/Vite project with Jest testing, ESLint, Prettier, and Vercel deployment. Executed all five phases of `harness-init`.

## Phase 1: Scaffold

Created `CLAUDE.md` with the following sections:

- **Build & Run**: All commands (install, dev, test, single test, lint, format, type check, build, preview)
- **Code Style**: TypeScript strict, Prettier config, ESLint setup, naming conventions, import ordering
- **Architecture**: Full directory map with `src/components/`, `src/features/`, `src/hooks/`, `src/lib/`, `src/pages/`, `src/types/` -- feature-based organization with co-location
- **Engineering Standards** (the key addition for iteration 2):
  - **Component Patterns**: Functional only, named exports, Props interfaces, composition over configuration, 150-line limit
  - **State Management**: Decision tree -- URL params first, React Query for server state, useState for local, Zustand for shared UI state. Explicit guidance against storing API responses in Zustand/Redux.
  - **API & Data Fetching**: Centralized API client, feature-scoped API functions, React Query hooks, typed ApiError objects, staleTime caching strategy
  - **Validation**: Zod schemas at boundaries, infer TS types from schemas, React Hook Form + Zod resolver for all forms
  - **Error Handling**: Three-level error boundaries (root, feature, component), let errors propagate, never swallow errors
  - **Testing Philosophy**: Behavior over implementation, no mocking what you don't own, integration-style component tests, MSW for API mocking, 3-8 tests per component guideline
- **Testing**: Framework, location, naming, run commands
- **Commit Conventions**: Conventional commits
- **Dependencies & External Services**: Full dependency list with env vars

Total CLAUDE.md: ~200 lines of substantive, opinionated guidance.

## Phase 2: Permissions

Created `settings.json` with:
- 21 permission allow rules covering npm scripts, Jest, TypeScript compiler, Prettier, ESLint, Vite, Node, and safe git/filesystem read commands
- All permissions follow blast-radius principle: auto-allow local/reversible operations, no auto-allow for git push, rm -rf, npm publish, or deploy commands

## Phase 3: Memory

Created memory system with MEMORY.md index and 4 seed memories:
- `user_role.md` -- New team member onboarding context
- `project_tech_stack.md` -- Full stack summary
- `project_deployment.md` -- Vercel deployment flow
- `reference_vercel.md` -- Vercel platform reference

## Phase 4: Hooks

Installed 3 hooks:
- **auto-format.sh** (PostToolUse on Edit|Write) -- Runs Prettier on supported files after Claude edits them
- **auto-lint.sh** (PostToolUse on Edit) -- Runs ESLint on TS/JS files and reports issues back to Claude
- **secret-scanner.sh** (PreToolUse on Write|Edit) -- Blocks writes containing AWS keys, API keys, or private keys (exit 2), warns on generic credential patterns

## Phase 5: Context Review

CLAUDE.md is approximately 200 lines -- well within budget for a project of this size. The most critical information (build commands) is front-loaded. Engineering standards are the second section, positioned for high visibility. Testing details, commit conventions, and dependency lists are at the end since they're referenced less frequently.

## Artifacts produced

```
outputs/
  CLAUDE.md              # Project context with Engineering Standards
  settings.json          # Permissions + hook configuration
  hooks/
    auto-format.sh       # Prettier auto-format on file changes
    auto-lint.sh         # ESLint feedback on edits
    secret-scanner.sh    # Secret detection gate
  memory/
    MEMORY.md            # Memory index
    user_role.md         # User context
    project_tech_stack.md    # Stack summary
    project_deployment.md    # Deployment flow
    reference_vercel.md      # Vercel reference
  summary.md             # This file
```

## Recommended next steps

- Run `harness-audit` after a few Claude sessions to identify gaps in the CLAUDE.md
- Add feedback memories as you discover team preferences Claude should remember
- Consider adding a `test-on-change.sh` hook once comfortable with the current hook setup
- Review and update Engineering Standards as you learn more about the team's actual patterns
