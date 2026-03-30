# Diagnosis Summary

## What Was Wrong

The user reported three symptoms. Each traced to a distinct root cause in a different harness pillar:

| Symptom | Root Cause | Fix |
|---------|-----------|-----|
| "Keeps asking permission for everything" | No allow rules in `settings.json` at any level (project or user). Every tool invocation required manual approval. | Added 30 specific allow rules covering build tools, test runner, linter, safe git commands, and filesystem read operations. Dangerous commands (push, delete, deploy) remain gated. |
| "CLAUDE.md is 2000 lines, half copy-pasted" | Bloated context file containing ~850 lines of generic blog content, ~350 lines duplicating existing config files, ~200 lines of stale references, and ~300 lines of obvious instructions. Only ~300 lines (~15%) were useful. Build commands buried at line 847. | Rewrote from scratch as a ~140-line file. Front-loaded build commands. Added an Engineering Standards section with opinionated domain guidance. Referenced config files instead of duplicating them. Every line earns its context budget. |
| "Never remembers what I told it last session" | No memory system. No `.claude/memory/` directory, no `MEMORY.md` index, no memory files of any type. Every session started from zero. | Recommended creating memory infrastructure with index and seed files for user role, feedback preferences, and project status. |

## Audit Score

Before: **3/21 (Nascent)**
- Context Engineering: 1/3 (CLAUDE.md exists but bloated)
- Permissions: 1/3 (settings.json exists but empty)
- Ergonomics: 1/3 (some style notes buried in CLAUDE.md)
- All other pillars: 0/3

Projected after fixes: **12-14/21 (Solid)**
- Context Engineering: 2/3 (focused CLAUDE.md with engineering standards)
- Permissions: 2/3 (well-tuned allow rules)
- Persistence: 2/3 (memory system with seed content)
- Ergonomics: 2/3 (front-loaded instructions, appropriate verbosity)
- Quality Gates: 1/3 (basic hook recommended)
- Skill Composition: 1/3 (starter commands created)
- Orchestration: 0/3 (not addressed, lower priority)

## Artifacts Produced

1. **audit-report.md** -- Full 7-pillar audit with detailed findings per pillar, content classification of the bloated CLAUDE.md, and prioritized recommendations.

2. **recommended-fixes.md** -- Five fixes ordered by impact/effort ratio, each with problem statement, action steps, rationale, and verification method.

3. **fixed-settings.json** -- Drop-in replacement for `.claude/settings.json` with 30 specific allow rules. Follows the blast radius principle: auto-allow local/reversible operations, prompt for shared-state and external operations.

4. **fixed-CLAUDE.md** -- Complete rewrite from ~2000 lines to ~140 lines. Includes Build & Run, Code Style, Architecture, Engineering Standards (with 7 domain subsections), Testing Philosophy, Commit Conventions, and Environment Variables. The Engineering Standards section demonstrates opinionated domain guidance covering API design, validation, error handling, database patterns, auth, and testing philosophy.

5. **summary.md** -- This file.

## What To Do Next

1. Replace `.claude/settings.json` with `fixed-settings.json`
2. Replace `CLAUDE.md` with `fixed-CLAUDE.md` (adapt project-specific details as needed)
3. Create `.claude/memory/` directory and populate with initial memories
4. Create `.claude/commands/` with starter commands for common workflows
5. Re-audit in 2-4 weeks to measure improvement and address remaining pillars
