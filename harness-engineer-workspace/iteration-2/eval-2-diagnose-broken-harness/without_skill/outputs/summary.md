# Summary: Claude Code Setup Diagnosis and Fixes

## Three problems, three root causes

| # | Symptom | Root Cause | Fix |
|---|---------|-----------|-----|
| 1 | Asks permission for everything | `allowedTools` not configured in settings.json | Add common tools to `~/.claude/settings.json` permissions allowlist |
| 2 | CLAUDE.md is 2000 lines of blog content | File was stuffed with irrelevant copy-pasted material | Replace with a focused 50-150 line project instruction file |
| 3 | Never remembers between sessions | No clean CLAUDE.md to store preferences; not using `--continue`/`--resume` | Maintain a curated CLAUDE.md; use session resumption features |

## What was produced

- **diagnosis.md** -- Detailed root cause analysis for each of the three symptoms, explaining why each issue occurs and what specifically to check.
- **fixes.md** -- Step-by-step remediation instructions for all three issues, with implementation order recommendations.
- **example-settings.json** -- A ready-to-use settings file with sensible `allowedTools` defaults that eliminate most permission prompts for typical development workflows.
- **example-CLAUDE.md** -- A clean template (~50 lines) demonstrating proper structure: project overview, build commands, code style, architecture map, conventions, and personal preferences. Designed to replace the bloated 2000-line file.

## Key insight

All three problems are interconnected. The bloated CLAUDE.md is the linchpin -- it wastes context tokens (making Claude less effective), buries any real instructions (so preferences are not "remembered"), and the lack of proper settings configuration (which could have been noted in a well-maintained CLAUDE.md) leads to the permission prompting. Fixing the CLAUDE.md addresses two of the three issues directly.

## Quickest path to relief

1. Drop `example-settings.json` into `~/.claude/settings.json` -- permission prompts stop immediately.
2. Back up the old CLAUDE.md, replace it with `example-CLAUDE.md`, customize for the actual project -- bloat eliminated, "memory" restored.
3. Start using `claude --continue` when returning to work -- session context preserved.

Total time to implement: approximately 10-15 minutes.
