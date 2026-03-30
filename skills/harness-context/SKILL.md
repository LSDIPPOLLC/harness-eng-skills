---
name: harness-context
description: >
  Optimize what information Claude loads and when — context budget analysis,
  CLAUDE.md restructuring, progressive disclosure design, and context layering.
  Use this skill whenever someone's CLAUDE.md is too long, too short, or poorly
  organized, when Claude seems to forget or ignore instructions, when context
  feels wasted on irrelevant info, or when designing what goes in CLAUDE.md vs.
  memory vs. commands vs. skill references. Trigger on: "optimize context",
  "CLAUDE.md is too long", "claude ignores my instructions", "context budget",
  "what should claude know", "restructure CLAUDE.md", or any concern about
  information overload or information gaps in Claude's context.
---

# Harness Context

Engineer what information Claude loads and when. The goal is maximum relevant context with minimum waste — every token in context should earn its place.

## Why context engineering matters

Claude's context window is large but not infinite. Everything loaded — CLAUDE.md, memory, skill descriptions, tool results, conversation history — competes for attention. When context is bloated with irrelevant information, Claude is more likely to miss or deprioritize the instructions that matter. When it's too sparse, Claude wastes time rediscovering things it should already know.

The sweet spot: Claude has exactly what it needs for the current task, and knows where to find everything else.

## Step 1: Audit Current Context Load

### Measure CLAUDE.md

```bash
# Line count and rough token estimate (1 token ≈ 4 chars)
wc -lc CLAUDE.md
```

| Size | Assessment |
|------|-----------|
| < 50 lines | Too sparse — missing critical information |
| 50-200 lines | Good for small/medium projects |
| 200-400 lines | Appropriate for large/complex projects |
| 400-600 lines | Getting heavy — look for things to move out |
| > 600 lines | Bloated — actively hurting performance |

### Measure total context load

Check all always-loaded context sources:
- CLAUDE.md (project root + any parent directories)
- MEMORY.md index
- Skill descriptions (name + description from all enabled skills)
- Settings and permissions

Estimate total: CLAUDE.md tokens + ~100 tokens per enabled skill + ~50 tokens for MEMORY.md index.

### Content quality check

Read CLAUDE.md and classify each section:

| Classification | Action |
|----------------|--------|
| **Critical** — build commands, code style, architecture | Keep in CLAUDE.md, front-load |
| **Useful** — conventions, patterns, preferences | Keep if concise, move to command if verbose |
| **Reference** — API docs, schemas, long lists | Move to .claude/commands/ or skill references |
| **Stale** — outdated info, removed features | Delete |
| **Redundant** — duplicates what's in config files | Delete (Claude can read the config) |
| **Generic** — could apply to any project | Delete or make specific |

## Step 2: Design Context Layers

### Layer 1: Always loaded (CLAUDE.md)
Content that's relevant to virtually every task:
- Project identity (what is this, what does it do)
- Build/test/run commands
- Code style rules (the ones humans can't easily infer)
- Architecture overview (where things live)
- Critical constraints ("never do X because Y")

**Budget target**: 100-300 lines

### Layer 2: On-demand (commands and skills)
Content that's relevant to specific workflows:
- Deployment procedures → `.claude/commands/deploy.md`
- Database migration steps → `.claude/commands/migrate.md`
- Release process → `.claude/commands/release.md`
- Code review checklist → skill or command
- Onboarding guide → command

**Budget**: unlimited per file, but each should be focused

### Layer 3: Discovered at runtime
Information Claude can find when needed:
- File contents (Claude reads files as needed)
- Git history (Claude runs git commands)
- Config file details (Claude reads .eslintrc, tsconfig, etc.)
- Test patterns (Claude reads existing tests)

**Don't put in CLAUDE.md** what Claude can discover by reading a file. For example, don't list all ESLint rules — just say "Follow .eslintrc" and Claude will read it.

### Layer 4: Persistent memory
Information that spans conversations but isn't always relevant:
- User preferences (feedback memories)
- Project status (project memories)
- External system references (reference memories)
- Team member context (user memories)

**Budget**: MEMORY.md index is always loaded (~50 tokens), individual memories loaded on demand.

## Step 3: Restructure CLAUDE.md

### Front-loading principle

Claude pays more attention to content near the top of CLAUDE.md. Order sections by:
1. Build/test commands (most universally needed)
2. Code style (prevents the most common mistakes)
3. Architecture (helps navigation)
4. Constraints and warnings (prevents costly errors)
5. Everything else

### Conciseness patterns

**Before** (verbose):
```markdown
## Testing
We use Jest for unit testing. Tests are located in the `__tests__` directory
next to the source files they test. When writing tests, please make sure to
follow our conventions for naming test files, which is to use the same name
as the source file but with a `.test.ts` extension. We prefer to use
`describe` and `it` blocks for organizing tests.
```

**After** (concise):
```markdown
## Testing
- Jest, co-located in `__tests__/` dirs
- Naming: `<source>.test.ts`
- Structure: `describe` > `it` blocks
- Run: `npm test` / single: `npm test -- --testPathPattern=<file>`
```

Same information, 1/3 the tokens. Claude understands bullet points just as well as prose.

### Deduplication

Check for information that exists in multiple places:
- CLAUDE.md mentions TypeScript AND tsconfig.json exists → remove TS config details from CLAUDE.md, just reference tsconfig
- CLAUDE.md lists ESLint rules AND .eslintrc exists → remove rules, just say "follow .eslintrc"
- CLAUDE.md describes commit format AND .commitlintrc exists → remove format, reference the config

### Anti-patterns to fix

- **Copy-pasted blocks**: Generic instructions copied from a template. Remove or make specific.
- **Instructing the obvious**: "Write clean code" or "follow best practices" — Claude already does this.
- **Excessive examples**: One example per pattern is enough. Three is too many for CLAUDE.md.
- **Changelogs in CLAUDE.md**: Never. That's what git log is for.
- **TODO lists**: These belong in issues, not CLAUDE.md.

## Step 4: Validate the Restructure

After making changes:

1. **Size check**: Is CLAUDE.md now within budget?
2. **Completeness check**: Can Claude still build, test, and navigate the project with just CLAUDE.md?
3. **Accessibility check**: Is moved-out content still discoverable? (commands listed, references pointed to)
4. **Freshness check**: Is everything in CLAUDE.md still accurate?

Ask the user to verify: "I've restructured CLAUDE.md from N lines to M lines. Here's what changed: [summary]. Want to review before I finalize?"

## Step 5: Set Up Maintenance

Context engineering isn't one-and-done. Recommend:
- Re-audit context every 2-4 weeks (or after major refactors)
- Use the `harness-drift` hook to flag when CLAUDE.md gets stale
- When adding new sections, ask "does this earn its context budget?"

Create a project memory noting when the last context optimization was done, so future audits can check timing.
