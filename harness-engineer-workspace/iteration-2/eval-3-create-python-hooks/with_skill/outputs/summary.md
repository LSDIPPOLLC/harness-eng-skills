# Hook Implementation Summary

## What Was Created

Two Claude Code hooks were designed and implemented to automate Python linting and secret detection.

### 1. Auto-Lint Hook (`auto-lint.sh`)

- **Type**: `PostToolUse` (runs after Claude edits or writes a file)
- **Matcher**: `Edit|Write` (triggers on both Edit and Write tool usage)
- **Behavior**: When Claude edits or writes a Python file (`.py`), the hook automatically runs `ruff check` and `ruff format --check` against the file using the project's `pyproject.toml` configuration. Lint issues and formatting problems are reported back to Claude via stdout so Claude can address them immediately.
- **Exit code**: Always exits 0 (reports issues but never blocks). This is intentional -- linting feedback should inform Claude, not prevent the edit from being saved.

### 2. Secret Scanner Hook (`secret-scanner.sh`)

- **Type**: `PreToolUse` (runs before Claude writes or edits any file)
- **Matcher**: `Write|Edit` (triggers on both Write and Edit tool usage)
- **Behavior**: Inspects the content about to be written for high-confidence secret patterns. Applies to ALL file types, not just Python.
- **Detected patterns that BLOCK (exit 2)**:
  - AWS Access Key IDs (`AKIA...`)
  - API secret keys (`sk-...`)
  - GitHub personal access tokens (`ghp_...`)
  - GitHub OAuth tokens (`gho_...`)
  - Private keys (RSA, EC, DSA, OPENSSH)
  - Slack tokens (`xox[bpors]-...`)
- **Patterns that WARN (exit 0)**:
  - Generic JSON credential key-value pairs (password, secret, api_key, etc.)
  - Environment variable style secrets (e.g., `MY_SECRET_KEY=...`)
- The warning-only patterns use exit 0 because they could match example code or test fixtures.

### 3. Settings Configuration (`settings.json`)

The `settings.json` file contains both hook entries in the `hooks` array. Key details:
- The secret scanner runs as `PreToolUse` so it executes BEFORE the file is written, allowing it to block the operation with exit code 2.
- The auto-linter runs as `PostToolUse` so it executes AFTER the file is written, allowing it to analyze the saved file content.
- Both hooks reference scripts in a `hooks/` directory relative to the project root.

## Setup Instructions

1. Create a `hooks/` directory in the project root
2. Copy `auto-lint.sh` and `secret-scanner.sh` into `hooks/`
3. Make them executable: `chmod +x hooks/auto-lint.sh hooks/secret-scanner.sh`
4. Merge the `hooks` array from `settings.json` into the project's `.claude/settings.json` (or user-level settings)
5. Ensure `ruff` is installed: `pip install ruff`
6. Ensure `jq` is installed (used by both hooks to parse `CLAUDE_TOOL_INPUT`)
7. Verify ruff configuration exists in `pyproject.toml`

## Dependencies

- **ruff**: Python linter and formatter (configured via `pyproject.toml`)
- **jq**: JSON parser (used to extract tool input parameters)
- **bash**: Shell interpreter

## Design Decisions

- The auto-lint hook reports both lint errors (`ruff check`) and formatting issues (`ruff format --check --diff`) to give Claude complete feedback in a single pass.
- The secret scanner uses `PreToolUse` rather than `PostToolUse` because secrets should be caught BEFORE they are written to disk, not after.
- The secret scanner applies to all file types (not just Python) because secrets can appear in any file (config files, shell scripts, YAML, etc.).
- High-confidence patterns (known key formats) block the write. Lower-confidence patterns (generic key-value credentials) only warn, avoiding false positives on example code.
