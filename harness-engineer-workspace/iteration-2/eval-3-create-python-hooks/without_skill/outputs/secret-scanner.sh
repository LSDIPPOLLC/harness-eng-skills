#!/usr/bin/env bash
# secret-scanner: PreToolUse hook for Edit/Write on any file
# Scans file content about to be written for potential secrets, API keys,
# tokens, and credentials. Blocks the write if secrets are detected.
#
# Exit codes:
#   0 = no secrets found, allow the write
#   2 = potential secret detected, block the write with message

set -euo pipefail

TOOL_INPUT="${CLAUDE_TOOL_INPUT:-}"

# If no tool input available, allow the operation
if [[ -z "$TOOL_INPUT" ]]; then
    exit 0
fi

# Extract the content being written and the file path
FILE_PATH=""
CONTENT=""

if command -v jq &>/dev/null; then
    FILE_PATH=$(echo "$TOOL_INPUT" | jq -r '.file_path // empty' 2>/dev/null || true)
    # For Write tool, content is in .content; for Edit tool, it's in .new_string
    CONTENT=$(echo "$TOOL_INPUT" | jq -r '.content // .new_string // empty' 2>/dev/null || true)
fi

# If we can't extract content, allow the operation
if [[ -z "$CONTENT" ]]; then
    exit 0
fi

BASENAME=""
if [[ -n "$FILE_PATH" ]]; then
    BASENAME=$(basename "$FILE_PATH")
fi

# Skip scanning for certain file types that commonly have false positives
# (e.g., lock files, binary-ish files, test fixtures with fake keys)
case "$BASENAME" in
    *.lock|*.sum|*.map|*.min.js|*.min.css)
        exit 0
        ;;
esac

FINDINGS=""

# --- Pattern 1: AWS access keys (AKIA...) ---
if echo "$CONTENT" | grep -qE 'AKIA[0-9A-Z]{16}'; then
    FINDINGS+="  - AWS Access Key ID detected (AKIA...)\n"
fi

# --- Pattern 2: AWS secret keys ---
if echo "$CONTENT" | grep -qE '["\x27][A-Za-z0-9/+=]{40}["\x27]'; then
    # Only flag if near an AWS-related keyword to reduce false positives
    if echo "$CONTENT" | grep -qiE '(aws|secret|access.key)'; then
        FINDINGS+="  - Possible AWS Secret Access Key detected\n"
    fi
fi

# --- Pattern 3: Generic API keys, tokens, secrets assigned to values ---
if echo "$CONTENT" | grep -qiE '(api[_-]?key|api[_-]?secret|access[_-]?token|auth[_-]?token|secret[_-]?key|private[_-]?key)\s*[:=]\s*["\x27][A-Za-z0-9+/=_\-]{16,}["\x27]'; then
    FINDINGS+="  - API key / secret / token assignment detected\n"
fi

# --- Pattern 4: GitHub tokens ---
if echo "$CONTENT" | grep -qE '(ghp|gho|ghu|ghs|ghr)_[A-Za-z0-9_]{36,}'; then
    FINDINGS+="  - GitHub personal access token detected\n"
fi

# --- Pattern 5: Generic high-entropy bearer/token strings ---
if echo "$CONTENT" | grep -qiE 'bearer\s+[A-Za-z0-9\._\-]{20,}'; then
    FINDINGS+="  - Bearer token detected\n"
fi

# --- Pattern 6: Private key blocks ---
if echo "$CONTENT" | grep -qE '\-\-\-\-\-BEGIN (RSA |EC |OPENSSH |DSA )?PRIVATE KEY\-\-\-\-\-'; then
    FINDINGS+="  - Private key block detected\n"
fi

# --- Pattern 7: Common cloud provider secrets ---
if echo "$CONTENT" | grep -qE 'sk-[A-Za-z0-9]{20,}'; then
    FINDINGS+="  - Possible OpenAI/Stripe secret key detected (sk-...)\n"
fi

# --- Pattern 8: Password assignments ---
if echo "$CONTENT" | grep -qiE '(password|passwd|pwd)\s*[:=]\s*["\x27][^"\x27]{8,}["\x27]'; then
    # Exclude common placeholder/example passwords
    if ! echo "$CONTENT" | grep -qiE '(password|passwd|pwd)\s*[:=]\s*["\x27](password|example|changeme|placeholder|xxx|your_password|test)["\x27]'; then
        FINDINGS+="  - Hardcoded password detected\n"
    fi
fi

# --- Pattern 9: Connection strings with credentials ---
if echo "$CONTENT" | grep -qiE '(mysql|postgres|postgresql|mongodb|redis|amqp)://[^:]+:[^@]+@'; then
    FINDINGS+="  - Database connection string with embedded credentials detected\n"
fi

# Report findings
if [[ -n "$FINDINGS" ]]; then
    echo "BLOCKED: Potential secrets detected in content being written to ${BASENAME:-unknown file}:"
    echo ""
    echo -e "$FINDINGS"
    echo ""
    echo "If these are intentional (e.g., test fixtures with fake values), consider:"
    echo "  - Moving secrets to environment variables"
    echo "  - Using a .env file (excluded from version control)"
    echo "  - Adding placeholder values instead"
    exit 2
fi

exit 0
