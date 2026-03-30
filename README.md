[Documentation Website](https://lsdippollc.github.io/harness-eng-skills)

# Harness

A configuration-as-code framework that transforms Claude Code from a stateless tool into an intelligent, context-aware collaborator — for any project.

## Why Harness?

Claude Code is powerful out of the box, but without deliberate configuration it starts every session from scratch: no knowledge of your conventions, no memory of past decisions, no guardrails against destructive actions, and no tailored workflows for your stack. The result is repetitive prompting, inconsistent behavior, and missed potential.

Harness exists to close that gap. It provides a structured, composable system for configuring every aspect of how Claude Code interacts with your codebase — from what context it loads, to what it's allowed to do autonomously, to how it remembers decisions across sessions. The goal is to make Claude Code *yours*: an assistant that understands your project's architecture, respects your team's conventions, and improves over time.

This matters because the difference between a well-configured AI assistant and a default one compounds with every interaction. Teams that invest in configuration spend less time correcting, more time building, and get dramatically more consistent results.

## What Harness Does

Harness organizes all Claude Code configuration around **7 foundational pillars**:

| Pillar | Concern | Key Question |
|--------|---------|--------------|
| **Skill Composition** | What atomic skills and workflows the project needs | *What should Claude be able to do?* |
| **Context Engineering** | What information Claude loads and when | *What does Claude need to know?* |
| **Orchestration & Routing** | How tasks route to specialist agents | *How should work be distributed?* |
| **Persistence & State** | Cross-session memory and knowledge | *What should Claude remember?* |
| **Quality Gates** | Automated validation and feedback loops | *How do we catch mistakes early?* |
| **Permissions & Safety** | Autonomous vs. confirmed actions | *What can Claude do without asking?* |
| **Ergonomics & Trust** | Interaction style and autonomy calibration | *How should Claude communicate?* |

Each pillar is implemented by one or more of **13 atomic skills** that can be composed, audited, and improved independently.

## The Skill System

### Core Skills

| Skill | Purpose |
|-------|---------|
| `harness-engineer` | Master router — dispatches to the right atomic skill based on what you need |
| `harness-init` | Bootstrap a complete harness from scratch by orchestrating multiple skills in sequence |
| `harness-audit` | Evaluate an existing harness against all 7 pillars, score maturity (0–21), recommend improvements |
| `harness-loop` | Continuous improvement cycle: audit, identify the weakest pillar, improve it, validate, repeat |

### Atomic Skills

| Skill | Pillar | What It Does |
|-------|--------|--------------|
| `harness-scaffold` | Context | Analyze a project and generate a tailored CLAUDE.md and `.claude/` directory structure |
| `harness-context` | Context | Optimize context budget — what Claude loads, when, and how much |
| `harness-memory` | Persistence | Design and set up the cross-session memory system |
| `harness-permissions` | Safety | Configure permission boundaries for your project's tools and workflows |
| `harness-hooks` | Quality Gates | Implement automated behaviors — format-on-save, lint-on-edit, secret scanning |
| `harness-skills` | Skill Composition | Analyze project workflows and decompose them into reusable skills |
| `harness-routing` | Orchestration | Design agent orchestration, parallelization, and worktree isolation |
| `harness-gates` | Quality Gates | Create validation gates and feedback loops (pre-commit checks, drift detection) |
| `harness-ergonomics` | Ergonomics | Tune verbosity, autonomy level, error communication style |

## How It Works

### Bootstrap a new project

Call `harness-engineer` with "set up Claude for this project" and it orchestrates:

1. **Scaffold** — Analyze the project and generate CLAUDE.md + settings
2. **Permissions** — Configure what Claude can do autonomously
3. **Memory** — Set up persistent cross-session knowledge
4. **Hooks** — Install automated quality gates (formatting, linting, secret scanning)
5. **Context** — Optimize what gets loaded into Claude's context window

### Audit an existing setup

Call `harness-audit` to score your current configuration across all 7 pillars (each scored 0–3). Get a structured report with your top improvement opportunities and direct routing to the skill that fixes each one.

### Continuously improve

Call `harness-loop` to run iterative improvement cycles. Each iteration finds the weakest pillar, routes to the appropriate skill to strengthen it, validates the change, and asks if you want to continue.

## Project Structure

```
harness/
├── skills/                    # The 13 atomic skills
│   ├── harness-engineer/      # Master router
│   ├── harness-init/          # Bootstrap orchestrator
│   ├── harness-scaffold/      # CLAUDE.md generator
│   ├── harness-context/       # Context optimization
│   ├── harness-memory/        # Memory system design
│   ├── harness-permissions/   # Permission configuration
│   ├── harness-hooks/         # Hook implementation
│   ├── harness-skills/        # Skill decomposition
│   ├── harness-routing/       # Agent orchestration
│   ├── harness-gates/         # Quality gates
│   ├── harness-audit/         # Harness evaluation
│   ├── harness-loop/          # Continuous improvement
│   └── harness-ergonomics/    # Interaction tuning
├── hooks/                     # Reusable hook scripts
│   ├── harness-validate.sh    # PostToolUse validation hook
│   ├── harness-drift.sh       # End-of-session health checks
│   └── settings-example.json  # Hook configuration example
└── evals/                     # Evaluation test cases
    └── evals.json             # Scenarios and assertions
```

Each skill directory contains a `SKILL.md` with complete methodology, step-by-step workflows, and practical examples.

## Key Concepts

### CLAUDE.md
The primary configuration file Claude Code reads at the start of every session. Harness generates and optimizes these files to be concise (100–300 lines), front-loaded with the most critical information, and tailored to your specific stack and conventions.

### Hooks
Shell scripts that execute automatically in response to Claude's actions. Harness uses them for quality control — formatting code after edits, scanning for secrets before writes, blocking dangerous commands, and running drift detection at session end.

### Memory System
A structured, file-based knowledge store (`.claude/memory/`) that persists across conversations. Organized by type — user preferences, project context, feedback corrections, and external references. Curated, not accumulated: only stores what can't be discovered at runtime.

### Maturity Scoring
The audit system scores each of the 7 pillars from 0 (not configured) to 3 (advanced), giving a total maturity score out of 21. This provides a clear picture of where your harness is strong and where it needs work.

## Getting Started

1. Install the skills from `skills/` into your Claude Code configuration
2. Run `harness-engineer` and describe what you need — it routes to the right skill
3. For a fresh project, start with `harness-init` to bootstrap everything
4. For an existing setup, start with `harness-audit` to see where you stand
5. Use `harness-loop` to iteratively improve over time
