---
name: harness-gates
description: Design quality gates, validation hooks, feedback loops, and self-evaluation patterns for any harness. Use this skill whenever you need to add automated checks, catch drift, prevent regressions, set up pre-commit or post-edit validation, create self-evaluation workflows, build feedback loops that improve a system over time, or wire quality enforcement into a development workflow. Activate this for any request involving code review automation, test-on-change hooks, harness health checks, breaking change detection, or continuous quality improvement.
---

# Harness Gates

Design quality gates and feedback loops that catch problems early and improve the harness over time.

## Why gates matter

Without gates, drift compounds silently. A small schema mismatch today becomes a broken workflow next week. A forgotten lint rule becomes 200 files of inconsistent style. Gates make the cost of mistakes immediate and local instead of delayed and systemic.

The goal is not perfection. The goal is fast feedback. Catch the issue in seconds, not hours.

## Types of quality gates

### Pre-commit gates

Run these before every commit. They must be fast (under 10 seconds) or developers will bypass them.

**What to check:**
- Lint changed files only (not the whole repo)
- Type-check affected modules
- Run tests for changed files and their direct dependents
- Validate that committed files match expected patterns (no secrets, no large binaries)

**How to implement:**

Create a `.hooks/pre-commit` script or configure through the project's hook system:

```bash
#!/usr/bin/env bash
set -euo pipefail

# Lint only staged files
STAGED=$(git diff --cached --name-only --diff-filter=ACM)

# Filter to relevant file types
JS_FILES=$(echo "$STAGED" | grep -E '\.(js|ts|tsx)$' || true)
PY_FILES=$(echo "$STAGED" | grep -E '\.py$' || true)

if [ -n "$JS_FILES" ]; then
  echo "$JS_FILES" | xargs eslint --fix
  echo "$JS_FILES" | xargs prettier --check
fi

if [ -n "$PY_FILES" ]; then
  echo "$PY_FILES" | xargs ruff check
  echo "$PY_FILES" | xargs ruff format --check
fi

# Block secrets
if echo "$STAGED" | xargs grep -lE '(AKIA|sk-|ghp_|password\s*=)' 2>/dev/null; then
  echo "ERROR: Potential secret detected in staged files"
  exit 1
fi
```

**Why lint only changed files:** Full-repo linting punishes developers for pre-existing issues they did not introduce. Scope gates to the developer's actual changes. Fix the rest in a dedicated cleanup pass.

### Post-edit gates

Run these after every file edit during an AI-assisted session. They validate that the edit did not break local invariants.

**What to check:**
- Format the edited file
- Validate schema files against their spec (JSON Schema, OpenAPI, etc.)
- Check for common security issues (eval, innerHTML, SQL concatenation)
- Verify import/export consistency

**How to implement:**

Create a post-edit hook that the harness calls after each file write:

```bash
#!/usr/bin/env bash
set -euo pipefail

FILE="$1"
EXT="${FILE##*.}"

case "$EXT" in
  json)
    python3 -m json.tool "$FILE" > /dev/null || { echo "Invalid JSON: $FILE"; exit 1; }
    ;;
  yaml|yml)
    python3 -c "import yaml; yaml.safe_load(open('$FILE'))" || { echo "Invalid YAML: $FILE"; exit 1; }
    ;;
  ts|tsx|js|jsx)
    npx prettier --write "$FILE" 2>/dev/null
    ;;
  py)
    ruff format "$FILE" 2>/dev/null
    ruff check --fix "$FILE" 2>/dev/null
    ;;
esac
```

**Why post-edit and not just pre-commit:** Pre-commit catches issues at the end. Post-edit catches them immediately. When an AI agent makes 15 edits in a row, you want each edit validated, not a pile of errors at commit time.

### Pre-push gates

Run these before pushing to remote. They can be slower (up to 2 minutes) because they run less frequently.

**What to check:**
- Full test suite
- Build verification (does the project compile/bundle?)
- License compliance scan
- Documentation generation (verify docs build without errors)
- Dependency audit (known vulnerabilities)

**How to implement:**

```bash
#!/usr/bin/env bash
set -euo pipefail

echo "Running full test suite..."
npm test || { echo "Tests failed. Push blocked."; exit 1; }

echo "Verifying build..."
npm run build || { echo "Build failed. Push blocked."; exit 1; }

echo "Checking dependencies..."
npm audit --audit-level=high || { echo "High-severity vulnerability found."; exit 1; }
```

**Why separate from pre-commit:** Full test suites are too slow for every commit. Run them at the push boundary where the cost of a slow gate is acceptable.

### Pre-merge gates

Run these in CI before merging a PR. They are the last line of defense.

**What to check:**
- Code review checklist (automated where possible)
- Breaking change detection
- API compatibility verification
- Migration script validation
- Coverage thresholds

**How to implement a breaking change detector:**

```bash
#!/usr/bin/env bash
set -euo pipefail

BASE_BRANCH="${1:-main}"

# Detect removed or renamed exports
REMOVED_EXPORTS=$(diff \
  <(git show "$BASE_BRANCH":src/index.ts | grep -E '^export' | sort) \
  <(grep -E '^export' src/index.ts | sort) \
  | grep '^<' || true)

if [ -n "$REMOVED_EXPORTS" ]; then
  echo "WARNING: The following exports were removed or renamed:"
  echo "$REMOVED_EXPORTS"
  echo ""
  echo "If intentional, add a BREAKING CHANGE note to the PR description."
fi

# Detect changed function signatures in public API
git diff "$BASE_BRANCH"...HEAD -- 'src/public/**' | \
  grep -E '^\-.*function|^\-.*export' | \
  grep -v '^\-\-\-' || true
```

### Conversation-end gates

Run these at the end of an AI-assisted session. They catch harness-level drift.

**What to check:**
- Harness file staleness: did any harness config change without updating related docs?
- Memory consistency: do memory files reference files that still exist?
- Skill coverage: are there new patterns that should be captured as skills?
- Hook integrity: do all registered hooks still point to valid scripts?

**How to implement:**

```bash
#!/usr/bin/env bash
set -euo pipefail

HARNESS_DIR="${1:-.harness}"

# Check for orphaned memory references
if [ -d "$HARNESS_DIR/memory" ]; then
  for memfile in "$HARNESS_DIR/memory"/*.md; do
    grep -oE '\b(src|lib|app)/[^\s]+\.(ts|js|py)\b' "$memfile" 2>/dev/null | while read -r ref; do
      if [ ! -f "$ref" ]; then
        echo "STALE: $memfile references $ref which no longer exists"
      fi
    done
  done
fi

# Check that hooks are still valid
if [ -d "$HARNESS_DIR/hooks" ]; then
  for hook in "$HARNESS_DIR/hooks"/*; do
    if [ ! -x "$hook" ]; then
      echo "WARNING: Hook $hook is not executable"
    fi
  done
fi

# Detect harness config changes without doc updates
HARNESS_CHANGES=$(git diff --name-only HEAD~1 -- "$HARNESS_DIR" | grep -v '\.md$' || true)
DOC_CHANGES=$(git diff --name-only HEAD~1 -- "$HARNESS_DIR" | grep '\.md$' || true)

if [ -n "$HARNESS_CHANGES" ] && [ -z "$DOC_CHANGES" ]; then
  echo "WARNING: Harness config changed but no documentation was updated"
  echo "Changed files: $HARNESS_CHANGES"
fi
```

## Self-evaluation patterns

### The skill-architect-eval pattern

Use one skill to evaluate the output of another. The evaluating skill has different context and different incentives, which catches blind spots.

**How it works:**
1. Skill A produces output (generates code, writes config, designs a system)
2. Skill B evaluates that output against defined criteria
3. If evaluation fails, feed the failure back to Skill A with specific corrections
4. Repeat until evaluation passes or a retry limit is reached

**When to use this:** Use it for high-stakes outputs where getting it wrong is expensive. Do not use it for routine edits where the overhead is not justified.

**Implementation pattern:**

Define evaluation criteria as a checklist the evaluating skill checks against:

```markdown
## Evaluation Criteria for [Output Type]

- [ ] All public functions have docstrings
- [ ] No function exceeds 50 lines
- [ ] Error cases are handled explicitly (no bare except/catch)
- [ ] All new dependencies are justified in comments
- [ ] Test coverage exists for new public API surface
```

The evaluating pass reads the output and checks each criterion. Report pass/fail per criterion with specific line references for failures.

### Assertion-based validation

Define what "good" looks like as executable assertions. Run them against every output.

**Examples:**

```bash
# Assert: every API endpoint has a corresponding test file
for endpoint in src/api/*.ts; do
  testfile="tests/api/$(basename "$endpoint" .ts).test.ts"
  if [ ! -f "$testfile" ]; then
    echo "MISSING TEST: $endpoint has no test at $testfile"
  fi
done

# Assert: no file exceeds 300 lines
find src -name '*.ts' | while read -r f; do
  lines=$(wc -l < "$f")
  if [ "$lines" -gt 300 ]; then
    echo "TOO LONG: $f has $lines lines (max 300)"
  fi
done

# Assert: all config files parse without errors
for config in config/*.yaml; do
  python3 -c "import yaml; yaml.safe_load(open('$config'))" 2>&1 || \
    echo "INVALID CONFIG: $config"
done
```

**Why assertions over manual review:** Assertions are repeatable, fast, and do not require human attention. Define the assertion once, run it forever. Every manual check that repeats more than twice should become an assertion.

### Regression detection

Compare current output to known-good baselines. Detect unintended changes.

**How to implement:**

1. **Capture baselines:** Store known-good outputs in a `baselines/` directory
2. **Compare on change:** Diff current output against baseline
3. **Flag regressions:** Report any unexpected differences
4. **Update intentionally:** When changes are intentional, update the baseline explicitly

```bash
#!/usr/bin/env bash
set -euo pipefail

BASELINE_DIR="baselines"
OUTPUT_DIR="$1"

for baseline in "$BASELINE_DIR"/*; do
  filename=$(basename "$baseline")
  current="$OUTPUT_DIR/$filename"

  if [ ! -f "$current" ]; then
    echo "REGRESSION: $filename exists in baseline but not in output"
    continue
  fi

  if ! diff -q "$baseline" "$current" > /dev/null 2>&1; then
    echo "CHANGED: $filename differs from baseline"
    diff --unified=3 "$baseline" "$current" | head -20
    echo "---"
    echo "If intentional, run: cp $current $baseline"
  fi
done
```

**Why baselines matter:** Without baselines, you cannot distinguish intentional changes from accidental ones. Baselines make "did anything change?" a question you can answer mechanically.

## Feedback loop design

### The improvement cycle

Every quality gate failure is a learning opportunity. Capture what went wrong, fix it, verify the fix, and log the improvement.

```
Failure detected
    |
    v
Diagnose root cause
    |
    v
Update harness (add rule, fix config, improve skill)
    |
    v
Verify fix (re-run gate, confirm it passes)
    |
    v
Log improvement (what changed, why, what it prevents)
```

**Implement a feedback log:**

```markdown
## Feedback Log

### 2026-03-15: Schema validation gate added
- **Trigger:** AI agent wrote invalid YAML config that broke deployment
- **Root cause:** No post-edit validation for YAML files
- **Fix:** Added YAML parse check to post-edit hook
- **Verification:** Introduced intentional YAML error, confirmed hook caught it
- **Prevention:** All future YAML edits are validated on write

### 2026-03-10: Import cycle detection added
- **Trigger:** Circular import caused runtime crash, not caught until production
- **Root cause:** No static analysis for import cycles
- **Fix:** Added madge --circular check to pre-commit
- **Verification:** Created test circular import, confirmed gate blocked commit
- **Prevention:** Circular imports are now impossible to commit
```

**Why log improvements:** The log creates institutional memory. Six months from now, when someone asks "why do we have this gate?", the log answers the question. It also reveals patterns -- if the same category of failure keeps appearing, the harness has a structural gap.

### Tracking quality metrics

When external systems are available (CI dashboards, observability tools), track gate metrics over time:

- **Gate pass rate:** What percentage of commits pass all gates on first attempt?
- **Mean time to fix:** When a gate fails, how long until the fix is committed?
- **False positive rate:** How often do gates block commits that are actually correct?
- **Drift detection rate:** How many drift issues are caught by gates vs. discovered manually?

A declining pass rate means the gates are too strict or the team is cutting corners. A high false positive rate means the gates need tuning. Track these to keep gates useful.

## Integration with CI/CD

Gates and CI/CD are complementary, not redundant.

| Layer | Purpose | Speed | Scope |
|-------|---------|-------|-------|
| Post-edit | Catch typos and format issues immediately | < 1 second | Single file |
| Pre-commit | Catch lint and type errors before they enter history | < 10 seconds | Changed files |
| Pre-push | Catch integration issues before they reach CI | < 2 minutes | Full project |
| CI pipeline | Catch cross-platform, environment-specific issues | < 10 minutes | Full matrix |
| Pre-merge | Final human + automated review | Variable | Full changeset |

**Principle:** Run cheap checks early, expensive checks late. Every gate should catch something that a later gate would also catch, but earlier and faster.

**Wire hooks into CI configuration:**

```yaml
# .github/workflows/gates.yml
name: Quality Gates
on: [pull_request]

jobs:
  gates:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Run pre-merge gates
        run: |
          bash .hooks/pre-merge.sh ${{ github.event.pull_request.base.ref }}
      - name: Breaking change check
        run: |
          bash .hooks/breaking-changes.sh ${{ github.event.pull_request.base.ref }}
      - name: Harness health check
        run: |
          bash .hooks/harness-health.sh
```

**Do not duplicate checks.** If pre-commit already runs lint, do not run lint again in CI unless the CI environment differs meaningfully (different OS, different Node version). Duplication wastes time and creates conflicting results.

## Anti-patterns

### Gates that are too strict

**Symptom:** Developers bypass hooks with `--no-verify`. CI pipelines have a long list of "allowed failures."

**Root cause:** The gate blocks legitimate work. Common examples:
- Enforcing 100% test coverage on all files
- Requiring zero warnings (not just errors) from lint
- Blocking commits for style issues in files the developer did not change

**Fix:** Scope gates to the developer's changes. Set thresholds at achievable levels and ratchet them up gradually. Distinguish errors (must fix) from warnings (should fix eventually).

### Gates that are too loose

**Symptom:** Issues consistently make it to production despite having gates in place.

**Root cause:** The gates check for the wrong things or have too many exceptions. Common examples:
- Lint config with dozens of disabled rules
- Test suite that passes even when assertions are commented out
- Security scan with so many suppressions it catches nothing

**Fix:** Audit gate effectiveness quarterly. For each production incident, ask: "Which gate should have caught this?" If no gate covers it, add one. If a gate exists but missed it, fix the gate.

### Gates that are too slow

**Symptom:** Developers context-switch while waiting for gates. Flow state is broken.

**Root cause:** Running expensive checks at cheap-check checkpoints. Common examples:
- Full test suite on pre-commit
- Docker build on every save
- Dependency resolution on every file edit

**Fix:** Move slow checks to later gates (pre-push or CI). Parallelize where possible. Cache aggressively. If a check takes more than 10 seconds, it does not belong in pre-commit.

### Gates without feedback

**Symptom:** Gates fail with cryptic messages. Developers do not know what to fix.

**Root cause:** The gate reports the failure but not the remedy.

**Fix:** Every gate failure message must include:
1. What failed (specific file, line, rule)
2. Why it matters (what breaks if this is ignored)
3. How to fix it (specific command or action)

```bash
# Bad
echo "Lint failed"
exit 1

# Good
echo "ERROR: src/api/users.ts:42 - 'password' variable may contain a secret"
echo "WHY: Hardcoded secrets in source code are a security vulnerability"
echo "FIX: Move the value to an environment variable and reference it with process.env.PASSWORD"
exit 1
```

## Putting it together

When designing gates for a harness, follow this sequence:

1. **Start with post-edit gates.** They are the cheapest and catch the most common issues (bad formatting, invalid syntax, broken schemas). Implement format-on-save and parse-on-write first.

2. **Add pre-commit gates.** Lint and type-check changed files. Add a secrets scanner. Keep total execution under 10 seconds.

3. **Add pre-push gates.** Run the full test suite and verify the build. This is where integration-level checks belong.

4. **Add conversation-end gates.** Check harness health, memory staleness, and hook integrity. These are unique to AI-assisted workflows.

5. **Add self-evaluation for high-stakes outputs.** Use the skill-architect-eval pattern for system design, API contracts, and migration scripts. Use assertion-based validation for everything else.

6. **Start the feedback log.** Record every gate failure, root cause, and fix. Review the log monthly to spot patterns and improve the gate suite.

7. **Measure and tune.** Track pass rates and false positives. Relax gates that block too much. Tighten gates that miss too much. Remove gates that catch nothing.

Do not try to build all gates at once. Start with the layer that addresses the most frequent failure mode in the current workflow, then expand outward.
