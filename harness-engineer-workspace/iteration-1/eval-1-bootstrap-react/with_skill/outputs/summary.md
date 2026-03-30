# Bootstrap Summary: React/TypeScript/Vite Project

## What was done

Executed the `harness-init` composed skill, which orchestrates five phases to produce a complete Claude Code harness for a React/TypeScript project with Vite, ESLint, Prettier, Jest, and Vercel deployment.

### Phase 1: Scaffold (harness-scaffold)

**Generated `CLAUDE.md`** (~90 lines) with sections ordered by importance:

1. **Build & Run** -- All commands needed to install, dev, build, test, lint, format, and type-check. This is front-loaded because it is the most universally needed context.
2. **Code Style** -- TypeScript strict mode, Prettier/ESLint conventions, naming rules (PascalCase components, camelCase functions), import ordering, component patterns (functional + arrow + named exports).
3. **Architecture** -- Directory map of `src/` with purpose annotations for components/, hooks/, types/, utils/, services/, assets/, styles/. Notes on state management (Context + hooks), routing, API layer, and styling.
4. **Testing** -- Jest + React Testing Library. Co-located tests, naming convention, run commands, key patterns (prefer getByRole, test behavior not implementation, never mock hooks directly).
5. **Deployment** -- Vercel config, preview deploys on PRs, production from main, VITE_ prefix requirement for client-side env vars.
6. **Commit Conventions** -- Conventional commits format with examples.

**Why these sections:** Following the harness-context skill's front-loading principle and conciseness patterns. Every section has evidence-based content (detected from the described tech stack), no generic filler. The file stays well within the 200-line budget for a medium project.

### Phase 2: Permissions (harness-permissions)

**Generated `settings.json`** with 22 permission rules following the blast-radius principle:

- **Auto-allowed (local, reversible):** npm test, npm run scripts, npx tooling (tsc, prettier, eslint, jest, vite), node execution, git read commands (status, log, diff, branch, show), filesystem reads (ls, find, grep, cat, head, tail, wc), mkdir, which.
- **Left to prompt (shared state/destructive):** git push, git reset, rm -rf, npm publish, vercel deploy. These are intentionally NOT in the allow list.

**Why these patterns:** Specific enough to prevent accidental dangerous operations (e.g., `Bash(npm run *)` allows package.json scripts but not `npm publish`), broad enough to avoid constant prompting during normal development.

### Phase 3: Memory (harness-memory)

**Created memory structure** with 4 seed memories:

| File | Type | Purpose |
|------|------|---------|
| `user_role.md` | user | Establishes the user as a team member familiar with React/TS |
| `project_tech_stack.md` | project | Records the full stack to prevent incompatible suggestions |
| `project_bootstrap.md` | project | Tracks harness creation date for future audit timing |
| `reference_deployment.md` | reference | Vercel deployment details including the VITE_ prefix rule |

**MEMORY.md index** created with one-line hooks per memory, organized by type.

**Why these seeds:** Only memories with clear evidence were created. No speculative memories. The tech stack memory prevents Claude from suggesting webpack/Vitest/other incompatible tools. The deployment reference captures the VITE_ prefix rule which is easy to forget.

### Phase 4: Hooks (harness-hooks)

**Created 3 hook scripts:**

1. **auto-format.sh** (PostToolUse on Edit|Write) -- Runs Prettier on TS/TSX/JS/JSX/JSON/CSS/MD/HTML files after Claude writes or edits them. Ensures every file Claude touches matches project formatting without manual intervention.

2. **auto-lint.sh** (PostToolUse on Edit) -- Runs ESLint on TS/TSX/JS/JSX files after edits and reports issues back to Claude via stdout. Non-blocking (exit 0) so Claude sees the issues and can fix them in the same turn.

3. **secret-scanner.sh** (PreToolUse on Write|Edit) -- Blocks writes containing AWS keys, OpenAI keys, GitHub tokens, or private keys (exit 2). Warns on generic credential patterns without blocking (could be example code). This is the safety rail.

**Why these hooks:** Auto-format eliminates formatting noise in diffs. Auto-lint gives Claude immediate feedback to self-correct. Secret scanner prevents accidental credential leaks. A test-on-change hook was considered but omitted -- for a 200-file project with Jest, running tests on every edit could be slow and noisy. Better to run tests explicitly via `npm test`.

### Phase 5: Context Review (harness-context)

Validated the generated CLAUDE.md against context budget guidelines:
- ~90 lines: well within the 50-200 line range for a medium project
- Build commands front-loaded (most important section first)
- No redundancy with config files (says "follow .prettierrc" and "follow eslint.config.*" rather than listing rules)
- No generic filler ("write clean code" type instructions omitted)
- All sections have actionable, specific content

## Output files

```
outputs/
  CLAUDE.md              # Project instructions for Claude (90 lines)
  settings.json          # Permissions (22 rules) + hooks (3 entries)
  hooks/
    auto-format.sh       # Prettier on write/edit
    auto-lint.sh         # ESLint on edit, reports to Claude
    secret-scanner.sh    # Blocks secret writes
  memory/
    MEMORY.md            # Index file (4 entries)
    user_role.md          # User context
    project_tech_stack.md # Stack details
    project_bootstrap.md  # Harness creation tracking
    reference_deployment.md # Vercel deployment reference
  summary.md             # This file
```

## Recommended next steps

1. **Run `harness-audit` after 3-5 working sessions** to identify gaps in CLAUDE.md and tune permissions based on actual usage patterns.
2. **Add feedback memories** as preferences are discovered (e.g., "prefer CSS Modules over styled-components", "always use data-testid for e2e selectors").
3. **Consider quality gates** via `harness-gates` if the team wants automated test runs or build verification on conversation end.
4. **Make hook scripts executable** after placing them: `chmod +x .claude/hooks/*.sh`
5. **Install jq** if not already present -- the hook scripts depend on it for parsing tool input JSON.
