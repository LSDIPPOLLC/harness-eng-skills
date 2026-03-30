#!/usr/bin/env bash
# hooks/auto-lint.sh — PostToolUse on Edit
# Runs ESLint on TypeScript/JavaScript files after edits and reports issues to Claude.
set -euo pipefail

FILE_PATH=$(echo "$CLAUDE_TOOL_INPUT" | jq -r '.file_path // empty' 2>/dev/null)
[[ -z "$FILE_PATH" || ! -f "$FILE_PATH" ]] && exit 0

case "$FILE_PATH" in
  *.ts|*.tsx|*.js|*.jsx)
    ISSUES=$(npx eslint --format compact "$FILE_PATH" 2>/dev/null || true)
    if [[ -n "$ISSUES" ]]; then
      echo "Lint issues found:"
      echo "$ISSUES"
    fi
    ;;
esac

exit 0
