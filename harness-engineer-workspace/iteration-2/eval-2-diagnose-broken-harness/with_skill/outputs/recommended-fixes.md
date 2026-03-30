# Recommended Fixes

Prioritized by impact/effort ratio. Each fix includes what to do, why, and how to verify it worked.

## Fix 1: Configure Permissions (Quick Win -- 5 minutes)

**Problem**: Empty allow rules cause Claude to prompt for every tool invocation.

**What to do**:
- Add project-specific build/test/lint commands to `.claude/settings.json`
- Add universal safe commands (git read operations, filesystem reads) to `~/.claude/settings.json`
- Keep dangerous operations (git push, rm -rf, deploy) as always-prompt

**Why this is priority 1**: This is the highest-frequency pain point. Every permission prompt breaks flow and trains the user to either rage-click "allow" (dangerous) or avoid using Claude for tasks that require multiple commands.

**How to verify**: Start a new Claude session and run `npm test`. If it executes without a permission prompt, the fix is working.

**See**: `fixed-settings.json` for the exact configuration.

## Fix 2: Rewrite CLAUDE.md (High Impact -- 20 minutes)

**Problem**: 2000-line CLAUDE.md is 85% waste. Critical instructions are buried. Copy-pasted content dilutes project-specific guidance.

**What to do**:
1. Delete the current CLAUDE.md entirely
2. Write a new one following the front-loading principle (build commands first)
3. Keep it under 200 lines
4. Include only project-specific, actionable information
5. Add an Engineering Standards section with opinionated domain guidance
6. Reference config files instead of duplicating them ("Follow `.eslintrc.json`" not a list of rules)

**Content to cut**:
- Generic "how to use Claude" instructions (Claude already knows this)
- Copy-pasted TypeScript/React best practices (not project-specific)
- Duplicated ESLint/Prettier/TSConfig rules (Claude reads these files)
- Stale references to removed directories and departed team members
- "Write clean code" / "follow best practices" (instructing the obvious)

**Content to keep and front-load**:
- Build, test, and run commands
- Project-specific code style conventions (the ones not in config files)
- Architecture overview (where things live)
- Engineering standards (how the team actually writes code)
- Critical constraints and gotchas

**How to verify**: Count lines (`wc -l CLAUDE.md`). Should be 120-200. Read through it -- every line should be something Claude could not infer from reading the codebase.

**See**: `fixed-CLAUDE.md` for the rewritten version.

## Fix 3: Create Memory System (High Impact -- 10 minutes)

**Problem**: No memory infrastructure means zero cross-session persistence.

**What to do**:
1. Create `.claude/memory/` directory
2. Create `MEMORY.md` index with type-based organization
3. Seed initial memories:
   - `user_role.md` -- who the user is, their expertise, output preferences
   - `feedback_permissions.md` -- note that user prefers minimal prompting
   - `project_status.md` -- current active work and context

**Why memory, not CLAUDE.md**: User preferences and project status change over time. Memory can be updated without touching CLAUDE.md. Memory is also loaded on-demand based on relevance, while CLAUDE.md is loaded every time.

**How to verify**: In a new session, check if Claude addresses the user correctly and knows their preferences without being told again.

## Fix 4: Add Starter Commands (Quick Win -- 5 minutes)

**Problem**: No `.claude/commands/` directory means no slash commands for common workflows.

**What to do**:
- Create `.claude/commands/test.md` -- run full test suite
- Create `.claude/commands/dev.md` -- start development environment
- Move any reference material from the old CLAUDE.md into relevant command files

**Why**: Commands offload context from CLAUDE.md (always-loaded) to on-demand files. A deployment procedure that is 50 lines in CLAUDE.md becomes a command that is only loaded when the user types `/deploy`.

## Fix 5: Add Quality Gate Hook (Medium Impact -- 10 minutes)

**Problem**: No automated checks means no safety net for common mistakes.

**What to do**:
- Add a pre-commit hook that runs the linter
- Consider a pre-push hook that runs the test suite

**Why**: This is lower priority than fixes 1-4 because it does not address any of the three reported symptoms. But it prevents a class of problems (pushing broken code) that would otherwise generate frustration.

## Execution Order

For immediate relief, execute in this order:
1. Fix permissions (instant pain reduction)
2. Rewrite CLAUDE.md (next session will feel dramatically better)
3. Create memory system (cross-session improvements start accumulating)
4. Add commands (incremental improvement)
5. Add hooks (preventive, not urgent)

After all fixes: re-audit. Expected score improvement from 3/21 to 12-14/21 (Solid).
