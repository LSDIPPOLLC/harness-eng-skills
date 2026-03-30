---
name: harness-init
description: "Bootstrap a complete Claude Code harness for a project from scratch. Use this skill whenever someone wants to initialize, set up, or bootstrap their project for Claude Code — including creating CLAUDE.md, configuring settings.json, setting up memory, permissions, and hooks. Trigger on 'set up claude', 'initialize harness', 'bootstrap this project', 'create CLAUDE.md', 'configure claude for this repo', or any request to get a project ready for productive Claude Code usage. Also trigger when someone opens a new project and says something like 'help me get started' or 'how should I set this up'."
---

# Harness Init

This is a composed skill that orchestrates a full project bootstrap by running multiple atomic skills in the right order. The goal is to take a bare project and produce a complete, tailored harness in one pass.

## Bootstrap Sequence

Execute these phases in order. Each phase uses an atomic skill — read its SKILL.md and follow its instructions in the context of this bootstrap.

### Phase 1: Scaffold (required)

**Skill**: `harness-scaffold`

This is the foundation. Analyze the project and generate:
- CLAUDE.md with project-specific conventions
- .claude/ directory structure
- Initial settings.json

Present the generated CLAUDE.md to the user for review before proceeding. This is the most important artifact — get it right.

### Phase 2: Permissions (required)

**Skill**: `harness-permissions`

Based on the detected tech stack from Phase 1:
- Configure permission allowlists in settings.json
- Set up MCP server permissions if relevant
- Apply the principle: auto-allow reads and local builds, prompt for shared-state mutations

### Phase 3: Memory (recommended)

**Skill**: `harness-memory`

Set up the persistence layer:
- Create memory directory structure
- Initialize MEMORY.md index
- Seed with any project context discovered during scaffolding (tech decisions, key contacts, external systems)

Ask the user if they want to set up memory. Some projects are simple enough to not need it.

### Phase 4: Hooks (optional)

**Skill**: `harness-hooks`

Based on the project's tooling, recommend and create hooks:
- Auto-format on save (if formatter detected)
- Lint on edit (if linter detected)
- Test on change (if test framework detected)

Present recommendations and let the user choose which hooks to install.

### Phase 5: Context Review (recommended)

**Skill**: `harness-context`

Final pass to validate the context budget:
- Is CLAUDE.md a reasonable size?
- Is anything in CLAUDE.md that should be a command or memory instead?
- Are the most important instructions front-loaded?

## Completion Checklist

After all phases, present a summary:

```
Harness Bootstrap Complete
─────────────────────────
✓ CLAUDE.md created (N lines)
✓ settings.json configured (N permissions)
✓ Memory system initialized (N seed memories)
✓ Hooks installed: [list]
✓ Context budget: ~N tokens

Recommended next steps:
- Run `harness-audit` after a few sessions to identify gaps
- Add feedback memories as you discover preferences
- Consider setting up quality gates with `harness-gates`
```

## Adapting to Existing Harnesses

If the project already has some harness files:
- Don't overwrite existing CLAUDE.md — merge or offer to rewrite
- Don't duplicate existing permissions — augment
- Don't create memory structure if one exists — audit it instead
- Skip phases that are already well-covered

In this case, consider suggesting `harness-audit` instead, which is designed for evaluating and improving existing harnesses.
