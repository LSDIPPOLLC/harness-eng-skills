#!/usr/bin/env bash
# harness-validate: PostToolUse hook for Edit/Write on harness files
# Validates changes to CLAUDE.md, settings.json, and hook scripts for consistency
#
# Exit codes:
#   0 = valid, proceed
#   2 = issue found, block with message
#
# This hook fires after edits to harness configuration files and checks:
# - CLAUDE.md isn't excessively large (context budget)
# - settings.json is valid JSON
# - Hook scripts are executable
# - No secrets accidentally added

set -euo pipefail

# The tool input comes via environment or stdin depending on hook type
# For PostToolUse, we check what file was just modified
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

BASENAME=$(basename "$FILE_PATH")
ERRORS=""

# --- CLAUDE.md checks ---
if [[ "$BASENAME" == "CLAUDE.md" ]]; then
    if [[ -f "$FILE_PATH" ]]; then
        LINE_COUNT=$(wc -l < "$FILE_PATH")
        CHAR_COUNT=$(wc -c < "$FILE_PATH")

        # Warn if CLAUDE.md exceeds ~800 lines (rough context budget threshold)
        if (( LINE_COUNT > 800 )); then
            ERRORS+="WARNING: CLAUDE.md is $LINE_COUNT lines. Consider moving some content to .claude/commands/ or skill references to stay within context budget.\n"
        fi

        # Check for potential secrets
        if grep -qiE '(api[_-]?key|secret|password|token)\s*[:=]\s*["\x27]?[A-Za-z0-9+/=]{20,}' "$FILE_PATH" 2>/dev/null; then
            ERRORS+="BLOCKED: CLAUDE.md appears to contain secrets (API keys, tokens, passwords). Remove them immediately.\n"
            echo -e "$ERRORS"
            exit 2
        fi
    fi
fi

# --- settings.json checks ---
if [[ "$BASENAME" == "settings.json" || "$BASENAME" == "settings.local.json" ]]; then
    if [[ -f "$FILE_PATH" ]]; then
        # Validate JSON syntax
        if command -v jq &>/dev/null; then
            if ! jq empty "$FILE_PATH" 2>/dev/null; then
                ERRORS+="BLOCKED: $BASENAME has invalid JSON syntax. Fix before proceeding.\n"
                echo -e "$ERRORS"
                exit 2
            fi
        fi

        # Check for overly broad permissions
        if command -v jq &>/dev/null; then
            BROAD=$(jq -r '.permissions.allow[]? // empty' "$FILE_PATH" 2>/dev/null | grep -c '^Bash(\*)$' || true)
            if (( BROAD > 0 )); then
                ERRORS+="WARNING: settings.json contains Bash(*) — this allows ALL bash commands without confirmation. Consider narrowing to specific patterns.\n"
            fi
        fi
    fi
fi

# --- Hook script checks ---
if [[ "$FILE_PATH" == *"/hooks/"* && ( "$FILE_PATH" == *.sh || "$FILE_PATH" == *.py ) ]]; then
    if [[ -f "$FILE_PATH" && ! -x "$FILE_PATH" ]]; then
        chmod +x "$FILE_PATH"
        ERRORS+="NOTE: Made $BASENAME executable (hooks must be executable to run).\n"
    fi
fi

# Report warnings (non-blocking)
if [[ -n "$ERRORS" ]]; then
    echo -e "$ERRORS"
fi

exit 0
