---
name: harness-routing
description: >
  ALWAYS use this skill when designing agent orchestration, routing, parallelization,
  subagent delegation, build-loop workflows, worktree isolation, or multi-agent
  coordination strategies. Use for ANY question about when to parallelize vs serialize,
  how to route tasks to specialist agents, how to structure phase-based execution loops,
  or how to isolate risky operations. Covers handoff patterns, background agents,
  mega-skill dispatch, and error recovery routing.
---

# Agent Orchestration and Routing Design

Design concrete orchestration strategies for a specific project. Analyze its actual
workflows, codebase structure, and task patterns. Recommend specific routing,
parallelization, and delegation strategies with justification.

Do not produce generic theory. Produce actionable orchestration plans tied to the
project's real constraints.

## Core Decision: Subagent vs. Inline

### Use a subagent when

- The task is **self-contained**: it has clear inputs, clear outputs, and does not need
  to modify shared state mid-execution. Subagents cannot coordinate with each other
  during execution, so tasks that require real-time collaboration stay inline.
- The task is **expensive but independent**: large codebase searches, test suite runs,
  multi-file analysis. Pushing these to subagents frees the orchestrator to continue
  planning or handle other work.
- The task is **risky**: experimental refactors, speculative changes, or anything that
  might corrupt working state. Subagents combined with worktree isolation contain the
  blast radius.
- The task requires a **different specialist mindset**: deep code review vs. architecture
  planning vs. test generation. Context-switching is expensive for a single agent;
  delegation is cheap.

### Keep inline when

- The task is **trivial**: a single file edit, a quick lookup, a one-line fix. Subagent
  overhead (spawn, context transfer, result collection) exceeds the task cost.
- The task requires **tight iteration with the user**: clarification loops, interactive
  refinement, decisions that depend on user preference. Subagents cannot ask follow-up
  questions.
- The task **mutates state that later steps depend on**: if step 2 reads what step 1
  wrote, and step 3 reads what step 2 wrote, serialize these inline. Subagent
  coordination across shared state is fragile and error-prone.

## Parallelization Strategy

### Parallelize these

- **Independent research queries**: "find all usages of X" + "find the config for Y" +
  "read the test file for Z". These touch different parts of the codebase and produce
  independent results. Fire all simultaneously.
- **Test runs across modules**: if the project has independent test suites (unit, integration,
  e2e), run them in parallel subagents. Each subagent reports pass/fail and relevant
  failures.
- **Multi-file analysis**: analyzing 5 files for the same pattern, reviewing 3 PRs,
  checking 4 config files for consistency. Each analysis is independent.
- **Exploration + planning**: one subagent explores the codebase to gather facts while
  another drafts an initial plan based on known information. Merge results afterward.
- **Lint + test + type-check**: these are independent validation steps. Run all three
  concurrently after a change.

### Serialize these

- **State-changing sequences**: create branch → make changes → commit → push. Each step
  depends on the previous step's success and side effects.
- **Dependent analysis**: "find the entry point" → "trace the call chain from the entry
  point" → "identify the bug in the call chain". Each step's output is the next step's
  input.
- **User-facing decisions**: present option A vs. B → get user input → execute chosen
  option. Cannot parallelize across a decision boundary.
- **File modifications to the same file**: two agents editing the same file will conflict.
  Serialize or partition by file.
- **Database/API mutations**: operations with side effects that could conflict or produce
  inconsistent state.

### The merge problem

Parallel subagents produce independent results that must be merged. Design the merge
point before launching subagents:

- **Research merges** are easy: concatenate findings, deduplicate, summarize.
- **Code change merges** are hard: if two subagents edit different files, merge is
  straightforward. If they might touch the same file, serialize instead.
- **Decision merges** require judgment: if two subagents produce conflicting
  recommendations, the orchestrator must resolve the conflict. Build this resolution
  logic into the orchestrator's post-merge step.

## Subagent Types and Strengths

### Explore agents (fast, focused)

Use for: codebase search, pattern finding, file discovery, dependency tracing.

These agents are fast because they carry minimal context and have a narrow mission.
Give them a specific question: "Find all files that import module X and list how they
use it." Do not give them broad mandates.

Strengths: speed, low cost, can fire many in parallel.
Weaknesses: no deep reasoning, no cross-file synthesis, no modifications.

### Plan agents (architecture, strategy)

Use for: designing implementation approaches, breaking down large tasks, identifying
risks, reviewing architecture decisions.

Give them the full context of the problem and ask for a structured plan. Their output
is a plan document, not code.

Strengths: deep reasoning, holistic view, risk identification.
Weaknesses: slow, expensive, output needs validation before execution.

### General-purpose agents (complex tasks)

Use for: implement a feature, fix a bug, write tests, refactor a module. These agents
do real work: they read code, write code, run tests, and iterate.

Give them a clear scope, specific acceptance criteria, and relevant file paths. The
more precise the brief, the better the output.

Strengths: can handle multi-step tasks, iterate on failures, produce working code.
Weaknesses: expensive, can go off-track without clear constraints, need result validation.

### Validation agents (quality gates)

Use for: reviewing another agent's output, running tests against changes, checking
for regressions, verifying style compliance.

These agents receive another agent's output and judge it. They do not create; they
evaluate. Keep them separate from creation agents to avoid self-review bias.

Strengths: independent judgment, can catch errors creators miss.
Weaknesses: need clear criteria to evaluate against, can be overly conservative.

## Build-Loop Pattern

The build loop is the core orchestration pattern for large, multi-phase tasks. It
turns a big task into a sequence of small, validated steps.

### Structure

```
1. Assess current state (what's done, what's next)
2. Pick the next phase from the plan
3. Route to the appropriate specialist agent
4. Collect the specialist's output
5. Validate the output (tests pass, requirements met, no regressions)
6. Log progress (what was done, what changed, any issues)
7. Update the plan if needed (new information may change priorities)
8. Repeat from step 1 until all phases complete
```

### Why this works

- **Incremental validation**: catching errors after each phase is cheaper than catching
  them after all phases. A bug in phase 2 is cheap to fix before phase 3 builds on it.
- **Adaptive planning**: the plan can change based on what the specialist discovers.
  Real codebases have surprises; rigid plans break.
- **Clear progress tracking**: the log shows exactly what was done and when. If something
  goes wrong, you can trace back to the phase that introduced the problem.
- **Resumability**: if the loop is interrupted, the log tells you where to resume. No
  work is lost.

### Phase design principles

- Each phase should produce a **testable artifact**: a file, a passing test, a config
  change that can be verified. Phases that produce "understanding" are exploration
  phases, not build phases.
- Phases should be **ordered by dependency**: build the foundation before the features,
  the features before the tests, the tests before the polish.
- Keep phases **small enough to validate**: a phase that changes 20 files is hard to
  validate. A phase that changes 3 files is easy to validate.
- Design **rollback points**: if phase 4 fails validation, can you revert to the state
  after phase 3? Structure phases so this is possible.

### Progress logging

Log each phase completion with:
- Phase name and description
- Files created or modified
- Tests run and their results
- Issues encountered and how they were resolved
- Time elapsed (for future estimation)

Store the log in a predictable location (e.g., `PROGRESS.md` or a structured log file).
The orchestrator reads this log on each iteration to understand current state.

## Worktree Isolation

Git worktrees let you check out a branch in a separate directory while keeping your
main working directory clean. Use them to isolate risky agent operations.

### Use worktrees when

- **Experimental changes**: the agent is trying an approach that might not work. If it
  fails, discard the worktree. No cleanup needed in the main tree.
- **Parallel branches**: two agents need to work on different branches simultaneously.
  Each gets its own worktree, no branch-switching conflicts.
- **Risky refactors**: large-scale changes that might break the build. The agent works
  in a worktree, runs tests there, and only merges to main if everything passes.
- **Long-running tasks**: a subagent working on a multi-hour task should not block the
  main worktree. Give it its own worktree and let the user continue working.

### Do not use worktrees when

- **Simple edits**: editing one file, adding a test, fixing a typo. The overhead of
  creating and merging a worktree exceeds the risk of the change.
- **Already on a feature branch**: if you are already isolated on a feature branch, a
  worktree adds unnecessary complexity.
- **Shared state dependencies**: if the agent needs to read files that another agent is
  actively modifying, worktrees create stale-read problems. Serialize instead.

### Worktree lifecycle

```
1. Create worktree on a new branch from the current HEAD
2. Agent performs all work in the worktree directory
3. Agent runs validation (tests, lint, type-check) in the worktree
4. If validation passes: merge branch back to main, delete worktree
5. If validation fails: log the failure, delete worktree, report to orchestrator
```

Always clean up worktrees after use. Abandoned worktrees accumulate and confuse
future operations.

## Background Agents

### Fire-and-forget

Use when: the result is logged but not needed by the orchestrator's next step.
Examples: updating documentation after a code change, running a slow lint pass,
generating a coverage report.

Pattern: launch the agent, do not wait for it, check results later or never.

Why: frees the orchestrator to continue without blocking on low-priority work.

### Results-needed

Use when: the orchestrator needs the result before proceeding, but can do other work
while waiting. Examples: running tests (need to know pass/fail before merging),
exploring a codebase section (need the findings before planning).

Pattern: launch the agent, continue with other independent work, collect results
at a synchronization point before the step that needs them.

Why: maximizes throughput by overlapping independent work with the background task.

### Choosing between them

Ask: "Does any future step in this workflow depend on this agent's output?"

- Yes → results-needed. Define the sync point where you will collect results.
- No → fire-and-forget. Log that you launched it for traceability.

## Routing Logic for Mega-Skills

Mega-skills are dispatchers: they receive a broad request and route it to the right
specialist skill. Design routing logic that is fast, accurate, and maintainable.

### Keyword matching (fast, brittle)

Match specific words or phrases in the request to specialist skills.

```
"test" → test-writer skill
"refactor" → refactor skill
"document" → documentation skill
"deploy" → deployment skill
```

Why it works: fast, zero-cost, handles the common case.
Why it breaks: ambiguous requests ("test the deployment refactor") match multiple
skills. Use as a first pass, not the only pass.

### Intent classification (slower, robust)

Analyze the full request to determine intent, then route.

Consider the primary action the user wants:
- Creating something new → route to builder
- Fixing something broken → route to debugger
- Understanding something → route to explorer
- Changing something existing → route to refactorer
- Validating something → route to tester

Why: handles ambiguity better than keyword matching. "Test the deployment refactor"
→ primary intent is "validate", route to tester with context about deployment and
refactoring.

### Context-based dispatch

Use the current project state to influence routing:
- If tests are failing → prioritize the debugger
- If on a feature branch with many uncommitted changes → prioritize the committer
- If the user just finished a refactor → suggest the tester
- If the codebase has no tests for a module → suggest the test-writer

Why: proactive routing catches tasks the user might forget. The mega-skill becomes
an intelligent assistant, not just a dispatcher.

### Multi-skill routing

Some requests require multiple specialists in sequence:
1. Explore (understand the current code)
2. Plan (design the change)
3. Implement (make the change)
4. Test (validate the change)
5. Document (update docs)

The mega-skill orchestrates this pipeline, passing context between specialists.
Each specialist's output becomes the next specialist's input.

### Fallback routing

When no specialist matches:
1. Ask the user to clarify (preferred when the user is interactive)
2. Route to a general-purpose agent (when the user expects autonomous operation)
3. Log the unrouted request for future skill development (always, regardless of
   which fallback is chosen)

Why: unrouted requests reveal gaps in your skill coverage. Track them to know what
specialists to build next.

## Error Handling and Recovery

### Agent failure modes

- **Agent produces wrong output**: validation catches this. Re-route to the same
  specialist with more specific instructions, or try a different specialist.
- **Agent times out**: kill it, log what it was doing, retry with a simpler scope.
  Large tasks that time out should be decomposed into smaller phases.
- **Agent corrupts state**: this is why worktree isolation exists. If the agent was
  in a worktree, discard it. If not, use git to revert.
- **Agent goes off-track**: the agent produces valid output, but for the wrong task.
  This is a routing failure. Improve the task brief with more constraints and re-route.

### Retry strategy

- **First retry**: same specialist, more specific instructions. Add constraints based
  on what went wrong.
- **Second retry**: different specialist or different approach. If the refactorer
  failed, try the debugger's perspective.
- **Third failure**: escalate to the user. Three failures indicate a fundamental
  misunderstanding that requires human judgment.

Why three: one failure is noise, two is a pattern, three is a signal. More retries
waste resources on a problem that needs human input.

### Cascading failure prevention

When one phase fails in a build loop:
1. Stop the loop. Do not continue to the next phase.
2. Validate all previous phases still pass. The failure might have revealed a
   latent issue in an earlier phase.
3. Fix the failure before continuing. Do not accumulate failures.
4. If the fix changes the plan, update the plan before resuming.

Why: cascading failures are exponentially harder to debug. Each phase that runs on
top of a broken foundation adds complexity to the eventual fix.

## Applying to a Specific Project

When designing orchestration for a project, follow this analysis sequence:

1. **Map the task types**: what kinds of work does this project require? Feature
   development, bug fixes, test writing, documentation, deployment, refactoring?
   Each task type gets its own routing entry.

2. **Identify natural parallelism**: which tasks are independent? Which files are
   rarely edited together? Which test suites are independent? These are your
   parallelization opportunities.

3. **Find the serialization constraints**: which tasks have dependencies? Which
   files are often edited together? Where do race conditions lurk? These are your
   serialization requirements.

4. **Design the build loop phases** for the most common task type. Break it into
   5-10 phases, each producing a testable artifact. This becomes your default
   workflow.

5. **Identify high-risk operations**: what changes could break the build, corrupt
   data, or cause outages? These get worktree isolation.

6. **Build the routing table**: map task descriptions to specialist agents. Start
   with keyword matching, add intent classification for ambiguous cases.

7. **Define validation criteria** for each phase and each specialist. What does
   "success" look like? How do you test it automatically?

8. **Design the progress log format**: what information does the orchestrator need
   to resume after interruption? Log that and nothing more.

Produce a concrete orchestration document for the project, not a generic framework.
Name specific files, modules, test suites, and workflows. The document should be
executable by an agent without further interpretation.
