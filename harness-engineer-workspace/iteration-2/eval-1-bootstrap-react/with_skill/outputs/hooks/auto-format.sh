#!/usr/bin/env bash
# hooks/auto-format.sh — PostToolUse on Edit|Write
# Runs Prettier on supported files after Claude writes or edits them.
set -euo pipefail

FILE_PATH=$(echo "$CLAUDE_TOOL_INPUT" | jq -r '.file_path // empty' 2>/dev/null)
[[ -z "$FILE_PATH" || ! -f "$FILE_PATH" ]] && exit 0

case "$FILE_PATH" in
  *.ts|*.tsx|*.js|*.jsx|*.json|*.css|*.md)
    npx prettier --write "$FILE_PATH" 2>/dev/null || true
    ;;
esac

exit 0
