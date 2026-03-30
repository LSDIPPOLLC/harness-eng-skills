# Claude Code Hooks: Auto-Lint and Secret Scanner

## What Was Created

### 1. auto-lint.sh -- Post-Edit Ruff Linting Hook

**Location:** `.claude/hooks/auto-lint.sh`
**Trigger:** `PostToolUse` (runs after `Edit` or `Write` tool calls)

This hook automatically runs the `ruff` linter and formatter on any Python file that Claude edits or creates. It:

- Checks if the tool used was `Edit` or `Write` (skips otherwise).
- Checks if the target file has a `.py` extension (skips non-Python files).
- Runs `ruff check --fix` to lint and auto-fix issues, respecting settings in `pyproject.toml`.
- Runs `ruff format` to apply consistent formatting.
- Exits with a non-zero status if ruff finds unfixable issues, signaling the error to Claude.

### 2. secret-scanner.sh -- Pre-Write Secret Detection Hook

**Location:** `.claude/hooks/secret-scanner.sh`
**Trigger:** `PreToolUse` (runs before `Edit` or `Write` tool calls)

This hook scans the content Claude is about to write for potential secrets and credentials. It blocks the write if matches are found. Detected patterns include:

- AWS access keys (AKIA...)
- Password, secret, token, and API key assignments
- PEM private keys
- GitHub personal access tokens
- Slack tokens
- Database connection strings with embedded credentials
- .env-style secret assignments (SECRET=, TOKEN=, etc.)

If a match is found, the hook exits with code 2 (blocking the tool use) and prints a message explaining what was detected.

### 3. settings.json -- Hook Configuration

**Location:** `.claude/settings.json`

Configures both hooks in the Claude Code settings format:

- **PreToolUse** hooks: `secret-scanner.sh` runs before any `Edit` or `Write` operation.
- **PostToolUse** hooks: `auto-lint.sh` runs after any `Edit` or `Write` operation.

The `matcher` field uses a regex pattern (`Edit|Write`) to target only file-modification tools.

## Setup Instructions

1. Copy the hook scripts into your project's `.claude/hooks/` directory.
2. Make both scripts executable: `chmod +x .claude/hooks/auto-lint.sh .claude/hooks/secret-scanner.sh`
3. Merge the `settings.json` content into your `.claude/settings.json` (project-level) or `~/.claude/settings.json` (user-level).
4. Ensure `ruff` is installed and available on your PATH (`pip install ruff` or `uv pip install ruff`).
5. Your existing `pyproject.toml` ruff configuration will be respected automatically -- ruff discovers it from the project root.

## Environment Variables Used by Hooks

| Variable | Description |
|---|---|
| `CLAUDE_TOOL_NAME` | The name of the tool being invoked (e.g., `Edit`, `Write`) |
| `CLAUDE_FILE_PATH` | The path of the file being read/written |
| `CLAUDE_TOOL_INPUT` | The full JSON input to the tool (used for secret scanning) |
