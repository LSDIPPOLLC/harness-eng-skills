#!/usr/bin/env bash
# hooks/secret-scanner.sh — PreToolUse on Write|Edit
# Blocks writes that contain likely secrets (API keys, private keys, tokens).
set -euo pipefail

CONTENT=$(echo "$CLAUDE_TOOL_INPUT" | jq -r '.content // .new_string // empty' 2>/dev/null)
[[ -z "$CONTENT" ]] && exit 0

# Patterns that indicate secrets
if echo "$CONTENT" | grep -qiE '(AKIA[A-Z0-9]{16}|sk-[a-zA-Z0-9]{48}|ghp_[a-zA-Z0-9]{36}|-----BEGIN (RSA |EC )?PRIVATE KEY)'; then
    echo "BLOCKED: Content appears to contain a secret (AWS key, API key, or private key). Remove the secret before writing."
    exit 2
fi

# Generic secret patterns (high-confidence only)
if echo "$CONTENT" | grep -qE '"(password|secret|api_key|apikey|access_token)"\s*:\s*"[^"]{10,}"'; then
    echo "WARNING: Content may contain credentials. Please verify this is not a real secret."
fi

exit 0
