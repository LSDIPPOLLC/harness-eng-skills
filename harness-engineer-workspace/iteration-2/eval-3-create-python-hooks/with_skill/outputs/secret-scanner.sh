#!/usr/bin/env bash
# hooks/secret-scanner.sh — PreToolUse on Write|Edit
# Scans content for secrets before any file gets written or edited.
# Blocks the operation (exit 2) if high-confidence secrets are detected.
set -euo pipefail

# Extract the content being written or edited
CONTENT=$(echo "$CLAUDE_TOOL_INPUT" | jq -r '.content // .new_string // empty' 2>/dev/null)
[[ -z "$CONTENT" ]] && exit 0

# High-confidence secret patterns — these BLOCK the write (exit 2)
# AWS Access Key IDs
if echo "$CONTENT" | grep -qE 'AKIA[A-Z0-9]{16}'; then
    echo "BLOCKED: Content contains what appears to be an AWS Access Key ID. Remove the secret before writing."
    exit 2
fi

# OpenAI / Anthropic API keys
if echo "$CONTENT" | grep -qE 'sk-[a-zA-Z0-9]{20,}'; then
    echo "BLOCKED: Content contains what appears to be an API secret key (OpenAI/Anthropic-style). Remove the secret before writing."
    exit 2
fi

# GitHub personal access tokens
if echo "$CONTENT" | grep -qE 'ghp_[a-zA-Z0-9]{36}'; then
    echo "BLOCKED: Content contains what appears to be a GitHub personal access token. Remove the secret before writing."
    exit 2
fi

# GitHub OAuth tokens
if echo "$CONTENT" | grep -qE 'gho_[a-zA-Z0-9]{36}'; then
    echo "BLOCKED: Content contains what appears to be a GitHub OAuth token. Remove the secret before writing."
    exit 2
fi

# Private keys (RSA, EC, DSA, etc.)
if echo "$CONTENT" | grep -qE '-----BEGIN (RSA |EC |DSA |OPENSSH )?PRIVATE KEY'; then
    echo "BLOCKED: Content contains what appears to be a private key. Remove the secret before writing."
    exit 2
fi

# Slack tokens
if echo "$CONTENT" | grep -qE 'xox[bpors]-[a-zA-Z0-9-]+'; then
    echo "BLOCKED: Content contains what appears to be a Slack token. Remove the secret before writing."
    exit 2
fi

# Generic high-entropy secret assignments (medium-confidence — warn, don't block)
if echo "$CONTENT" | grep -qE '"(password|secret|api_key|apikey|access_token|secret_key|auth_token)"\s*:\s*"[^"]{10,}"'; then
    echo "WARNING: Content may contain credentials in key-value format. Please verify this is not a real secret."
    # Warning only — don't block, as it could be example/test code
fi

# .env style secrets
if echo "$CONTENT" | grep -qE '^[A-Z_]*(SECRET|PASSWORD|TOKEN|API_KEY|PRIVATE_KEY)[A-Z_]*=.{8,}'; then
    echo "WARNING: Content may contain environment variable secrets. Please verify this is not a real secret."
fi

exit 0
