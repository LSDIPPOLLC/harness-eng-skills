# Harness Audit Report

```
Harness Audit Report
════════════════════

Overall Maturity: 4/21 — Nascent

Pillar Scores:
  1. Skill Composition        [░░░] 0/3
  2. Context Engineering       [█░░] 1/3
  3. Orchestration & Routing   [░░░] 0/3
  4. Persistence & State       [░░░] 0/3
  5. Quality Gates             [░░░] 0/3
  6. Permissions & Safety      [█░░] 1/3
  7. Ergonomics & Trust        [██░] 2/3
```

## Pillar-by-Pillar Analysis

### Pillar 1: Skill Composition — 0/3 (Absent)

**Finding:** No `.claude/commands/` directory exists. No custom skills or slash commands are defined. The user has no way to invoke repeatable workflows.

**Impact:** Every task starts from scratch. There is no codified knowledge about project-specific workflows like deployment, database migrations, or release processes.

### Pillar 2: Context Engineering — 1/3 (Basic)

**Finding:** CLAUDE.md exists but is severely bloated at approximately 2,000 lines (~8,000 tokens). Content analysis reveals:

| Classification | Estimated Lines | Percentage |
|---|---|---|
| **Critical** (build commands, architecture) | ~120 | 6% |
| **Useful** (conventions, patterns) | ~200 | 10% |
| **Generic/copy-pasted** (blog post content) | ~900 | 45% |
| **Redundant** (duplicates config files) | ~400 | 20% |
| **Stale** (outdated references) | ~380 | 19% |

**Specific problems identified:**

1. **Blog post copy-paste block (~900 lines):** A large section appears to be lifted from a "Best practices for working with AI" style article. It includes generic advice like "write clean code," "use meaningful variable names," and "follow SOLID principles." None of this is project-specific and Claude already knows these things. This is the single largest source of context waste.

2. **Redundant config duplication (~400 lines):** The CLAUDE.md reproduces ESLint rules, TypeScript compiler options, and Prettier configuration that already exist in `.eslintrc.js`, `tsconfig.json`, and `.prettierrc`. Claude can read these files directly.

3. **No front-loading:** Build commands are buried at line ~800. Critical constraints appear after the copy-pasted block. Claude's attention is diluted by the time it reaches actionable instructions.

4. **Stale references (~380 lines):** References to removed API endpoints, deprecated packages, and a team member who left 6 months ago. These actively mislead Claude.

5. **Verbose prose style:** Instructions written as multi-paragraph explanations instead of scannable bullet points. A 12-line paragraph explains the testing convention when 4 bullet points would suffice.

**Impact:** At 2,000 lines, the CLAUDE.md consumes a significant portion of the context window on every interaction. The generic and redundant content dilutes the signal of the instructions that actually matter, causing Claude to miss or deprioritize project-specific rules.

### Pillar 3: Orchestration & Routing — 0/3 (Absent)

**Finding:** No orchestration guidance exists. No patterns for subagent usage, no build-loop designs, no phased workflows.

**Impact:** Low for most users. This is an advanced pillar and its absence is expected at this maturity level. Not a priority fix.

### Pillar 4: Persistence & State — 0/3 (Absent)

**Finding:** No memory system exists. No `.claude/memory/` directory. No `MEMORY.md`. No user, feedback, project, or reference memories.

**Specific problems this causes:**

1. **"It never remembers what I told it last session"** — This is the direct consequence. Without a memory system, every session starts from zero. Corrections given in one session are lost. User preferences must be re-stated.

2. **No feedback persistence** — When the user corrects Claude's behavior (e.g., "don't mock the database in tests," "use the staging API, not production"), those corrections evaporate at session end.

3. **No user context** — Claude doesn't know the user's role, expertise level, or working preferences, forcing it to guess or ask every time.

**Impact:** High. This is the root cause of the "never remembers" complaint. Every repeated correction erodes trust and wastes time.

### Pillar 5: Quality Gates — 0/3 (Absent)

**Finding:** No hooks configured. No automated validation. No pre-commit checks, no post-write formatting, no drift detection.

**Impact:** Medium. Without hooks, there is no automated quality enforcement and no mechanism to detect when the harness itself drifts out of date.

### Pillar 6: Permissions & Safety — 1/3 (Basic)

**Finding:** `.claude/settings.json` exists but contains only default permissions. No project-specific allow rules have been configured.

**Current state of `settings.json`:**
```json
{
  "permissions": {
    "allow": []
  }
}
```

**Specific problems this causes:**

1. **"It keeps asking me permission for everything"** — This is the direct consequence. With no allow rules, Claude prompts for every `Bash` command, every file write, every tool invocation. Common operations like `npm test`, `git status`, `npm run build` all require manual approval.

2. **Permission fatigue** — The user is prompted so often that they either start blindly approving (defeating the safety purpose) or become frustrated and disengage.

3. **Flow destruction** — Every permission prompt breaks concentration. In a typical development session, this can mean 20-40 interruptions.

**Impact:** Critical. This is the most immediately felt problem and the easiest to fix. The user's primary complaint ("keeps asking me permission for everything") maps directly to this pillar.

### Pillar 7: Ergonomics & Trust — 2/3 (Solid)

**Finding:** The CLAUDE.md does contain some interaction style guidance, buried deep in the file. There are instructions about output format and a partial trust configuration. However:

1. **Trust level is implicitly Level 1 (New User)** — The combination of no permissions and buried style guidance means Claude defaults to maximum caution: confirming everything, explaining everything, over-summarizing.

2. **No feedback memory loop** — Even though the user has likely corrected Claude's behavior many times ("just do it," "stop asking"), none of those corrections persist.

3. **Interaction style instructions are drowned out** — The few good ergonomic instructions that exist are lost in the 2,000-line CLAUDE.md. Claude may not weight them strongly enough given all the competing content.

**Impact:** Medium. The ergonomic instructions exist but are ineffective due to problems in other pillars (context bloat, no memory, no permissions).

---

## Root Cause Analysis

The user's three complaints map cleanly to harness gaps:

| Complaint | Root Cause | Pillar |
|---|---|---|
| "Keeps asking permission for everything" | Empty allow list in settings.json | Pillar 6: Permissions |
| "CLAUDE.md is 2000 lines, half copy-pasted" | No context engineering, bloated CLAUDE.md | Pillar 2: Context |
| "Never remembers what I told it last session" | No memory system | Pillar 4: Persistence |

These three problems compound. The bloated CLAUDE.md makes it harder for Claude to follow the few good instructions that exist. The lack of memory means corrections never stick. The lack of permissions means every session is an interruption marathon. Together, they create the experience of a tool that is simultaneously over-cautious, poorly informed, and forgetful.

---

## Top 3 Recommendations (highest impact)

1. **Fix permissions immediately** (Pillar 6, 10 minutes) — Add project-specific allow rules to settings.json. This eliminates the most visible frustration source and has immediate, tangible impact on every session.

2. **Trim CLAUDE.md from 2,000 to ~200 lines** (Pillar 2, 30 minutes) — Remove the blog post copy-paste, remove config duplication, delete stale references, restructure with front-loaded critical info in bullet format. This directly addresses the second complaint and improves Claude's ability to follow project-specific instructions.

3. **Set up a memory system** (Pillar 4, 15 minutes) — Create `.claude/memory/` with MEMORY.md index. Seed initial memories for user role, key feedback rules, and project context. This addresses the third complaint and ensures future corrections persist.
