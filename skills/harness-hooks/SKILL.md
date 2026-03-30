---
name: harness-hooks
description: >
  Design, implement, debug, and manage Claude Code hooks — automated behaviors
  that fire before/after tool use or at conversation end. Use this skill whenever
  someone wants to add auto-formatting, auto-linting, safety gates, commit
  validation, test-on-change, secret scanning, or any automated behavior tied
  to Claude's tool usage. Trigger on: "add a hook", "auto-format", "auto-lint",
  "run tests automatically", "validate before commit", "block dangerous commands",
  "hook not working", "fix my hook", "PostToolUse", "PreToolUse", "Stop hook",
  or any request about automating behaviors in response to Claude's actions.
  Also trigger when someone says "I want claude to automatically X" — that's a hook.
---

# Harness Hooks

Hooks are shell commands that execute automatically in response to Claude's actions. They're the mechanism for automated quality gates, formatting, validation, and safety rails.

## Why hooks matter

Without hooks, quality checks are manual — you have to remember to lint, format, and validate. Hooks automate what should never be optional: "every file Claude writes gets formatted" or "every bash command gets checked for danger." They're the immune system of the harness.

## Hook Types

| Type | When it fires | Use for |
|------|--------------|---------|
| **PreToolUse** | Before a tool executes | Block dangerous operations, validate inputs |
| **PostToolUse** | After a tool executes | Format files, run linters, trigger tests |
| **Stop** | When Claude finishes responding | Health checks, memory updates, drift detection |
| **Notification** | When async events happen | Alert on completions, status updates |

## Hook Mechanics

### Configuration format

Hooks live in settings.json (user-level or project-level):

```json
{
  "hooks": [
    {
      "type": "PostToolUse",
      "matcher": "Edit|Write",
      "command": "bash /path/to/hook-script.sh"
    }
  ]
}
```

### Matcher patterns

The `matcher` field filters which tool invocations trigger the hook:

| Matcher | Matches |
|---------|---------|
| `"Edit"` | Only Edit tool |
| `"Write"` | Only Write tool |
| `"Edit\|Write"` | Edit or Write |
| `"Bash"` | All Bash commands |
| (omitted) | All tools of that type |

### Exit codes

| Code | Meaning | Effect |
|------|---------|--------|
| 0 | Success | Operation proceeds normally |
| 2 | Block | Operation is blocked, stdout shown as error message |
| Other | Error | Treated as hook failure, operation proceeds |

### Environment variables

Hooks receive context via environment:
- `CLAUDE_TOOL_INPUT` — JSON string of the tool's input parameters
- `CLAUDE_TOOL_OUTPUT` — JSON string of the tool's output (PostToolUse only)
- `CLAUDE_PROJECT_DIR` — Project root directory

### Stdout and stderr

- **stdout** → shown to Claude as feedback (use for error messages, warnings)
- **stderr** → logged but not shown to Claude

## Common Hook Patterns

### 1. Auto-format on save

Format files after Claude writes or edits them.

```bash
#!/usr/bin/env bash
# hooks/auto-format.sh — PostToolUse on Edit|Write
set -euo pipefail

FILE_PATH=$(echo "$CLAUDE_TOOL_INPUT" | jq -r '.file_path // empty' 2>/dev/null)
[[ -z "$FILE_PATH" || ! -f "$FILE_PATH" ]] && exit 0

case "$FILE_PATH" in
  *.ts|*.tsx|*.js|*.jsx|*.json|*.css|*.md)
    npx prettier --write "$FILE_PATH" 2>/dev/null || true
    ;;
  *.py)
    ruff format "$FILE_PATH" 2>/dev/null || true
    ;;
  *.rs)
    rustfmt "$FILE_PATH" 2>/dev/null || true
    ;;
  *.go)
    gofmt -w "$FILE_PATH" 2>/dev/null || true
    ;;
esac

exit 0
```

Settings entry:
```json
{
  "type": "PostToolUse",
  "matcher": "Edit|Write",
  "command": "bash hooks/auto-format.sh"
}
```

### 2. Lint on edit

Run linter after edits and report issues back to Claude.

```bash
#!/usr/bin/env bash
# hooks/auto-lint.sh — PostToolUse on Edit
set -euo pipefail

FILE_PATH=$(echo "$CLAUDE_TOOL_INPUT" | jq -r '.file_path // empty' 2>/dev/null)
[[ -z "$FILE_PATH" || ! -f "$FILE_PATH" ]] && exit 0

ISSUES=""

case "$FILE_PATH" in
  *.ts|*.tsx|*.js|*.jsx)
    ISSUES=$(npx eslint --format compact "$FILE_PATH" 2>/dev/null || true)
    ;;
  *.py)
    ISSUES=$(ruff check "$FILE_PATH" 2>/dev/null || true)
    ;;
esac

if [[ -n "$ISSUES" ]]; then
    echo "Lint issues found:"
    echo "$ISSUES"
fi

exit 0  # Don't block, just report
```

### 3. Secret scanner

Block writes that contain secrets.

```bash
#!/usr/bin/env bash
# hooks/secret-scanner.sh — PreToolUse on Write|Edit
set -euo pipefail

# Check the content being written
CONTENT=$(echo "$CLAUDE_TOOL_INPUT" | jq -r '.content // .new_string // empty' 2>/dev/null)
[[ -z "$CONTENT" ]] && exit 0

# Patterns that indicate secrets
if echo "$CONTENT" | grep -qiE '(AKIA[A-Z0-9]{16}|sk-[a-zA-Z0-9]{48}|ghp_[a-zA-Z0-9]{36}|-----BEGIN (RSA |EC )?PRIVATE KEY)'; then
    echo "BLOCKED: Content appears to contain a secret (AWS key, API key, or private key). Remove the secret before writing."
    exit 2
fi

# Generic secret patterns (high-confidence only)
if echo "$CONTENT" | grep -qE '"(password|secret|api_key|apikey|access_token)"\s*:\s*"[^"]{10,}"'; then
    echo "WARNING: Content may contain credentials. Please verify this is not a real secret."
    # Warning only, don't block (could be example code)
fi

exit 0
```

### 4. Dangerous command gate

Block risky bash commands before execution.

```bash
#!/usr/bin/env bash
# hooks/command-gate.sh — PreToolUse on Bash
set -euo pipefail

COMMAND=$(echo "$CLAUDE_TOOL_INPUT" | jq -r '.command // empty' 2>/dev/null)
[[ -z "$COMMAND" ]] && exit 0

# Block destructive commands
case "$COMMAND" in
  *"rm -rf /"*|*"rm -rf ~"*|*"rm -rf ."*)
    echo "BLOCKED: Recursive deletion of root, home, or current directory is not allowed."
    exit 2
    ;;
  *"--force"*push*|*push*"--force"*|*"push -f"*)
    echo "BLOCKED: Force push is not allowed by hook. Remove --force flag or ask the user to run manually."
    exit 2
    ;;
  *"DROP TABLE"*|*"DROP DATABASE"*|*"TRUNCATE"*)
    echo "BLOCKED: Destructive database operations must be run manually."
    exit 2
    ;;
esac

exit 0
```

### 5. Test on change

Run relevant tests when source files are edited.

```bash
#!/usr/bin/env bash
# hooks/test-on-change.sh — PostToolUse on Edit
set -euo pipefail

FILE_PATH=$(echo "$CLAUDE_TOOL_INPUT" | jq -r '.file_path // empty' 2>/dev/null)
[[ -z "$FILE_PATH" || ! -f "$FILE_PATH" ]] && exit 0

# Only trigger for source files, not test files
case "$FILE_PATH" in
  *.test.*|*.spec.*|*__tests__*) exit 0 ;;
esac

# Find and run the corresponding test
TEST_FILE=""
case "$FILE_PATH" in
  *.ts|*.tsx)
    BASE="${FILE_PATH%.*}"
    for ext in test.ts test.tsx spec.ts spec.tsx; do
      [[ -f "${BASE}.${ext}" ]] && TEST_FILE="${BASE}.${ext}" && break
    done
    [[ -n "$TEST_FILE" ]] && npx jest "$TEST_FILE" --no-coverage 2>&1 | tail -5
    ;;
  *.py)
    DIR=$(dirname "$FILE_PATH")
    BASE=$(basename "$FILE_PATH" .py)
    TEST_FILE="${DIR}/test_${BASE}.py"
    [[ -f "$TEST_FILE" ]] && python -m pytest "$TEST_FILE" -q 2>&1 | tail -5
    ;;
esac

exit 0
```

### 6. Conversation-end health check

Run checks when Claude finishes responding.

```bash
#!/usr/bin/env bash
# hooks/stop-check.sh — Stop hook
set -euo pipefail

# Check for uncommitted harness changes
if git diff --name-only 2>/dev/null | grep -qE '(CLAUDE\.md|settings\.json|MEMORY\.md)'; then
    echo "NOTE: You have uncommitted changes to harness files. Consider committing them."
fi

exit 0
```

## Step-by-Step: Adding a Hook

1. **Identify the trigger**: What tool action should fire the hook? (Edit, Write, Bash, etc.)
2. **Choose the type**: PreToolUse (validate/block) or PostToolUse (react/fix)?
3. **Write the script**: Use the patterns above as templates. Handle edge cases (missing jq, missing file, etc.)
4. **Make it executable**: `chmod +x hooks/your-hook.sh`
5. **Add to settings.json**: Add the hook entry to the `hooks` array
6. **Test independently**: Run the script manually with sample input to verify behavior
7. **Test with Claude**: Make an edit and verify the hook fires

## Debugging Hooks

When a hook isn't working:

1. **Check it's executable**: `ls -la hooks/your-hook.sh`
2. **Check settings.json**: Is the hook entry valid JSON? Is the matcher correct?
3. **Test the script directly**:
   ```bash
   CLAUDE_TOOL_INPUT='{"file_path":"/tmp/test.ts"}' bash hooks/your-hook.sh
   echo $?
   ```
4. **Check for jq**: Many hooks need jq. Install it if missing: `sudo apt-get install jq`
5. **Check stderr**: Hook errors go to stderr — they're logged but not shown to Claude
6. **Simplify**: Start with `echo "hook fired" && exit 0` to verify the hook triggers at all

## Hook Anti-patterns

- **Slow hooks**: A hook that takes >2 seconds on every edit will kill flow. Keep hooks fast or make them async.
- **Noisy hooks**: A hook that prints warnings on every invocation trains the user to ignore them. Only report actionable issues.
- **Blocking on warnings**: Use exit code 2 sparingly. Most issues should be reported (exit 0) not blocked (exit 2).
- **No error handling**: Always handle the case where the tool input is missing or malformed. Default to exit 0 (allow).
- **Hardcoded paths**: Use `$CLAUDE_PROJECT_DIR` and relative paths so hooks work across machines.
