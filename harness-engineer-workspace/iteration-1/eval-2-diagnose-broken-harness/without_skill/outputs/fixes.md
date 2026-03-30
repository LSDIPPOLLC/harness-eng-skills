# Fixes: Restoring a Healthy Claude Code Setup

## Fix 1: Configure Tool Permissions in settings.json

**File:** `~/.claude/settings.json` (global) or `.claude/settings.json` (project)

**Action:** Add sensible default permissions so Claude can perform routine operations without prompting.

**Principle:** Allow read operations and common dev tools freely. Require approval for destructive or security-sensitive operations.

See `example-settings.json` for the recommended configuration.

**Steps:**
1. Back up existing settings: `cp ~/.claude/settings.json ~/.claude/settings.json.bak`
2. Replace with the example settings (or merge into existing).
3. For project-specific overrides, create `.claude/settings.json` in the project root.

---

## Fix 2: Rewrite CLAUDE.md from Scratch

**File:** `CLAUDE.md` in the project root

**Action:** Delete the existing 2000-line file and replace it with a focused, project-specific file.

**Guidelines for a good CLAUDE.md:**

1. **Keep it under 150 lines.** Every line should earn its place.
2. **Only include project-specific information** that Claude would not otherwise know:
   - Build/test/lint commands
   - Project structure overview (brief)
   - Code style rules that differ from defaults
   - Architecture decisions and constraints
   - Common pitfalls specific to this codebase
3. **Never include:**
   - Generic coding advice ("write clean code")
   - Prompt engineering tips
   - Full API docs (reference file paths instead)
   - Conversation logs
   - Content copied from blog posts or tutorials
4. **Use sections with headers** for scannability.
5. **Be imperative and specific:** "Use `pnpm` not `npm`" beats "We prefer pnpm for package management because..."

See `example-CLAUDE.md` for a template.

**Steps:**
1. Back up existing: `cp CLAUDE.md CLAUDE.md.bak`
2. Identify the 5-10 genuinely useful instructions in the existing file.
3. Write a new CLAUDE.md using the example as a starting template, incorporating those instructions.
4. Delete the backup once satisfied.

---

## Fix 3: Set Up Cross-Session Memory Properly

**Action:** Use CLAUDE.md as the persistence layer for instructions that should survive across sessions.

**How to do it going forward:**

1. **During a session**, when you discover something Claude should always know, say:
   > "Add to CLAUDE.md: always run tests with `--no-cache` flag"

   Claude will append it to the file, and it will be loaded in every future session.

2. **Use the `/memory` command** (shortcut) to quickly append notes:
   > `/memory always use the staging database for integration tests`

3. **Periodically review CLAUDE.md** to prune outdated instructions. Treat it like code -- it should be maintained.

4. **For global preferences** (applying to all projects), use `~/.claude/CLAUDE.md`:
   - Preferred language/framework defaults
   - Your coding style preferences
   - Communication preferences (verbosity, format, etc.)

**Steps:**
1. Create `~/.claude/CLAUDE.md` if it does not exist.
2. Add 5-10 lines of global preferences.
3. Keep project CLAUDE.md for project-specific context only.

---

## Fix 4: Verify Installation and Version

**Action:** Ensure Claude Code is up to date, as older versions may have bugs or missing features.

```bash
claude --version
npm update -g @anthropic-ai/claude-code
```

---

## Verification Checklist

After applying fixes:

- [ ] Run `claude` in the project directory -- it should start without excessive permission prompts
- [ ] File reads, grep, and glob should execute without asking
- [ ] Bash commands for build/test/lint should execute without asking
- [ ] File writes should either auto-approve or prompt once (depending on your preference)
- [ ] CLAUDE.md loads quickly and Claude can summarize its contents accurately
- [ ] Start a new session and verify Claude follows instructions from CLAUDE.md
- [ ] Add a new instruction via conversation and verify it appears in CLAUDE.md
