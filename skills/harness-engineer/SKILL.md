---
name: harness-engineer
description: "The master skill for Claude Code harness engineering. Use this skill whenever someone wants to set up, improve, audit, or maintain their Claude Code harness — including CLAUDE.md, settings.json, hooks, memory, permissions, skills, agent routing, or any aspect of how Claude interacts with their project. Trigger on phrases like 'set up my harness', 'improve my claude config', 'audit my setup', 'add hooks', 'fix my permissions', 'optimize context', 'bootstrap this project for claude', or any request about configuring how Claude works with a codebase. Also trigger when someone is struggling with Claude's behavior in their project — that's usually a harness problem."
---

# Harness Engineer

You are the master router for harness engineering. Your job is to understand what the user needs and dispatch to the right specialist skill(s) — or handle it directly if the request is simple enough.

## The 7 Pillars

Every harness engineering task maps to one or more of these pillars:

1. **Skill Composition** → `harness-skills`
2. **Context Engineering** → `harness-context`
3. **Orchestration & Routing** → `harness-routing`
4. **Persistence & State** → `harness-memory`
5. **Quality Gates & Feedback Loops** → `harness-gates`
6. **Permission & Safety Boundaries** → `harness-permissions`, `harness-hooks`
7. **Ergonomics & Trust Calibration** → `harness-ergonomics`

Plus two cross-cutting workflows:
- **Bootstrap** → `harness-scaffold` (generates initial CLAUDE.md and config)
- **Continuous Improvement** → `harness-audit` (evaluates), `harness-loop` (iterates)

## Routing Logic

### Step 1: Classify the request

Read the user's request and classify their intent:

| Intent | Route to | Examples |
|--------|----------|---------|
| New project setup | `harness-init` | "set up claude for this project", "bootstrap harness", "initialize" |
| Evaluate existing setup | `harness-audit` | "audit my harness", "what's missing", "how good is my setup" |
| Continuous improvement | `harness-loop` | "improve my harness", "iterate", "make it better" |
| CLAUDE.md creation/editing | `harness-scaffold` | "create CLAUDE.md", "rewrite my claude config" |
| Context optimization | `harness-context` | "CLAUDE.md is too long", "optimize context", "what should claude know" |
| Memory system | `harness-memory` | "set up memory", "audit memories", "memory organization" |
| Permissions | `harness-permissions` | "fix permissions", "add allow rules", "too many prompts" |
| Hooks | `harness-hooks` | "add a hook", "auto-format on save", "validate before commit" |
| Skill design | `harness-skills` | "what skills does this project need", "skill decomposition" |
| Agent orchestration | `harness-routing` | "when to use subagents", "parallelize", "build loop design" |
| Quality gates | `harness-gates` | "add quality checks", "auto-test", "catch drift" |
| Interaction tuning | `harness-ergonomics` | "too verbose", "stop asking", "trust calibration" |
| Unclear / broad | Start with `harness-audit` | "help with my harness", "make claude work better" |

### Step 2: Assess scope

- **Single pillar**: Route directly to the atomic skill. Read it and follow its instructions.
- **Multiple pillars**: Route to the appropriate composed skill, or execute atomic skills in sequence.
- **Full bootstrap**: Use `harness-init` which composes multiple atomic skills.
- **Vague request**: Start with `harness-audit` to assess the current state, then recommend next steps.

### Step 3: Execute

When routing to a skill:
1. Read the skill's SKILL.md from `skills/<skill-name>/SKILL.md` (relative to this skill's parent directory)
2. Follow its instructions in the context of the user's specific request
3. After completion, check if the work revealed needs in adjacent pillars
4. Offer to continue with related improvements

When handling multiple skills in sequence:
1. Present the plan to the user: "I'll address X first, then Y"
2. Execute each skill's workflow
3. Validate that changes from one skill don't conflict with another
4. Summarize what was done across all pillars

## Direct Handling

For simple requests that don't need a full skill workflow, handle directly:

- "What hooks do I have?" → Read settings.json and report
- "Show me my permissions" → Read settings.json and list
- "How big is my CLAUDE.md?" → Read and count tokens
- "What's in my memory?" → Read MEMORY.md and summarize

The threshold: if the answer requires analysis, design, or multiple file changes, route to a skill. If it's a quick lookup, just do it.

## Cross-Cutting Concerns

After any harness modification, verify:
- CLAUDE.md and settings.json are consistent (no conflicting instructions)
- New hooks don't conflict with existing ones
- Permission changes match the intent
- Memory index (MEMORY.md) is up to date if memories were modified
- No secrets or credentials were accidentally added to tracked files

## When Things Go Wrong

If a user reports that Claude is behaving badly in their project, that's almost always a harness problem. Diagnose by checking:

1. **Wrong behavior**: Check CLAUDE.md for missing or conflicting instructions → `harness-context`
2. **Too many permission prompts**: Check settings.json allow rules → `harness-permissions`
3. **Forgetting context**: Check memory system → `harness-memory`
4. **Not using skills**: Check skill descriptions and triggers → `harness-skills`
5. **Slow/inefficient**: Check orchestration and context bloat → `harness-routing`, `harness-context`
6. **Inconsistent quality**: Check quality gates → `harness-gates`
