#!/usr/bin/env bash
# hooks/auto-lint.sh — PostToolUse on Edit|Write
# Automatically runs ruff linter whenever Claude edits or writes a Python file.
# Uses project-level ruff configuration from pyproject.toml.
set -euo pipefail

FILE_PATH=$(echo "$CLAUDE_TOOL_INPUT" | jq -r '.file_path // empty' 2>/dev/null)
[[ -z "$FILE_PATH" || ! -f "$FILE_PATH" ]] && exit 0

# Only act on Python files
case "$FILE_PATH" in
  *.py)
    # Run ruff check (uses pyproject.toml settings automatically)
    ISSUES=$(ruff check "$FILE_PATH" 2>/dev/null || true)

    if [[ -n "$ISSUES" ]]; then
        echo "Ruff lint issues found in $FILE_PATH:"
        echo "$ISSUES"
    fi

    # Also run ruff format to auto-fix formatting
    ruff format "$FILE_PATH" 2>/dev/null || true
    ;;
esac

exit 0
