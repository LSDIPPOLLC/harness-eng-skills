#!/usr/bin/env bash
# hooks/auto-lint.sh — PostToolUse on Edit|Write
# Automatically runs ruff linter on Python files after Claude edits or writes them.
# Uses the project's pyproject.toml for ruff configuration.
set -euo pipefail

FILE_PATH=$(echo "$CLAUDE_TOOL_INPUT" | jq -r '.file_path // empty' 2>/dev/null)
[[ -z "$FILE_PATH" || ! -f "$FILE_PATH" ]] && exit 0

# Only run on Python files
case "$FILE_PATH" in
  *.py)
    # Run ruff check with --config to ensure pyproject.toml settings are used
    # ruff automatically discovers pyproject.toml, but we anchor to project dir
    ISSUES=$(cd "$CLAUDE_PROJECT_DIR" && ruff check --config pyproject.toml "$FILE_PATH" 2>/dev/null || true)

    if [[ -n "$ISSUES" ]]; then
      echo "Ruff lint issues found in $FILE_PATH:"
      echo "$ISSUES"
      echo ""
      echo "Run 'ruff check --fix $FILE_PATH' to auto-fix applicable issues."
    fi

    # Also run ruff format check to report formatting issues
    FORMAT_ISSUES=$(cd "$CLAUDE_PROJECT_DIR" && ruff format --check --diff "$FILE_PATH" 2>/dev/null || true)

    if [[ -n "$FORMAT_ISSUES" ]]; then
      echo "Ruff formatting issues found in $FILE_PATH:"
      echo "$FORMAT_ISSUES"
    fi
    ;;
esac

exit 0  # Don't block, just report issues back to Claude
