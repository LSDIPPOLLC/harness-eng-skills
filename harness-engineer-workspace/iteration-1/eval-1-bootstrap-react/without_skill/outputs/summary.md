# Bootstrap Summary: React/TypeScript/Vite/Jest/Vercel Project

## What Was Created

### 1. CLAUDE.md
The primary context file that Claude Code reads to understand the project. Contains:

- **Project overview** -- identifies the tech stack (React, TypeScript, Vite, Jest, Vercel) so Claude understands what it is working with.
- **Project structure** -- maps the `src/` directory layout so Claude can navigate the codebase and place new files correctly.
- **Common commands** -- lists every command Claude needs (dev server, testing, linting, formatting, type-checking, building). This is critical so Claude runs the right commands without guessing.
- **Code conventions** -- file naming (PascalCase components, camelCase utils), export style (named over default), component style (functional with hooks). Keeps Claude's output consistent with the team's patterns.
- **TypeScript guidelines** -- strict mode rules, `interface` vs `type` preferences, no `any`. Prevents Claude from generating loose TypeScript.
- **Testing guidelines** -- co-located tests, React Testing Library best practices, accessible queries over test IDs. Ensures Claude writes tests the way the team expects.
- **Important warnings** -- do not modify vite.config.ts or bump major deps without approval, VITE_ prefix requirement for env vars, vercel.json caution. Guards against common mistakes.

### 2. settings.json
Claude Code permissions configuration:

- **Allowed commands** -- pre-approves safe, routine commands (dev, build, test, lint, format, type-check, install) so Claude can run them without prompting every time. This reduces friction significantly on a 200-file project where you will be running tests and lint checks constantly.
- **Denied commands** -- blocks destructive or deployment-related commands (force push, npm publish, vercel deploy) to prevent accidental production impact.

### 3. .claudeignore
Controls which files Claude Code indexes, similar to `.gitignore`. Reasons for each exclusion:

- **node_modules/, dist/, build/, .vercel/, coverage/** -- generated/third-party content that wastes context window and adds no value for code understanding.
- **.env files** -- security: prevents Claude from reading secrets.
- **Binary assets (images, fonts, video)** -- not useful for code analysis and waste context.
- **Lock files** -- extremely large, machine-generated, not useful for understanding code.

## Why These Files

| File | Purpose |
|------|---------|
| CLAUDE.md | Gives Claude project context, commands, and conventions |
| settings.json | Pre-approves safe commands, blocks dangerous ones |
| .claudeignore | Keeps context window focused on actual source code |

## Placement

In the actual project, these files go in the repository root:

```
project-root/
  CLAUDE.md            # Project context for Claude
  .claude/
    settings.json      # Claude Code permissions
  .claudeignore        # File exclusion rules
  src/
  ...
```

Note: `settings.json` should be placed inside a `.claude/` directory at the project root. It is output here as a flat file for evaluation purposes.
