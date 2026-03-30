---
name: harness-loop
description: "Continuous improvement loop for Claude Code harnesses. Use this skill when someone wants to iteratively improve their harness, run an improvement cycle, grind through harness enhancements, or set up ongoing harness maintenance. Trigger on 'improve my harness', 'iterate on the harness', 'harness improvement loop', 'make my setup better', 'keep improving', or when the user wants to systematically work through harness gaps identified by an audit. Also use when the user says something like 'what should I work on next' in the context of harness engineering."
---

# Harness Loop

A continuous improvement cycle that identifies the weakest pillar, improves it, validates the improvement, and moves to the next. This is the build-loop pattern applied to harness engineering itself.

## The Loop

```
┌─────────────────────────────────┐
│  1. Audit (assess current state) │
├─────────────────────────────────┤
│  2. Identify (weakest pillar)    │
├─────────────────────────────────┤
│  3. Improve (apply atomic skill) │
├─────────────────────────────────┤
│  4. Validate (check improvement) │
├─────────────────────────────────┤
│  5. Log (record what changed)    │
├─────────────────────────────────┤
│  6. Continue? (user decides)     │
└─────────────────────────────────┘
```

### Step 1: Audit

If no recent audit exists, run `harness-audit` to get the current pillar scores. If the user just ran an audit, use those results.

### Step 2: Identify the Target

Pick the pillar to improve based on:
1. **Lowest score first** — bring up the floor before polishing the ceiling
2. **User preference** — if they care more about X, do X even if Y scores lower
3. **Dependencies** — some pillars depend on others (you need context engineering before quality gates make sense)

Dependency order (rough):
```
scaffold → context → permissions → hooks → memory → skills → routing → gates → ergonomics
```

Tell the user: "Your weakest area is [X] (score [N]/3). I'll focus on improving that. Sound good?"

### Step 3: Improve

Route to the appropriate atomic skill and execute its full workflow:

| Pillar | Atomic Skill |
|--------|-------------|
| Skill Composition | `harness-skills` |
| Context Engineering | `harness-context` |
| Orchestration & Routing | `harness-routing` |
| Persistence & State | `harness-memory` |
| Quality Gates | `harness-gates` |
| Permissions & Safety | `harness-permissions` |
| Safety (Hooks) | `harness-hooks` |
| Ergonomics & Trust | `harness-ergonomics` |
| Foundation | `harness-scaffold` |

### Step 4: Validate

After the improvement:
1. Re-score the target pillar — did the score improve?
2. Check for regressions — did the change break anything in adjacent pillars?
3. Run `harness-validate` hook logic to check consistency

If the score didn't improve, diagnose why:
- Was the improvement too incremental?
- Did it address the right gap?
- Does the user agree the score should be higher?

### Step 5: Log

Record what was done. If memory is available, save a project memory:

```markdown
---
name: harness-improvement-log
description: Track of harness improvements and pillar score changes over time
type: project
---

## Improvement Log

| Date | Pillar | Before | After | What Changed |
|------|--------|--------|-------|-------------|
| 2026-03-27 | Context | 1 | 2 | Restructured CLAUDE.md, moved verbose docs to commands/ |
```

If an existing log memory exists, update it rather than creating a new one.

### Step 6: Continue or Stop

Present the updated scores and ask: "Want to continue to the next pillar, or stop here?"

If continuing:
- Move to the next weakest pillar
- Repeat from Step 2

If stopping:
- Summarize all improvements made in this session
- Show before/after scores
- Suggest what to tackle next time

## Session Continuity

If the user comes back in a new session and says "keep improving my harness":
1. Check for the improvement log memory
2. Re-audit to get fresh scores (things may have changed)
3. Resume the loop from where they left off

This is why the improvement log is important — it provides continuity across sessions.

## Parallel Improvements

For advanced users who want to move faster:
- Identify 2-3 independent pillars that can be improved simultaneously
- Spawn subagents for each atomic skill
- Validate all changes together at the end

Independence heuristic: pillars are independent if improving one doesn't touch the same files as improving another. For example, memory and permissions can usually be improved in parallel since they modify different files.
