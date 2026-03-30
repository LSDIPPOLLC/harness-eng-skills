#!/usr/bin/env bash
# hooks/secret-scanner.sh — PreToolUse on Write|Edit
# Scans content for secrets before any file gets written or edited.
# Blocks writes that contain high-confidence secret patterns.
set -euo pipefail

# Extract the content being written or edited
CONTENT=$(echo "$CLAUDE_TOOL_INPUT" | jq -r '.content // .new_string // empty' 2>/dev/null)
[[ -z "$CONTENT" ]] && exit 0

# High-confidence secret patterns — block these
if echo "$CONTENT" | grep -qiE '(AKIA[A-Z0-9]{16}|sk-[a-zA-Z0-9]{48}|ghp_[a-zA-Z0-9]{36}|-----BEGIN (RSA |EC )?PRIVATE KEY)'; then
    echo "BLOCKED: Content appears to contain a secret (AWS key, API key, or private key). Remove the secret before writing."
    exit 2
fi

# Generic secret patterns (high-confidence only)
if echo "$CONTENT" | grep -qE '"(password|secret|api_key|apikey|access_token|secret_key)"\s*:\s*"[^"]{10,}"'; then
    echo "WARNING: Content may contain credentials. Please verify this is not a real secret."
    # Warning only — don't block, as it could be example code
fi

# Check for environment variable assignments with real-looking values
if echo "$CONTENT" | grep -qE '^(export\s+)?(AWS_SECRET_ACCESS_KEY|DATABASE_PASSWORD|API_SECRET|PRIVATE_KEY)=.{10,}'; then
    echo "BLOCKED: Content appears to set a secret via environment variable. Remove the real value before writing."
    exit 2
fi

exit 0
