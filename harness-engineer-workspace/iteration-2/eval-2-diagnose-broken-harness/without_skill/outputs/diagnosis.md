# Diagnosis: Broken Claude Code Setup

## Issues Reported

1. **Claude keeps asking permission for everything**
2. **CLAUDE.md is ~2000 lines long with copy-pasted blog content**
3. **Claude never remembers what was told in previous sessions**

---

## Root Cause Analysis

### Issue 1: Excessive Permission Prompts

**Diagnosis:** The `settings.json` file (either at `~/.claude/settings.json` for global or `.claude/settings.json` for project-level) is missing or has an empty/restrictive `allowedTools` configuration. Claude Code uses an allowlist model -- tools and commands that are not explicitly permitted will trigger an interactive permission prompt every time.

**Likely state:**
- `allowedTools` array is empty or missing entirely
- No project-level settings file exists to grant blanket permissions for common operations
- The user has never accepted "always allow" for routine tools, or those acceptances were lost

**What to check:**
- `~/.claude/settings.json` -- global settings
- `.claude/settings.json` -- project-level settings
- Both files' `allowedTools` arrays

### Issue 2: Bloated CLAUDE.md (~2000 lines, copy-pasted blog content)

**Diagnosis:** The `CLAUDE.md` file has been stuffed with irrelevant content. This file is meant to be a concise project-level instruction set -- typically 50-200 lines covering project conventions, architecture notes, and workflow preferences. A 2000-line file with blog post content causes multiple problems:

- **Token waste:** CLAUDE.md is injected into every conversation's context window. 2000 lines of noise eats into the usable context, reducing Claude's ability to reason about actual code.
- **Instruction dilution:** When genuine instructions are buried in walls of copy-pasted text, Claude may ignore or deprioritize them.
- **Conflicting directives:** Blog posts often contain generic advice that conflicts with project-specific needs, causing unpredictable behavior.

**What to check:**
- `/path/to/project/CLAUDE.md` -- the project root file
- `~/.claude/CLAUDE.md` -- global instructions (if it exists)
- Whether there are multiple CLAUDE.md files at different directory levels that compound the problem

### Issue 3: No Memory Between Sessions

**Diagnosis:** Claude Code does not have built-in persistent memory across sessions by default. Each conversation starts fresh. The mechanisms for continuity are:

- **CLAUDE.md files** -- these persist between sessions and are the primary "memory" mechanism. But if the file is bloated with irrelevant content (Issue 2), any actual preferences recorded there get lost in the noise.
- **Session history** -- Claude Code can resume sessions with `claude --continue` or `claude --resume`, but this is per-session, not permanent memory.
- **Project settings** -- preferences in `settings.json` persist but are limited to tool permissions and configuration, not conversational context.

**The real problem:** The user likely expects Claude to "remember" conversational instructions (e.g., "I prefer tabs over spaces" or "always use pnpm"), but those instructions were never captured in CLAUDE.md or were drowned out by the 2000 lines of blog content. Without a clean, well-structured CLAUDE.md, there is no durable memory.

---

## Summary of Root Causes

| Symptom | Root Cause | Fix Category |
|---|---|---|
| Permission prompts | Missing/empty `allowedTools` in settings.json | Configuration |
| Bloated CLAUDE.md | Copy-pasted blog content, no curation | Content cleanup |
| No session memory | No structured CLAUDE.md preferences + not using --continue | Workflow + Content |
