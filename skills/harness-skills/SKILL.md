---
name: harness-skills
description: >
  Analyze a project's workflows and decompose them into a well-composed skill
  system — atomic skills, composed workflows, and routing entry points. Use this
  skill whenever someone wants to identify what skills their project needs,
  design skill composition, check for gaps or overlaps in existing skills,
  organize their .claude/commands/ directory, or understand which recurring
  tasks should become skills. Trigger on: "what skills do I need", "decompose
  into skills", "skill analysis", "too many commands", "skills overlap",
  "design my skill system", "which tasks should be skills", or any request
  about organizing automated workflows for a project. Also trigger when
  someone has a bunch of ad-hoc commands and wants to systematize them.
---

# Harness Skills

Analyze a project's workflows and design a skill system that captures them as reusable, composable units. This skill is about figuring out what skills a specific project needs — not about how to write skills in general (that's skill-architect's job).

## Why skill decomposition matters

Without skills, complex workflows live in the user's head. They re-explain the deployment process, re-describe the review checklist, re-walk-through the migration steps every time. Skills capture these workflows so Claude can execute them reliably.

But skills have overhead — each one takes up context for its description, and too many create decision fatigue ("which skill should I use?"). The goal is the minimum set that covers the maximum workflow surface.

## Step 1: Discover Workflows

### Ask the user

The most reliable source of workflow information is the user. Ask:

1. "What are the 3-5 things you do most often in this project with Claude?"
2. "Are there multi-step processes you find yourself explaining repeatedly?"
3. "What's the most annoying thing about working with Claude on this project?"

### Analyze git history

```bash
# What kinds of changes happen most?
git log --oneline -100 | head -30

# What files change together? (indicates workflows)
git log --pretty=format: --name-only -50 | sort | uniq -c | sort -rn | head -20

# Commit message patterns (what verbs recur?)
git log --oneline -100 | grep -oiE '^\w+\s+(add|fix|update|refactor|test|deploy|migrate|release|review)' | sort | uniq -c | sort -rn
```

### Survey existing commands

```bash
# Existing slash commands
ls .claude/commands/ 2>/dev/null

# Existing skills
find . -name "SKILL.md" -not -path "*/node_modules/*" 2>/dev/null
```

### Check for automation gaps

Common workflows that benefit from skills:
- **Deploy**: multi-step deployment process
- **Review**: code review checklist with specific criteria
- **Migrate**: database or schema migration workflow
- **Release**: version bump, changelog, tag, publish
- **Test**: running specific test suites with specific configurations
- **Generate**: scaffolding new components, modules, or features
- **Debug**: systematic debugging workflow for common issue types
- **Document**: generating or updating documentation

## Step 2: Classify Candidates

For each workflow identified, assess whether it should be a skill:

| Question | Yes → Skill | No → Something else |
|----------|------------|-------------------|
| Multi-step? (>3 steps) | Skill | Simple command or CLAUDE.md instruction |
| Recurring? (>1x/week) | Skill | One-off or ad-hoc |
| Needs context? (domain knowledge) | Skill | Generic enough for base Claude |
| Benefits from structure? | Skill | Free-form is fine |
| Others would use it? | Shared skill | Personal command |

### Skill vs. command vs. CLAUDE.md

| Artifact | Use when |
|----------|---------|
| **Skill** | Complex workflow, needs structure, may compose with others |
| **Command** (`.claude/commands/`) | Simple prompt template, 1-2 steps, personal workflow |
| **CLAUDE.md instruction** | Always-relevant rule ("use spaces not tabs") |

## Step 3: Design the Skill Map

### Atomic skills

Identify the smallest useful units — skills that do one thing well:
- Each has a clear trigger (when does a user need this?)
- Each has bounded scope (what's in and what's out?)
- Each produces a defined output (what does "done" look like?)

### Composed skills

Identify workflows that chain atomic skills:
- Deploy = build → test → push → verify
- Release = bump version → update changelog → tag → deploy
- Onboard = scaffold → permissions → memory → hooks

### Entry points

If there are many skills, consider a router skill that dispatches:
- User says vague thing → router figures out which skill(s) to invoke
- Prevents the user from needing to know all skill names

### Skill map template

```
Project: [name]

Atomic Skills:
  [skill-1] — [what it does] — triggers on [phrases]
  [skill-2] — [what it does] — triggers on [phrases]
  [skill-3] — [what it does] — triggers on [phrases]

Composed Workflows:
  [workflow-1] = [skill-1] → [skill-2] → [skill-3]
  [workflow-2] = [skill-2] → [skill-4]

Entry Points:
  [router] — dispatches to all of the above
```

Present this map to the user for validation before building anything.

## Step 4: Check for Problems

### Overlap detection

Two skills overlap when a user prompt could reasonably trigger either one. For each pair:
- Are the descriptions distinct enough?
- Would a user know which to use?
- Should they be merged or should the boundary be clarified?

### Gap detection

For each common workflow pattern (deploy, test, review, etc.):
- Is there a skill covering this?
- Would having one save meaningful time?
- Is the gap felt daily or rarely?

### Trigger quality

For each skill:
- Is the description specific enough to trigger on relevant prompts?
- Is it broad enough to not miss valid triggers?
- Does it clash with other skill descriptions?

Common trigger problems:
- **Too narrow**: "Use when the user says 'deploy to staging'" — misses "push to staging", "ship it", etc.
- **Too broad**: "Use for any code-related task" — triggers on everything, adds noise.
- **Keyword collision**: Two skills both mention "test" — which triggers?

## Step 5: Recommend and Build

Present recommendations in priority order:

1. **Must-have** — Skills for daily workflows that currently require re-explanation
2. **Nice-to-have** — Skills for weekly workflows or quality-of-life improvements
3. **Later** — Skills for rare workflows or future needs

For each recommended skill, provide:
- Name and description
- What it does (3-5 bullet points)
- What triggers it
- Whether it's atomic or composed
- Estimated complexity (simple command vs. full SKILL.md)

Offer to build the top 1-2 skills immediately, with the rest as follow-up.

## Maintenance

Skills need occasional maintenance:
- **Trigger tuning**: If a skill never fires, its description needs work
- **Scope creep**: If a skill keeps growing, split it
- **Staleness**: If the workflow changed, update the skill
- **Redundancy**: If two skills converged, merge them

Recommend a quarterly skill review using `harness-audit`.
