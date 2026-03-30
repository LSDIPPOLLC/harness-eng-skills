#!/usr/bin/env bash
# auto-lint: PostToolUse hook for Edit/Write on Python files
# Automatically runs ruff to lint and fix Python files after Claude edits them.
# Uses the project's pyproject.toml for ruff configuration.
#
# Exit codes:
#   0 = lint passed (or file was not Python), proceed
#   2 = lint errors remain after auto-fix attempt, block with message

set -euo pipefail

TOOL_INPUT="${CLAUDE_TOOL_INPUT:-}"
FILE_PATH=""

# Extract file_path from tool input JSON
if command -v jq &>/dev/null; then
    FILE_PATH=$(echo "$TOOL_INPUT" | jq -r '.file_path // empty' 2>/dev/null || true)
fi

# If we can't determine the file, allow the operation
if [[ -z "$FILE_PATH" ]]; then
    exit 0
fi

# Only act on Python files
if [[ "$FILE_PATH" != *.py ]]; then
    exit 0
fi

# Verify the file exists
if [[ ! -f "$FILE_PATH" ]]; then
    exit 0
fi

# Locate the project root by searching upward for pyproject.toml
PROJECT_ROOT=""
SEARCH_DIR=$(dirname "$FILE_PATH")
while [[ "$SEARCH_DIR" != "/" ]]; do
    if [[ -f "$SEARCH_DIR/pyproject.toml" ]]; then
        PROJECT_ROOT="$SEARCH_DIR"
        break
    fi
    SEARCH_DIR=$(dirname "$SEARCH_DIR")
done

# Build ruff arguments
RUFF_ARGS=()
if [[ -n "$PROJECT_ROOT" ]]; then
    RUFF_ARGS+=(--config "$PROJECT_ROOT/pyproject.toml")
fi

# Check that ruff is available
if ! command -v ruff &>/dev/null; then
    echo "WARNING: ruff is not installed. Skipping auto-lint for $FILE_PATH."
    echo "Install with: pip install ruff"
    exit 0
fi

# Step 1: Run ruff fix (auto-fix safe issues)
ruff check --fix "${RUFF_ARGS[@]}" "$FILE_PATH" 2>/dev/null || true

# Step 2: Run ruff format
ruff format "${RUFF_ARGS[@]}" "$FILE_PATH" 2>/dev/null || true

# Step 3: Run final lint check to see if issues remain
LINT_OUTPUT=""
LINT_EXIT=0
LINT_OUTPUT=$(ruff check "${RUFF_ARGS[@]}" "$FILE_PATH" 2>&1) || LINT_EXIT=$?

if [[ $LINT_EXIT -ne 0 && -n "$LINT_OUTPUT" ]]; then
    echo "BLOCKED: ruff found lint errors in $(basename "$FILE_PATH") that could not be auto-fixed:"
    echo ""
    echo "$LINT_OUTPUT"
    echo ""
    echo "Please fix these issues before proceeding."
    exit 2
fi

echo "Linted $(basename "$FILE_PATH") with ruff -- all clean."
exit 0
