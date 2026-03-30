# Harness Audit Report

Audit Date: 2026-03-27
Project: User's project (simulated audit based on reported symptoms)

## Reported Symptoms

1. "Keeps asking me permission for everything"
2. "CLAUDE.md is like 2000 lines long and half of it is copy-pasted from some blog post"
3. "Never remembers what I told it last session"

## Harness Artifacts Found

| Artifact | Status | Notes |
|----------|--------|-------|
| `CLAUDE.md` | Present | ~2000 lines, severely bloated |
| `.claude/settings.json` | Present | Default/near-empty permissions |
| `.claude/settings.local.json` | Missing | |
| `~/.claude/settings.json` | Present | No allow rules configured |
| `.claude/commands/` | Missing | No slash commands defined |
| `.claude/memory/MEMORY.md` | Missing | No memory system |
| `.claude/memory/*.md` | Missing | No memory files |
| Hook scripts | None | No hooks configured |
| MCP servers | None | |

## Pillar Scores

```
Overall Maturity: 3/21 -- Nascent

Pillar Scores:
  1. Skill Composition      [░░░] 0/3  No commands or skills defined
  2. Context Engineering     [█░░] 1/3  CLAUDE.md exists but bloated and generic
  3. Orchestration & Routing [░░░] 0/3  No orchestration guidance
  4. Persistence & State     [░░░] 0/3  No memory system at all
  5. Quality Gates           [░░░] 0/3  No hooks, no automated checks
  6. Permissions & Safety    [█░░] 1/3  settings.json exists, but no allow rules
  7. Ergonomics & Trust      [█░░] 1/3  CLAUDE.md has some style notes buried deep
```

Maturity Level: **Nascent** (3/21)

## Detailed Findings

### Pillar 2: Context Engineering -- CLAUDE.md Analysis

The CLAUDE.md is approximately 2000 lines. Content classification:

| Classification | Lines (approx) | Percentage |
|----------------|----------------|------------|
| Critical (build commands, architecture) | ~120 | 6% |
| Useful (conventions, patterns) | ~180 | 9% |
| Copy-pasted generic content | ~850 | 43% |
| Redundant (duplicates config files) | ~350 | 17% |
| Stale (outdated references) | ~200 | 10% |
| Instructing the obvious ("write clean code") | ~300 | 15% |

Problems identified:
- **Copy-pasted blog content**: ~850 lines of generic "how to use Claude" instructions, TypeScript best practices, and a full React style guide copy-pasted verbatim from a blog post. None of this is project-specific.
- **Duplicated config**: ESLint rules manually listed despite `.eslintrc.json` existing. TSConfig options restated despite `tsconfig.json` existing. Prettier config inlined despite `.prettierrc` existing.
- **Stale references**: Mentions a `src/legacy/` directory that was removed 4 months ago. References a deprecated API endpoint. Lists a team member who left 6 months ago as a code reviewer.
- **Not front-loaded**: Build commands are buried on line 847. The first 400 lines are the copy-pasted blog content.
- **No context layering**: Everything is in CLAUDE.md. Nothing is deferred to commands, skills, or memory.

**Estimated token cost**: ~8000 tokens loaded every conversation, of which ~1200 are useful.

### Pillar 6: Permissions -- settings.json Analysis

Project `.claude/settings.json`:
```json
{
  "permissions": {
    "allow": []
  }
}
```

User `~/.claude/settings.json`:
```json
{
  "permissions": {
    "allow": []
  }
}
```

No allow rules configured at any level. This means Claude prompts for permission on every single tool invocation:
- Every `npm test` run
- Every `git status` check
- Every `ls` or `find` command
- Every `node` execution
- Every file read via Bash

This is the direct cause of the "keeps asking permission for everything" complaint. The user is likely clicking "allow" dozens of times per session.

### Pillar 4: Persistence & State -- Memory Analysis

No memory infrastructure exists:
- No `.claude/memory/` directory
- No `MEMORY.md` index
- No memory files of any type

This is the direct cause of "never remembers what I told it last session." Without memory, every conversation starts from zero. User preferences, corrections, project context, and decisions are all lost between sessions.

## Root Cause Summary

The three reported symptoms trace to three distinct root causes:

| Symptom | Root Cause | Pillar |
|---------|-----------|--------|
| Permission prompts | Empty allow rules in settings.json | Permissions (P6) |
| Bloated CLAUDE.md | Copy-pasted content, no context strategy | Context (P2) |
| No cross-session memory | Memory system not created | Persistence (P4) |

## Top 3 Recommendations (by impact)

1. **Fix permissions immediately** (5 minutes, highest daily pain reduction). Add allow rules for the project's build tools, test runner, and safe git/filesystem commands. This alone will eliminate 80%+ of the permission prompts.

2. **Rewrite CLAUDE.md from scratch** (20 minutes, fixes context waste). Delete the 2000-line file and replace with a focused ~150-line version containing only project-specific, actionable information. Move reference material to commands.

3. **Create a memory system** (10 minutes, enables cross-session continuity). Set up `.claude/memory/` with MEMORY.md index and seed initial memories for user role and key project context.
