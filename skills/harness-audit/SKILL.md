---
name: harness-audit
description: "Audit and evaluate an existing Claude Code harness against the 7 pillars of harness engineering. Use this skill whenever someone wants to assess their setup, find gaps, check harness quality, score their configuration maturity, or understand what's missing from their Claude Code setup. Trigger on 'audit my harness', 'what's missing', 'check my setup', 'evaluate my config', 'harness health check', 'is my CLAUDE.md good', 'why isn't claude working well', or any request to diagnose or improve how Claude interacts with a project. Also trigger when someone is frustrated with Claude's behavior — that's usually a harness gap."
---

# Harness Audit

Evaluate an existing harness against the 7 pillars of harness engineering. Produce a maturity score, identify gaps, and recommend prioritized improvements.

## Audit Process

### Step 1: Gather Current State

Read all harness artifacts. Check each of these locations:

```
Project root:
  CLAUDE.md
  .claude/
    settings.json
    settings.local.json
    commands/
    memory/
      MEMORY.md
      *.md (individual memories)

User-level:
  ~/.claude/settings.json
  ~/.claude/settings.local.json
  ~/.claude/commands/
```

Also check:
- Git history for CLAUDE.md (how often is it updated?)
- Any skill directories referenced in settings
- Hook scripts referenced in settings
- MCP server configurations

### Step 2: Score Each Pillar

Rate each pillar on a 0-3 scale:

| Score | Meaning |
|-------|---------|
| 0 | **Absent** — No configuration for this pillar |
| 1 | **Basic** — Minimal setup, significant gaps |
| 2 | **Solid** — Good coverage, minor improvements possible |
| 3 | **Excellent** — Well-tuned, actively maintained |

#### Pillar 1: Skill Composition
- Are there project-specific skills or commands?
- Do skills have clear triggers and bounded scope?
- Is there composition (skills that call other skills)?
- Score 0: no commands/ or skills. Score 1: a few ad-hoc commands. Score 2: organized skill set with clear triggers. Score 3: composed skill system with routing.

#### Pillar 2: Context Engineering
- Does CLAUDE.md exist and contain project-specific info?
- Is it appropriately sized (not too long, not too sparse)?
- Are instructions front-loaded (most important first)?
- Is there a context layering strategy (always-loaded vs. on-demand)?
- Score 0: no CLAUDE.md. Score 1: generic/copy-pasted CLAUDE.md. Score 2: tailored CLAUDE.md with good structure. Score 3: optimized context budget with progressive disclosure.

#### Pillar 3: Orchestration & Routing
- Are there patterns for when to use subagents?
- Is there a build-loop or phased workflow?
- Are parallelization opportunities identified?
- Score 0: no orchestration guidance. Score 1: basic "use agents for X" notes. Score 2: defined workflows with routing. Score 3: build-loops with quality gates.

#### Pillar 4: Persistence & State
- Is there a memory system?
- Are memories well-organized and up-to-date?
- Is there a clear distinction between conversation-scoped and durable state?
- Score 0: no memory. Score 1: MEMORY.md exists but sparse/stale. Score 2: organized memory with multiple types. Score 3: active memory system with lifecycle management.

#### Pillar 5: Quality Gates & Feedback Loops
- Are there automated checks (hooks, CI integration)?
- Is there a self-evaluation pattern?
- Do feedback loops exist to improve the harness over time?
- Score 0: no automated validation. Score 1: basic linting hooks. Score 2: quality gates at multiple stages. Score 3: self-improving feedback loops.

#### Pillar 6: Permission & Safety Boundaries
- Is settings.json configured with appropriate permissions?
- Are permissions specific enough to be safe but broad enough for flow?
- Are dangerous operations gated?
- Score 0: default permissions only. Score 1: some allow rules but too broad/narrow. Score 2: well-tuned permissions matching project needs. Score 3: layered permissions with hooks for additional safety.

#### Pillar 7: Ergonomics & Trust Calibration
- Are there instructions about output style and verbosity?
- Is the trust level appropriate for the user?
- Are feedback memories being captured?
- Score 0: no ergonomic tuning. Score 1: basic style notes. Score 2: defined interaction patterns with feedback capture. Score 3: actively calibrated trust with consistent behavior.

### Step 3: Present the Report

Format the audit results:

```
Harness Audit Report
════════════════════

Overall Maturity: [X/21] — [Nascent|Developing|Solid|Advanced|Elite]

Pillar Scores:
  1. Skill Composition      [█░░] 1/3
  2. Context Engineering     [██░] 2/3
  3. Orchestration & Routing [░░░] 0/3
  4. Persistence & State     [██░] 2/3
  5. Quality Gates           [█░░] 1/3
  6. Permissions & Safety    [███] 3/3
  7. Ergonomics & Trust      [█░░] 1/3

Top 3 Recommendations (highest impact):
  1. [recommendation with rationale]
  2. [recommendation with rationale]
  3. [recommendation with rationale]
```

Maturity levels:
- 0-5: **Nascent** — Just getting started
- 6-10: **Developing** — Foundation in place
- 11-15: **Solid** — Good working harness
- 16-18: **Advanced** — Well-engineered setup
- 19-21: **Elite** — Comprehensive, actively maintained

### Step 4: Recommend Next Steps

Prioritize recommendations by impact/effort ratio:
- **Quick wins**: Things that can be fixed in minutes (add a permission, seed a memory)
- **High impact**: Things that will most improve the experience (usually context engineering or permissions)
- **Long-term**: Things that pay off over time (skill composition, quality gates)

Offer to execute the top recommendation immediately using the appropriate atomic skill.

## Re-Audit

After improvements are made, offer to re-audit to show progress. Track the score trajectory if memory is available — this itself becomes a useful project memory.
