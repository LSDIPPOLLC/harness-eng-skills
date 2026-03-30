---
name: harness-memory
description: >
  Design, set up, audit, and maintain a project's Claude Code memory system.
  Use this skill whenever someone needs to create a memory structure, organize
  existing memories, audit for staleness or gaps, understand what should be a
  memory vs. CLAUDE.md vs. a task, or fix broken memory indexing. Trigger on:
  "set up memory", "organize memories", "audit my memories", "memory system",
  "claude keeps forgetting", "remember across sessions", "MEMORY.md", or any
  request about persistent cross-session state. Also trigger when someone says
  "I already told you this" — that's a missing memory.
---

# Harness Memory

Design and maintain the memory system that lets Claude retain knowledge across conversations. Memory is what transforms Claude from a stateless tool into a collaborative partner that learns your project over time.

## Why memory matters

Without memory, every conversation starts from zero. The user re-explains their role, re-corrects the same mistakes, re-describes external systems. Memory captures what's been learned so future sessions start where the last one left off.

But memory has costs: stale memories teach Claude wrong things, too many memories bloat context, and poorly organized memories are never found. A good memory system is curated, not accumulated.

## Memory Types

| Type | What it stores | Example |
|------|---------------|---------|
| **user** | Who the user is, their role, preferences, expertise | "Senior backend engineer, prefers terse output" |
| **feedback** | Corrections AND confirmations of approach | "Don't mock the DB in integration tests — use real DB" |
| **project** | Ongoing work, decisions, status, deadlines | "Auth rewrite driven by compliance, not tech debt" |
| **reference** | Pointers to external systems and resources | "Pipeline bugs tracked in Linear project INGEST" |

## Step 1: Check Current State

Look for existing memory infrastructure:

```
# Project-level memory
.claude/memory/
  MEMORY.md          # Index file
  *.md               # Individual memory files

# User-level memory (shared across projects)
~/.claude/projects/<project-hash>/memory/
  MEMORY.md
  *.md
```

If memory exists, audit it. If not, create the structure.

## Step 2: Create Memory Structure

### Directory and index

Create the memory directory and MEMORY.md index:

```bash
mkdir -p .claude/memory
```

MEMORY.md format — this is an index, not content:
```markdown
# Memory Index

## User
- [User Role](user_role.md) — Senior backend eng, prefers concise output

## Feedback
- [Testing Approach](feedback_testing.md) — Use real DB, never mock in integration tests

## Project
- [Auth Rewrite](project_auth_rewrite.md) — Compliance-driven, deadline March 2026

## References
- [Bug Tracker](reference_bug_tracker.md) — Linear project INGEST for pipeline bugs
```

Rules for MEMORY.md:
- One line per memory, under 150 characters
- Organized by type, not chronologically
- No content in the index — just pointers and one-line hooks
- Keep under 200 lines (truncated after that)

### Memory file format

Each memory is a separate .md file with frontmatter:

```markdown
---
name: descriptive-name
description: One-line description used to decide relevance in future conversations
type: user|feedback|project|reference
---

Content here. For feedback and project types, structure as:

Rule or fact statement.

**Why:** The reason behind it.

**How to apply:** When and where this guidance kicks in.
```

### Naming conventions

- Prefix with type: `user_role.md`, `feedback_testing.md`, `project_auth.md`, `reference_linear.md`
- Use descriptive names, not dates: `feedback_db_mocking.md` not `feedback_2026-03-15.md`
- Keep names short but specific enough to distinguish

## Step 3: Seed Initial Memories

For a new project, create seed memories based on what you learn during scaffolding:

**Always worth seeding:**
- `user_role.md` — Who is the user, what's their expertise level
- `reference_*` — Any external systems mentioned (issue tracker, docs, deployment)

**Seed if discovered:**
- `project_*` — Any active initiatives, deadlines, or decisions
- `feedback_*` — Any stated preferences about how to work

**Don't seed speculatively.** Only create memories for things you have evidence of. Empty or vague memories waste index space.

## Step 4: Audit Existing Memories

If memories already exist, check each one:

### Quality checklist

For each memory file:
- [ ] Has complete frontmatter (name, description, type)
- [ ] Description is specific enough to judge relevance
- [ ] Content is still accurate (not stale)
- [ ] Not duplicated by another memory
- [ ] Belongs in memory (not in CLAUDE.md or code)

### Common problems

| Problem | Fix |
|---------|-----|
| Missing frontmatter | Add name, description, type |
| Vague description | Rewrite to be specific: "user preference" → "prefers single PR for refactors, confirmed 2026-03" |
| Stale content | Update or delete — stale memories are worse than no memories |
| Duplicate memories | Merge into one, delete the other, update index |
| Code patterns stored as memory | Delete — these belong in CLAUDE.md or should be discovered from code |
| Architecture docs as memory | Delete — read the code or put in CLAUDE.md |
| Conversation-specific notes | Delete — these should be tasks, not memories |

### Index sync check

Verify MEMORY.md matches actual files:
```bash
# Memory files that exist
find .claude/memory -name "*.md" ! -name "MEMORY.md" | sort

# Compare against entries in MEMORY.md
grep -oP '\(([^)]+\.md)\)' .claude/memory/MEMORY.md | tr -d '()' | sort
```

Fix any mismatches — orphaned files or broken links.

## What Belongs Where

This is the most common source of confusion. Use this decision tree:

| Information | Where it goes | Why |
|------------|--------------|-----|
| Build commands, code style | CLAUDE.md | Needed every session |
| User's role, expertise | Memory (user) | Relevant but not always |
| "Don't do X" corrections | Memory (feedback) | Must persist, not always relevant |
| Active sprint/deadline | Memory (project) | Time-bound, cross-session |
| External system URLs | Memory (reference) | Rarely needed, easy to forget |
| Current task steps | Tasks (in-conversation) | Session-scoped, not durable |
| Implementation approach | Plan (in-conversation) | Session-scoped, may change |
| File paths, function names | Nothing — discover at runtime | Changes too fast for memory |
| Git history, recent changes | Nothing — use git log | Git is authoritative |
| Debugging solutions | Nothing — it's in the code | The fix is the documentation |

## Step 5: Set Up Memory Hygiene

### Lifecycle rules

Recommend these practices to the user:

1. **Create on discovery**: When you learn something non-obvious about the user, project, or workflow, save it immediately.
2. **Update on change**: When a memory becomes partially wrong, update it — don't create a new one.
3. **Delete on completion**: Project memories for completed initiatives should be retired.
4. **Review monthly**: Skim MEMORY.md once a month and remove anything stale.

### Automated checks

The `harness-drift` hook checks for memory/index sync at conversation end. Recommend enabling it.

For projects with active memory usage, suggest a periodic audit: "Every few weeks, run harness-memory to check for staleness and gaps."

## Anti-patterns

- **Hoarding**: Saving everything "just in case." Memories have a cost — each one takes up index space and may be loaded unnecessarily.
- **Journaling**: Using memories as a changelog. "March 15: fixed the auth bug" is not a memory — it's git history.
- **Duplicating CLAUDE.md**: If it's in CLAUDE.md, don't also put it in memory. One source of truth.
- **Storing code**: Memory is for human context, not code patterns. Code belongs in the codebase.
- **Relative dates**: "Next Thursday" becomes meaningless in a future session. Always use absolute dates.
