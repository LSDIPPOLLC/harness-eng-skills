#!/usr/bin/env bash
# Hook: secret-scanner.sh
# Trigger: PreToolUse (before Claude writes any file)
# Purpose: Scan file content for potential secrets/credentials before allowing writes.

set -euo pipefail

# Only act on file-writing tools
if [[ "$CLAUDE_TOOL_NAME" != "Edit" && "$CLAUDE_TOOL_NAME" != "Write" ]]; then
  exit 0
fi

FILE_PATH="$CLAUDE_FILE_PATH"
TOOL_INPUT="$CLAUDE_TOOL_INPUT"

# Define patterns that indicate secrets or credentials
SECRET_PATTERNS=(
  # AWS keys
  'AKIA[0-9A-Z]{16}'
  # Generic secret/password/token assignments
  '["\x27]?(?:password|passwd|pwd|secret|token|api_key|apikey|api[-_]?secret|access[-_]?key|private[-_]?key|auth[-_]?token|bearer)["'\''"]?\s*[:=]\s*["'\''"][^\s"'\'']{8,}["'\''"']'
  # Private keys
  '-----BEGIN\s+(RSA\s+)?PRIVATE KEY-----'
  # GitHub tokens
  'gh[pousr]_[A-Za-z0-9_]{36,}'
  # Generic hex tokens (long hex strings that look like secrets)
  '(?:secret|token|key|password)\s*[:=]\s*["\x27]?[0-9a-fA-F]{32,}["\x27]?'
  # Slack tokens
  'xox[baprs]-[0-9a-zA-Z-]+'
  # Connection strings with credentials
  '(?:mysql|postgres|postgresql|mongodb|redis):\/\/[^:]+:[^@]+@'
  # .env style secrets
  '(?:SECRET|TOKEN|PASSWORD|API_KEY|PRIVATE_KEY)\s*=\s*[^\s]+'
)

# Combine patterns into one regex
COMBINED_PATTERN=""
for pattern in "${SECRET_PATTERNS[@]}"; do
  if [[ -n "$COMBINED_PATTERN" ]]; then
    COMBINED_PATTERN="${COMBINED_PATTERN}|${pattern}"
  else
    COMBINED_PATTERN="$pattern"
  fi
done

# Check the tool input for secrets
MATCHES=$(echo "$TOOL_INPUT" | grep -Pioc "$COMBINED_PATTERN" 2>/dev/null || true)

if [[ "$MATCHES" -gt 0 ]]; then
  echo "BLOCKED: Potential secret or credential detected in content being written to $FILE_PATH"
  echo "Found $MATCHES pattern match(es) that may contain sensitive data."
  echo ""
  echo "Detected patterns may include: API keys, passwords, tokens, private keys, or connection strings."
  echo "Please remove or replace secrets with environment variable references or placeholder values."
  exit 2
fi

echo "Secret scan passed for $FILE_PATH - no credentials detected."
exit 0
