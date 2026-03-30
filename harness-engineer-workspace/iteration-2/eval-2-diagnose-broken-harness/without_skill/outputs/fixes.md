# Fixes for Broken Claude Code Setup

## Fix 1: Stop Excessive Permission Prompts

### What to do

Configure `allowedTools` in your settings files to pre-approve common operations.

**Global settings** (`~/.claude/settings.json`):
Add commonly used tools so they never prompt, regardless of project.

**Project settings** (`.claude/settings.json` in project root):
Add project-specific tools and commands.

### Steps

1. Open or create `~/.claude/settings.json`
2. Add an `allowedTools` array with the tools you use regularly
3. Optionally create `.claude/settings.json` in your project root for project-specific permissions

See `example-settings.json` for a ready-to-use template.

### Key tools to allow

- `Bash` -- shell command execution (the most common prompt trigger)
- `Read` -- reading files
- `Edit` -- editing files
- `Write` -- writing new files
- `Glob` -- file search
- `Grep` -- content search

You can also allow specific shell commands by pattern, e.g.:
- `Bash(npm run *)` -- allow any npm script
- `Bash(git *)` -- allow git commands
- `Bash(make *)` -- allow make targets

---

## Fix 2: Clean Up CLAUDE.md

### What to do

Replace the 2000-line bloated file with a focused, well-structured document. Target: 50-150 lines.

### Steps

1. **Back up the current file:** `cp CLAUDE.md CLAUDE.md.backup`
2. **Identify real instructions:** Scan the existing file for any genuine project-specific instructions mixed in with the blog content. Look for:
   - Coding style preferences
   - Project architecture notes
   - Build/test commands
   - Naming conventions
   - Deployment notes
3. **Replace with a clean template:** Use the provided `example-CLAUDE.md` as a starting point
4. **Transfer genuine instructions:** Move any real instructions from the backup into the new file
5. **Delete the backup** once satisfied

### Guidelines for a good CLAUDE.md

- **Be concise.** Every line costs context tokens.
- **Be specific.** "Use pnpm, not npm" is better than a paragraph about package managers.
- **Be actionable.** Instructions Claude can follow, not background reading.
- **No copy-paste from blogs/docs.** If Claude needs reference material, point it to files in the repo.
- **Organize with headers.** Claude parses markdown structure well.
- **Update regularly.** Add new preferences as they come up, remove stale ones.

---

## Fix 3: Enable Session Memory

### What to do

Use a combination of CLAUDE.md for persistent preferences and session management for short-term continuity.

### For persistent preferences (things Claude should always know)

Add them to CLAUDE.md under a dedicated section. Examples:
- "Always use TypeScript strict mode"
- "Prefer functional components over class components"
- "Run `pnpm test` after making changes to src/"
- "The API base URL is defined in src/config.ts"

### For session continuity (picking up where you left off)

Use Claude Code's built-in session management:

```bash
# Continue the most recent session
claude --continue

# Resume a specific past session interactively
claude --resume
```

### For per-project memory

Create a project-level CLAUDE.md at the project root. This is automatically loaded when Claude Code is launched from that directory.

### For global memory (applies to all projects)

Create `~/.claude/CLAUDE.md` with preferences that span all projects:
- Coding style preferences
- Communication preferences ("be concise", "explain your reasoning")
- Tool preferences ("prefer ripgrep over grep")

---

## Implementation Order

1. **Fix the settings.json first** -- this immediately stops the permission spam
2. **Clean up CLAUDE.md second** -- this fixes both the bloat and the memory issues
3. **Adopt session management habits** -- use `--continue` and `--resume` as needed

All three fixes are independent and can be applied in any order, but the above sequence gives the fastest relief.
