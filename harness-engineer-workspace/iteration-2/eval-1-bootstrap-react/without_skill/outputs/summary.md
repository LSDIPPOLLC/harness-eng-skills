# Bootstrap Summary: React/TypeScript/Vite Project

## What Was Created

### 1. CLAUDE.md
The primary context file that Claude Code reads to understand the project. It contains:

- **Project overview** identifying this as a React/TS app built with Vite and deployed to Vercel.
- **Project structure** mapping out the `src/` directory layout so Claude knows where to find and place files.
- **Common commands** listing every npm script (dev, build, test, lint, format) so Claude can run them without guessing.
- **Code style conventions** covering component naming (PascalCase), export style (named exports), props interface naming, import ordering, and Prettier settings. This prevents Claude from generating code that fails lint or deviates from team patterns.
- **Testing guidelines** specifying that tests are co-located with components, use React Testing Library with role/label queries, and that API calls must be mocked.
- **Build and deployment notes** covering Vercel's `VITE_` env var prefix requirement, the `dist/` output directory, and SPA rewrite rules.

### 2. settings.json
Claude Code permission configuration that:

- **Pre-approves safe commands** like `npm run dev`, `npm run test`, `npm run lint`, `git` operations, and file read/edit tools so Claude can work without constant permission prompts.
- **Blocks dangerous commands** like `rm -rf /`, `npm publish`, and `vercel --prod` to prevent accidental production deployments or destructive operations.

### 3. .claudeignore
Tells Claude Code which files and directories to skip when indexing the codebase:

- **node_modules/** -- thousands of dependency files that add noise and consume context.
- **dist/build/** -- generated output, not source code.
- **coverage/** -- test coverage reports, not relevant to coding tasks.
- **.env files** -- secrets that should never be read or included in context.
- **Binary assets** (images, fonts) -- not parseable as code.
- **Lock files** -- large and not useful for understanding application logic.

This is important for a 200-file repo because it keeps Claude focused on the actual source code rather than wasting context window on generated or irrelevant files.

## Why These Files

These three files form the minimum effective configuration for Claude Code:

1. **CLAUDE.md** gives Claude the domain knowledge a new team member would need -- what the project is, how it is structured, what conventions to follow, and how to build/test/deploy.
2. **settings.json** removes friction by pre-approving routine commands while maintaining safety guardrails.
3. **.claudeignore** ensures Claude's file indexing stays fast and its context window is spent on code that matters.

No additional configuration files (like `.claude/` directory configs or MCP server settings) were created because they are not needed for a standard React/Vite project. The three files above cover the essential needs.
