# Hook Setup Summary

## What Was Created

Two Claude Code hooks and a settings.json configuration to wire them up.

### 1. auto-lint.sh (PostToolUse hook)

- **Type**: PostToolUse — fires after Claude edits or writes a file
- **Matcher**: `Edit|Write` — triggers on both Edit and Write tool invocations
- **What it does**:
  - Extracts the `file_path` from `CLAUDE_TOOL_INPUT` using jq
  - Checks if the file is a Python file (`.py` extension)
  - Runs `ruff check` to report lint issues back to Claude via stdout; ruff automatically picks up the project's configuration from `pyproject.toml`
  - Runs `ruff format` to auto-fix any formatting issues in-place
  - Exits 0 in all cases (reports issues but never blocks)
- **Why PostToolUse**: Linting should happen after the file has been written, not before. This lets Claude see any issues it introduced and fix them in the next turn.

### 2. secret-scanner.sh (PreToolUse hook)

- **Type**: PreToolUse — fires before Claude writes or edits any file
- **Matcher**: `Write|Edit` — triggers on both Write and Edit tool invocations
- **What it does**:
  - Extracts the content being written (`content` for Write, `new_string` for Edit) from `CLAUDE_TOOL_INPUT`
  - Checks for high-confidence secret patterns:
    - AWS access keys (`AKIA...`)
    - OpenAI/Stripe-style API keys (`sk-...`)
    - GitHub personal access tokens (`ghp_...`)
    - PEM private keys (`-----BEGIN PRIVATE KEY`)
    - Environment variable assignments with secret-looking values
  - **Blocks** (exit 2) when a high-confidence secret is detected, preventing the file write entirely
  - **Warns** (exit 0 with stdout message) for generic credential patterns like `"password": "..."` in JSON, since these may be example code
- **Why PreToolUse**: Secret scanning must happen before the file is written. Exit code 2 blocks the operation so secrets never reach disk.

### 3. settings.json

Contains the `hooks` array with both hooks configured:
- The secret scanner runs first (PreToolUse) to gate writes
- The auto-linter runs second (PostToolUse) to check and format after successful writes

## Setup Instructions

1. Place `auto-lint.sh` and `secret-scanner.sh` in a `hooks/` directory at the project root
2. Make both scripts executable: `chmod +x hooks/auto-lint.sh hooks/secret-scanner.sh`
3. Merge the `hooks` array from `settings.json` into your project's `.claude/settings.json` (or user-level settings)
4. Ensure `jq` is installed (used to parse `CLAUDE_TOOL_INPUT`)
5. Ensure `ruff` is installed and your linting/formatting rules are configured in `pyproject.toml`

## Dependencies

- **jq**: For parsing the JSON environment variables that Claude provides to hooks
- **ruff**: Python linter and formatter (reads config from `pyproject.toml`)
- **grep**: Used by the secret scanner for pattern matching (standard on all systems)
