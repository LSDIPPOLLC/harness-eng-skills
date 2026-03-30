# Python Hooks: Auto-Lint and Secret Scanner

## What Was Created

### 1. `auto-lint.sh` -- PostToolUse Hook
A hook that automatically runs `ruff` whenever Claude edits or writes a Python file.

**Hook type:** `PostToolUse` (fires after Edit or Write)

**Behavior:**
- Checks if the modified file has a `.py` extension; skips non-Python files
- Searches upward from the file's directory to find the nearest `pyproject.toml` for ruff configuration
- Runs `ruff check --fix` to auto-fix safe lint issues
- Runs `ruff format` to apply formatting
- Runs a final `ruff check` to verify -- if unfixable errors remain, exits with code 2 to block the operation and display the errors
- Gracefully handles missing ruff installation with a warning instead of a hard failure

### 2. `secret-scanner.sh` -- PreToolUse Hook
A hook that scans content for potential secrets before any file is written or edited.

**Hook type:** `PreToolUse` (fires before Edit or Write)

**Behavior:**
- Extracts the content about to be written (`.content` for Write, `.new_string` for Edit)
- Scans for nine categories of secrets:
  - AWS access keys and secret keys
  - Generic API keys, secrets, and tokens
  - GitHub personal access tokens
  - Bearer tokens
  - Private key blocks (RSA, EC, OPENSSH, DSA)
  - OpenAI/Stripe secret keys (`sk-...`)
  - Hardcoded passwords (excluding common placeholders)
  - Database connection strings with embedded credentials
- Blocks the write (exit code 2) with a detailed report if any secrets are found
- Skips lock files, source maps, and minified assets to reduce false positives

### 3. `settings.json` -- Hook Configuration
Integrates both new hooks alongside the existing harness hooks.

**Hook order in settings.json:**
1. `PreToolUse: secret-scanner.sh` -- runs BEFORE writes to block secrets early
2. `PostToolUse: auto-lint.sh` -- runs AFTER writes to lint Python files
3. `PostToolUse: harness-validate.sh` -- existing hook, preserved
4. `Stop: harness-drift.sh` -- existing hook, preserved

## Configuration Notes

- Both hooks use `jq` to parse `CLAUDE_TOOL_INPUT` JSON (consistent with existing hooks)
- The auto-lint hook respects ruff settings from `pyproject.toml` by passing `--config`
- The secret scanner runs as `PreToolUse` so secrets are caught before they hit disk
- The auto-linter runs as `PostToolUse` so it can fix the file after it is written
- Both scripts should be made executable: `chmod +x auto-lint.sh secret-scanner.sh`

## Installation

1. Copy the hook scripts to the hooks directory:
   ```
   cp auto-lint.sh secret-scanner.sh /home/lyle/projects/harness/hooks/
   chmod +x /home/lyle/projects/harness/hooks/auto-lint.sh
   chmod +x /home/lyle/projects/harness/hooks/secret-scanner.sh
   ```

2. Place `settings.json` in your `.claude/` directory (or merge into existing settings):
   ```
   cp settings.json /home/lyle/projects/harness/.claude/settings.json
   ```
