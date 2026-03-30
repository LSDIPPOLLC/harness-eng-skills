# Recommended Fixes — Prioritized Action Plan

## Priority 1: Fix Permissions (Quick Win — 10 minutes)

**Problem:** Empty allow list causes Claude to prompt for every command.

**Action:** Write a properly scoped `settings.json` with allow rules for the project's toolchain.

**Steps:**
1. Detect the project's package manager and build tools (e.g., `package.json` scripts, `Makefile` targets).
2. Add specific allow rules for safe, routine commands: test runners, linters, formatters, read-only git operations, file inspection.
3. Keep dangerous operations (git push, rm -rf, deploy, publish) out of the allow list — they should always prompt.
4. Place universal safe commands (ls, cat, grep, git status) in user-level `~/.claude/settings.json`.
5. Place project-specific commands in `.claude/settings.json` (committed) or `.claude/settings.local.json` (local only).

**Verification:** Start a new session, run `npm test` or equivalent — it should execute without prompting.

**See:** `fixed-settings.json` for the example configuration.

---

## Priority 2: Trim CLAUDE.md (High Impact — 30 minutes)

**Problem:** 2,000-line CLAUDE.md with ~65% waste content drowns out useful instructions.

**Action:** Restructure to ~150-200 lines of high-signal, front-loaded, bullet-format content.

**Steps:**
1. **Delete the blog post block** (~900 lines). Generic AI advice has zero project-specific value and Claude already knows best practices.
2. **Delete config duplication** (~400 lines). Remove reproduced ESLint, TypeScript, and Prettier configs. Replace with one-line references: "Follow `.eslintrc.js` for linting rules."
3. **Delete stale references** (~380 lines). Remove mentions of deprecated APIs, removed packages, and departed team members.
4. **Restructure remaining content** (~320 lines of useful + critical content):
   - Section 1: Build / Test / Run commands (most universally needed)
   - Section 2: Code style rules (only the non-obvious ones)
   - Section 3: Architecture overview (where things live)
   - Section 4: Critical constraints ("never do X because Y")
   - Section 5: Interaction style (trust level, output preferences)
5. **Convert prose to bullets.** Every multi-paragraph explanation becomes a scannable bullet list.
6. **Move verbose reference content** to `.claude/commands/` as on-demand resources.

**Verification:** Count lines (target: 150-200). Verify Claude can still build, test, and navigate the project using only the trimmed CLAUDE.md.

**See:** `fixed-CLAUDE.md` for the example restructured file.

---

## Priority 3: Set Up Memory System (High Impact — 15 minutes)

**Problem:** No memory system means corrections and context are lost between sessions.

**Action:** Create `.claude/memory/` with MEMORY.md index and seed initial memories.

**Steps:**
1. Create directory: `mkdir -p .claude/memory`
2. Create `MEMORY.md` index with type-organized sections (User, Feedback, Project, References).
3. Seed `user_role.md` — capture the user's role, expertise level, and working preferences.
4. Seed `feedback_interaction_style.md` — capture known preferences like "don't ask permission for routine tasks," "terse output preferred."
5. Seed any project-level memories for active work or deadlines.
6. Seed reference memories for external systems (issue tracker, CI/CD, staging environment).

**Naming convention:** Prefix files with type: `user_`, `feedback_`, `project_`, `reference_`.

**Verification:** Check that MEMORY.md index matches actual files. Verify each memory has complete frontmatter (name, description, type).

---

## Priority 4: Add Interaction Style Section (Medium Impact — 5 minutes)

**Problem:** Trust level defaults to maximum caution (Level 1) because no explicit calibration exists.

**Action:** Add a concise interaction style section to the trimmed CLAUDE.md.

**Steps:**
1. Determine appropriate trust level based on user behavior (the frustration with permission prompts suggests Level 2 or 3).
2. Add a 5-10 line interaction style block to CLAUDE.md.
3. Store the trust calibration as a feedback memory so it persists.

**Template (Level 2 — Established User):**
```markdown
## Interaction Style
- Execute routine tasks without confirmation.
- Confirm before destructive or irreversible actions.
- Concise output. State results, not reasoning.
- Surface only non-obvious decisions.
- No summaries, no transitions, no filler.
```

---

## Priority 5: Add Basic Quality Gate (Long-term — 20 minutes)

**Problem:** No automated validation means the harness can drift silently.

**Action:** Add a pre-commit hook for linting and a harness-drift check.

**Steps:**
1. Configure a hook in settings.json that runs the project linter on file save.
2. Consider a periodic drift check that flags when CLAUDE.md content no longer matches the project state.

**Note:** This is lower priority. Fix Priorities 1-3 first and let the setup stabilize before adding automation.

---

## Execution Order

```
Session 1 (immediate, ~55 minutes total):
  1. Fix permissions in settings.json          [10 min]
  2. Trim and restructure CLAUDE.md            [30 min]
  3. Set up memory system with seed memories   [15 min]

Session 2 (next day, after testing):
  4. Fine-tune interaction style based on use   [5 min]
  5. Add quality gates if needed               [20 min]
  6. Re-audit to measure improvement           [10 min]
```

**Expected score after Session 1:** 10-12/21 (Developing to Solid), up from 4/21 (Nascent).

**Expected score after Session 2:** 13-15/21 (Solid), with clear path to Advanced.
