---
name: harness-scaffold
description: >
  Generate a tailored CLAUDE.md and .claude/ directory structure for any project.
  Use this skill whenever someone needs to create a CLAUDE.md from scratch, set up
  their .claude/ directory, generate initial project configuration for Claude Code,
  or when bootstrapping a new repo. Trigger on: "create CLAUDE.md", "set up claude
  for this project", "scaffold my config", "generate project instructions",
  "write CLAUDE.md", or any request to create the foundational harness files.
  Also use when someone says "claude doesn't understand my project" — that means
  the scaffold is missing or inadequate.
---

# Harness Scaffold

Generate a project-tailored CLAUDE.md and .claude/ directory structure by analyzing the codebase. The scaffold is the foundation — every other harness pillar builds on top of it.

## Why scaffolding matters

Without a CLAUDE.md, Claude starts every conversation blind. It doesn't know your build commands, coding style, architecture patterns, or team conventions. A good scaffold eliminates the first 5 minutes of every session where you'd otherwise be re-explaining context.

## Step 1: Detect the Tech Stack

Read these files to understand the project. Check each one — don't assume they exist:

**Package/build manifests:**
- `package.json` — Node.js/JS/TS projects (scripts, dependencies, engines)
- `pyproject.toml` / `setup.py` / `requirements.txt` — Python projects
- `Cargo.toml` — Rust projects
- `go.mod` — Go projects
- `Gemfile` — Ruby projects
- `pom.xml` / `build.gradle` — Java/Kotlin projects
- `Makefile` / `justfile` / `Taskfile.yml` — Task runners
- `docker-compose.yml` / `Dockerfile` — Container setup

**Code style configuration:**
- `.editorconfig` — Universal editor settings
- `.prettierrc` / `.prettierrc.json` — Prettier config
- `.eslintrc*` / `eslint.config.*` — ESLint config
- `tsconfig.json` — TypeScript configuration
- `.rubocop.yml` — Ruby style
- `ruff.toml` / `pyproject.toml [tool.ruff]` — Python linting
- `.clang-format` — C/C++ formatting

**CI/CD:**
- `.github/workflows/` — GitHub Actions
- `.gitlab-ci.yml` — GitLab CI
- `Jenkinsfile` — Jenkins
- `.circleci/` — CircleCI
- `vercel.json` / `netlify.toml` — Deployment platforms

**Testing:**
- `jest.config.*` / `vitest.config.*` — JS test frameworks
- `pytest.ini` / `conftest.py` — Python testing
- `cypress/` / `playwright.config.*` — E2E testing

## Step 2: Analyze Git History

```bash
# Commit message style (conventional? freeform? ticket prefixed?)
git log --oneline -20

# Most active directories (where does work happen?)
git log --pretty=format: --name-only -50 | sort | uniq -c | sort -rn | head -20

# Contributors (team size context)
git shortlog -sn --no-merges | head -10
```

This tells you: what the commit conventions are, which parts of the codebase are active, and whether this is a solo or team project.

## Step 3: Extract Domain Engineering Patterns

This is where the scaffold goes beyond tooling and into engineering philosophy. Read actual source files to extract the team's established patterns. These opinions are what prevent Claude from writing structurally correct but stylistically alien code.

**Sample 5-10 representative files** from the most active directories (identified in Step 2). For each domain below, look for established patterns:

### Frontend (React/Vue/Svelte/etc.)
- **Component patterns**: Functional vs. class? Props interface inline or extracted? Default exports or named? Barrel files?
- **State management**: What's the strategy? (Redux, Zustand, Context, signals, stores) Where does state live — local, global, server?
- **Data fetching**: How do API calls work? (React Query, SWR, custom hooks, fetch wrappers) Where do fetch functions live?
- **Form handling**: Library or manual? (React Hook Form, Formik, native) Validation approach? (Zod, Yup, custom)
- **Styling**: CSS modules, Tailwind, styled-components, CSS-in-JS? Naming conventions for classes?
- **Routing**: File-based or config-based? Route guards? Layout patterns?

### Backend / API
- **API client patterns**: How are HTTP clients structured? Error handling? Response typing?
- **Validation**: Where and how? (middleware, decorators, schemas) Input sanitization approach?
- **Error handling**: Custom error classes? Error codes? How errors propagate to clients?
- **Database access**: ORM or raw queries? Repository pattern? Migration strategy?
- **Auth patterns**: JWT, session, OAuth? Where is auth checked?

### General
- **File organization**: Feature-based or layer-based? Co-location rules?
- **Dependency injection**: Constructor injection, context, global singletons?
- **Logging**: Structured or unstructured? What gets logged? Logger setup?
- **Environment config**: How are env vars accessed? Validation at startup?

### Testing philosophy
- **Test scope**: Unit-heavy or integration-heavy? E2E coverage?
- **Mocking policy**: What gets mocked and what doesn't? Are there real DB tests?
- **Assertion style**: What assertions matter most? Behavioral or structural?
- **Test data**: Factories, fixtures, inline? Shared helpers?

To extract these patterns, read a few key files:
```bash
# Find the most-changed source files (these reflect the team's patterns)
git log --pretty=format: --name-only -100 | grep -E '\.(ts|tsx|js|jsx|py|go|rs|rb)$' | sort | uniq -c | sort -rn | head -10

# Sample a component, a service/hook, a test, and a utility
```

Read those files and note the patterns. You're not inventing conventions — you're documenting what the team already does so Claude follows suit.

## Step 4: Scan Architecture

```bash
# Directory structure (top 2 levels)
find . -maxdepth 2 -type d -not -path '*/node_modules/*' -not -path '*/.git/*' -not -path '*/venv/*' | sort

# Entry points
ls -la src/index.* src/main.* src/app.* app.* index.* main.* 2>/dev/null
```

Look for patterns: monorepo (packages/, apps/), standard web (src/components/, src/pages/), API (routes/, controllers/), library (lib/, src/).

## Step 4: Generate CLAUDE.md

Structure the CLAUDE.md with these sections in order of importance (most important first, because context has a budget):

### Template

```markdown
# Project Name

Brief description of what this project does and its primary purpose.

## Build & Run

[Most critical section — how to build, run, and test]

```bash
# Install dependencies
<detected install command>

# Run development server
<detected dev command>

# Run tests
<detected test command>

# Run single test
<detected single-test command>

# Lint / format
<detected lint command>
```

## Code Style

[Conventions detected from config files and codebase]

- Language: <detected>
- Formatting: <tool and key settings>
- Naming: <conventions observed — camelCase, snake_case, etc.>
- Imports: <ordering conventions>
- Error handling: <patterns used>

## Architecture

[High-level structure — where things live and why]

- `src/` — <purpose>
- `src/components/` — <purpose>
- `tests/` — <purpose>
- Key patterns: <MVC, hooks, services, etc.>

## Engineering Standards

[Opinionated guidance extracted from the codebase. Only include domains relevant to the project.]

### Component Patterns
- <How to write components — composition, props, state, naming>
- <Preferred patterns with brief rationale>

### State Management
- <Where state lives and why — local vs. global vs. server>
- <Libraries/patterns in use and how to choose between them>

### API & Data Fetching
- <How API calls are structured — client patterns, error handling, caching>
- <Where fetch logic lives, how responses are typed>

### Validation
- <Where and how — schemas, middleware, form-level>
- <Libraries in use, patterns to follow>

### Error Handling
- <How errors propagate — custom classes, error boundaries, logging>
- <What to catch vs. what to let bubble>

### Testing Philosophy
- <What to test and how — behavioral over structural>
- <Mocking policy: what gets mocked, what uses real implementations>
- <Test data approach — factories, fixtures, inline>
- <A good test verifies behavior a user cares about, not implementation details>

## Testing

[How tests are organized, what framework, how to run specific tests]

- Framework: <detected>
- Location: <where tests live>
- Naming: <test file naming convention>
- Run specific: `<command to run one test file>`

## Commit Conventions

[Detected from git log]

<conventional commits? ticket prefix? freeform?>

## Dependencies & External Services

[Key dependencies, APIs, databases, services the project talks to]
```

### Adaptation rules

- Only include sections you have evidence for. Don't guess.
- If the project is a monorepo, add a section describing each package/app.
- If there's a deployment process, document it.
- If there are environment variables, list them (without values).
- Keep total length under 200 lines for small projects, under 400 for large ones.
- **Engineering Standards are the highest-value section** after Build & Run. These are what prevent Claude from writing code that works but doesn't fit the project. Be opinionated — document what the team actually does, not every possible approach. If the codebase uses Zustand, say "Use Zustand for global state" — don't list alternatives.
- For Testing Philosophy, emphasize *what makes a good test here* — not just which framework. If the team values integration tests over unit tests, say so. If over-mocking is an anti-pattern, call it out explicitly.

## Step 5: Create .claude/ Directory

```
.claude/
├── settings.json        # Project-level permissions
└── commands/            # Slash commands for common workflows
```

Create `settings.json` with minimal permissions to start:

```json
{
  "permissions": {
    "allow": []
  }
}
```

Permissions get configured properly by `harness-permissions` — keep the scaffold minimal.

Create 1-2 starter commands if obvious workflows exist:

- `commands/test.md` — "Run the full test suite and report results"
- `commands/dev.md` — "Start the development server"

## Step 6: Present and Confirm

Show the generated CLAUDE.md to the user. Ask:
1. "Does this accurately describe your project?"
2. "Anything missing or wrong?"
3. "Any team conventions I should know about?"

Iterate based on feedback before writing the final version. The scaffold is the foundation — getting it right here saves work everywhere else.

## Common Pitfalls

- **Too generic**: "This is a TypeScript project" is useless. Be specific: "SvelteKit app using TypeScript strict mode, Tailwind CSS, deployed to Vercel."
- **Too verbose**: Don't paste entire config files. Summarize the key settings.
- **Missing build commands**: The #1 thing Claude needs is how to build and test. If you skip this, every session starts with "how do I run the tests?"
- **Stale information**: A CLAUDE.md written once and never updated is worse than none — it teaches Claude wrong things. Note the creation date so future audits can check freshness.
