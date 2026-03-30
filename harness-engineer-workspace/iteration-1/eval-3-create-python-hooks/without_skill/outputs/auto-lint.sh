#!/usr/bin/env bash
# Hook: auto-lint.sh
# Trigger: PostToolUse (after Claude edits a file)
# Purpose: Automatically run ruff linter/formatter on Python files after edits.

set -euo pipefail

# Only act on file-editing tools
if [[ "$CLAUDE_TOOL_NAME" != "Edit" && "$CLAUDE_TOOL_NAME" != "Write" ]]; then
  exit 0
fi

# Extract the file path from the tool input
FILE_PATH="$CLAUDE_FILE_PATH"

# Only act on Python files
if [[ "$FILE_PATH" != *.py ]]; then
  exit 0
fi

# Verify the file exists
if [[ ! -f "$FILE_PATH" ]]; then
  echo "Warning: File $FILE_PATH does not exist, skipping lint."
  exit 0
fi

# Run ruff check with auto-fix, respecting pyproject.toml settings
echo "Running ruff check on $FILE_PATH..."
if ruff check --fix "$FILE_PATH" 2>&1; then
  echo "Ruff check passed."
else
  echo "Ruff found issues that could not be auto-fixed in $FILE_PATH"
  exit 1
fi

# Run ruff format to ensure consistent formatting
echo "Running ruff format on $FILE_PATH..."
ruff format "$FILE_PATH" 2>&1
echo "Ruff formatting complete."
