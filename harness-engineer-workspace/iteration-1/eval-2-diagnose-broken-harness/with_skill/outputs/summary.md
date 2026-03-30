# Diagnosis Summary

## Request Classification

The user reported three symptoms:
1. "It keeps asking me permission for everything"
2. "CLAUDE.md is like 2000 lines long and half of it is copy-pasted from some blog post"
3. "It never remembers what I told it last session"

Using the harness-engineer routing logic, this request was classified as:

- **Primary intent:** Evaluate existing setup (behavioral problems indicate harness gaps)
- **Scope:** Multi-pillar — the symptoms span Permissions (Pillar 6), Context Engineering (Pillar 2), and Persistence (Pillar 4)
- **Entry point:** `harness-audit` — because the request is diagnostic ("figure out what's wrong"), not a specific fix request

## Routing Decisions

### Step 1: Start with harness-audit

The "When Things Go Wrong" section of the harness-engineer skill maps the user's complaints directly:

| Complaint | Diagnostic check | Skill |
|---|---|---|
| "Too many permission prompts" | Check settings.json allow rules | `harness-permissions` |
| "CLAUDE.md is 2000 lines" | Context bloat, content quality | `harness-context` |
| "Never remembers" | Check memory system | `harness-memory` |

The audit was run first to score all 7 pillars and identify whether additional problems exist beyond the three stated complaints.

### Step 2: Identify affected pillars

The audit confirmed three critically deficient pillars and revealed a fourth contributing factor:

1. **Pillar 6 (Permissions):** Score 1/3. Empty allow list. Direct cause of complaint #1.
2. **Pillar 2 (Context):** Score 1/3. Bloated CLAUDE.md with ~65% waste content. Direct cause of complaint #2 and a contributing factor to complaints #1 and #3 (buried instructions, diluted attention).
3. **Pillar 4 (Persistence):** Score 0/3. No memory system at all. Direct cause of complaint #3.
4. **Pillar 7 (Ergonomics):** Score 2/3. Some interaction style guidance exists but is ineffective due to the above three problems. Contributing factor to complaint #1.

### Step 3: Determine fix sequence

Fixes were prioritized by the harness-audit skill's impact/effort framework:

1. **Quick win:** Fix permissions (10 min, immediate relief from prompt fatigue)
2. **High impact:** Trim CLAUDE.md (30 min, fixes context waste and improves instruction adherence)
3. **High impact:** Set up memory system (15 min, enables cross-session learning)

This sequence was chosen because permissions are the fastest to fix and provide the most immediately visible improvement. Context optimization second because it affects everything else. Memory third because it requires the context to be clean first (otherwise memories and CLAUDE.md will contain redundant information).

## Skills Consulted

| Skill | Purpose | Key Guidance Applied |
|---|---|---|
| `harness-engineer` | Master routing, request classification | Routing table, "When Things Go Wrong" diagnostic |
| `harness-audit` | Pillar scoring, gap identification | 0-3 scoring rubric, maturity levels, report format |
| `harness-permissions` | Permission design | Blast radius principle, pattern specificity, per-language templates |
| `harness-context` | CLAUDE.md restructuring | Size guidelines, content classification, front-loading principle, conciseness patterns |
| `harness-memory` | Memory system design | Memory types, file format, seeding strategy, what-goes-where decision tree |
| `harness-ergonomics` | Trust calibration | Trust levels, interaction style templates, anti-patterns |

## Compound Problem Analysis

The three complaints are not independent. They form a reinforcing failure loop:

```
Bloated CLAUDE.md (2000 lines)
    -> Claude's attention diluted
    -> Misses buried permission and style instructions
    -> Defaults to maximum caution (ask permission for everything)
    -> User corrects: "just do it"
    -> Correction not stored (no memory system)
    -> Next session: same over-cautious behavior
    -> User corrects again
    -> Frustration compounds
```

This is why the fix must address all three pillars together. Fixing permissions alone would reduce prompt fatigue but leave the context and memory problems to cause other behavioral issues. Fixing CLAUDE.md alone would improve instruction adherence but not eliminate the prompt problem or the forgetting problem. The three fixes work as a unit.

## Artifacts Produced

| File | Description |
|---|---|
| `audit-report.md` | Full 7-pillar audit with scores, specific problems, and root cause analysis |
| `recommended-fixes.md` | Prioritized action plan with steps, time estimates, and verification criteria |
| `fixed-settings.json` | Example settings.json with properly scoped permissions for a Node.js/TypeScript project |
| `fixed-CLAUDE.md` | Example restructured CLAUDE.md trimmed from ~2000 to ~80 lines with front-loaded, bullet-format content |
| `summary.md` | This file — diagnosis process and routing decisions |

## Expected Outcome

After applying all three priority fixes:

- **Permissions:** Routine commands execute without prompting. Only destructive operations (git push, rm -rf, deploy) still require confirmation.
- **Context:** CLAUDE.md drops from ~2000 lines to ~80-150 lines. Instructions are front-loaded, scannable, and project-specific. No generic filler, no config duplication, no stale references.
- **Memory:** Cross-session state is preserved. User preferences, feedback corrections, and project context survive session boundaries. Claude improves over time instead of resetting to zero.
- **Overall maturity:** From 4/21 (Nascent) to an estimated 12/21 (Solid) after initial fixes.
