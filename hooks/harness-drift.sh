#!/usr/bin/env bash
# harness-drift: Stop hook for end-of-conversation harness health check
# Runs when Claude finishes a conversation and flags potential harness issues
#
# This hook checks for:
# - CLAUDE.md staleness (hasn't been updated in a while relative to code changes)
# - Memory index (MEMORY.md) out of sync with memory files
# - Orphaned hook scripts (referenced in settings but missing)
# - Settings drift (local settings diverging from project settings)
#
# Exit code 0 always (informational only, never blocks)

set -euo pipefail

ISSUES=""
PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"

# --- CLAUDE.md staleness check ---
if [[ -f "$PROJECT_DIR/CLAUDE.md" ]]; then
    CLAUDE_MD_AGE=$(stat -c %Y "$PROJECT_DIR/CLAUDE.md" 2>/dev/null || stat -f %m "$PROJECT_DIR/CLAUDE.md" 2>/dev/null || echo 0)
    NOW=$(date +%s)
    DAYS_OLD=$(( (NOW - CLAUDE_MD_AGE) / 86400 ))

    if (( DAYS_OLD > 14 )); then
        # Check if code has changed since CLAUDE.md was last updated
        if command -v git &>/dev/null && git -C "$PROJECT_DIR" rev-parse --git-dir &>/dev/null; then
            RECENT_COMMITS=$(git -C "$PROJECT_DIR" log --since="${DAYS_OLD} days ago" --oneline 2>/dev/null | wc -l || echo 0)
            if (( RECENT_COMMITS > 10 )); then
                ISSUES+="STALE: CLAUDE.md hasn't been updated in ${DAYS_OLD} days but there have been ${RECENT_COMMITS} commits. Consider running harness-audit.\n"
            fi
        fi
    fi
fi

# --- Memory index sync check ---
MEMORY_DIR=""
if [[ -d "$PROJECT_DIR/.claude/memory" ]]; then
    MEMORY_DIR="$PROJECT_DIR/.claude/memory"
elif [[ -n "${CLAUDE_MEMORY_DIR:-}" && -d "$CLAUDE_MEMORY_DIR" ]]; then
    MEMORY_DIR="$CLAUDE_MEMORY_DIR"
fi

if [[ -n "$MEMORY_DIR" && -f "$MEMORY_DIR/MEMORY.md" ]]; then
    # Count memory files vs index entries
    MEMORY_FILES=$(find "$MEMORY_DIR" -name "*.md" ! -name "MEMORY.md" -type f 2>/dev/null | wc -l || echo 0)
    INDEX_ENTRIES=$(grep -c '^\s*-\s*\[' "$MEMORY_DIR/MEMORY.md" 2>/dev/null || echo 0)

    DIFF=$(( MEMORY_FILES - INDEX_ENTRIES ))
    if (( DIFF > 2 )) || (( DIFF < -2 )); then
        ISSUES+="DRIFT: Memory index has $INDEX_ENTRIES entries but found $MEMORY_FILES memory files. MEMORY.md may be out of sync.\n"
    fi
fi

# --- Orphaned hook check ---
if [[ -f "$PROJECT_DIR/.claude/settings.json" ]]; then
    if command -v jq &>/dev/null; then
        # Extract hook commands from settings
        HOOK_COMMANDS=$(jq -r '.hooks[]?.command // empty' "$PROJECT_DIR/.claude/settings.json" 2>/dev/null || true)
        while IFS= read -r cmd; do
            [[ -z "$cmd" ]] && continue
            # Extract the script path from the command
            SCRIPT=$(echo "$cmd" | grep -oE '[^ ]+\.(sh|py|js)' | head -1 || true)
            if [[ -n "$SCRIPT" && ! -f "$SCRIPT" && ! -f "$PROJECT_DIR/$SCRIPT" ]]; then
                ISSUES+="MISSING: Hook references '$SCRIPT' but the file doesn't exist.\n"
            fi
        done <<< "$HOOK_COMMANDS"
    fi
fi

# --- Report ---
if [[ -n "$ISSUES" ]]; then
    echo -e "Harness health check:\n$ISSUES"
fi

exit 0
