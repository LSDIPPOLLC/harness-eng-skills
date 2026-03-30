# Diagnosis: Broken Claude Code Setup

## Symptom 1: "Keeps asking me permission for everything"

**Root Cause:** The `settings.json` (either `~/.claude/settings.json` globally or `.claude/settings.json` per-project) has no `allowedTools` configured, or it is set to an empty list. Without explicit tool permissions, Claude Code defaults to prompting the user before every tool invocation -- file reads, writes, bash commands, etc.

**What we'd expect to find:**

```json
// ~/.claude/settings.json
{
  "permissions": {
    "allow": [],
    "deny": []
  }
}
```

Or the file may not exist at all, which means full default (prompt for everything).

**Contributing factor:** If the user previously had a working config and it got overwritten (e.g., by a reinstall or by manually editing the file incorrectly), all previously granted permissions would be lost. Claude Code does not persist per-session "allow once" decisions across sessions.

---

## Symptom 2: "CLAUDE.md is like 2000 lines long and half of it is copy-pasted from some blog post"

**Root Cause:** The project-level `CLAUDE.md` file has been stuffed with excessive, irrelevant content. Common anti-patterns found in bloated CLAUDE.md files:

1. **Copy-pasted "prompt engineering" guides** from blog posts or Twitter threads -- these are instructions *about* how to prompt, not actual project context.
2. **Entire API documentation** pasted inline instead of referenced.
3. **Duplicate sections** where the same instruction appears multiple times in different wording.
4. **Generic instructions** that restate Claude's default behavior (e.g., "write clean code," "use best practices") adding token cost with zero benefit.
5. **Conversation history or logs** accidentally appended to the file.
6. **Full file contents** pasted in as "examples" instead of referencing paths.

**Impact:** A 2000-line CLAUDE.md consumes a large portion of the context window on every session start. This:
- Reduces the effective context available for actual work.
- Dilutes the signal of genuinely useful project instructions.
- Can cause Claude to over-index on irrelevant pasted content.
- Slows down session initialization.

**What a healthy CLAUDE.md looks like:** 50-150 lines of concise, project-specific instructions covering build commands, test commands, code style rules, architecture notes, and common gotchas.

---

## Symptom 3: "It never remembers what I told it last session"

**Root Cause:** Claude Code sessions are stateless by design -- each new `claude` invocation starts fresh. There is no automatic memory across sessions. The user likely expects that instructions given conversationally ("always use tabs," "never modify the database schema directly") would persist, but they do not.

**What should be done instead:**
- Persistent instructions belong in `CLAUDE.md` (project-level) or `~/.claude/CLAUDE.md` (global).
- Claude Code can be told to "add this to CLAUDE.md" during a session, which writes the instruction to the file for future sessions.
- The `/memory` command (if available in the user's version) can also append to CLAUDE.md.

**Contributing factor:** Because the existing CLAUDE.md is 2000 lines of noise, even if the user *did* add instructions there, they may be buried and deprioritized by the model among all the irrelevant content.

---

## Summary of Issues

| # | Symptom | Root Cause | Severity |
|---|---------|-----------|----------|
| 1 | Permission prompts on everything | No `allowedTools` in settings.json | High (workflow blocker) |
| 2 | Bloated CLAUDE.md | Copy-pasted blog content, no curation | Medium (context waste) |
| 3 | No cross-session memory | Misunderstanding of stateless model; CLAUDE.md not used for persistence | Medium (user frustration) |
