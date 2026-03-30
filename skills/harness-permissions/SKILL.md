---
name: harness-permissions
description: >
  Configure Claude Code permission boundaries — what to auto-allow, what to prompt
  for, and how to balance flow with safety. Use this skill whenever someone needs
  to set up permissions in settings.json, is getting too many permission prompts,
  has overly broad permissions (Bash(*)), needs to add MCP server permissions,
  or wants to design a permission strategy for their project. Trigger on:
  "fix permissions", "too many prompts", "allow npm", "permission denied",
  "settings.json permissions", "auto-allow", "stop asking me", or any frustration
  about Claude asking for permission too often or not enough.
---

# Harness Permissions

Configure what Claude can do autonomously vs. what requires human confirmation. The goal is flow — minimize interruptions for safe operations while maintaining guardrails for dangerous ones.

## Why permissions matter

Every permission prompt breaks flow. If Claude asks "can I run npm test?" ten times a session, the user either rage-allows everything (dangerous) or gets annoyed and loses trust. Good permissions auto-allow the routine and gate the risky.

But over-permissioning is equally dangerous. `Bash(*)` means Claude can run ANY command without asking — including `rm -rf`, `git push --force`, or `curl | bash`. A single bad inference could cause real damage.

The sweet spot: Claude runs your build, test, and development tools without asking, but confirms before touching shared state.

## Permission Philosophy

### The blast radius principle

| Blast radius | Examples | Permission |
|-------------|----------|-----------|
| **Local, reversible** | Read files, run tests, format code | Auto-allow |
| **Local, hard to reverse** | Delete files, reset git | Prompt |
| **Shared state** | Git push, deploy, publish, DB write | Always prompt |
| **External systems** | API calls, emails, Slack messages | Always prompt |

### Pattern specificity

Permissions use glob-like matching. Be specific:

```
✗ Bash(*)                    # Too broad — allows everything
✗ Bash(npm *)                # Allows npm publish, npm unpublish
✓ Bash(npm test *)           # Only test commands
✓ Bash(npm run *)            # Only package.json scripts
✓ Bash(npm install *)        # Only install (still somewhat broad)
```

## Step 1: Detect Project Tooling

Read the project's configuration to understand what tools are used:

```bash
# Package manager
ls package.json Cargo.toml pyproject.toml go.mod Gemfile pom.xml 2>/dev/null

# Key config files
ls Makefile justfile Taskfile.yml docker-compose.yml 2>/dev/null

# CI/CD
ls .github/workflows/*.yml .gitlab-ci.yml Jenkinsfile 2>/dev/null
```

Check `package.json` scripts, `Makefile` targets, or equivalent for the specific commands the project uses.

## Step 2: Check Current Permissions

Read the settings hierarchy:
1. `~/.claude/settings.json` — User-level (applies everywhere)
2. `.claude/settings.json` — Project-level (committed to repo)
3. `.claude/settings.local.json` — Local overrides (gitignored)

Evaluate current rules:
- Are commonly-used commands allowed?
- Are dangerous commands gated?
- Are there overly broad patterns?
- Are MCP servers configured?

## Step 3: Design Permission Set

### By language/framework

**Node.js / TypeScript:**
```json
{
  "permissions": {
    "allow": [
      "Bash(npm test *)",
      "Bash(npm run *)",
      "Bash(npx *)",
      "Bash(node *)",
      "Bash(tsc *)",
      "Bash(eslint *)",
      "Bash(prettier *)"
    ]
  }
}
```

**Python:**
```json
{
  "permissions": {
    "allow": [
      "Bash(python *)",
      "Bash(python3 *)",
      "Bash(pip install *)",
      "Bash(pytest *)",
      "Bash(ruff *)",
      "Bash(mypy *)",
      "Bash(uv *)"
    ]
  }
}
```

**Rust:**
```json
{
  "permissions": {
    "allow": [
      "Bash(cargo build *)",
      "Bash(cargo test *)",
      "Bash(cargo run *)",
      "Bash(cargo clippy *)",
      "Bash(cargo fmt *)"
    ]
  }
}
```

**Go:**
```json
{
  "permissions": {
    "allow": [
      "Bash(go build *)",
      "Bash(go test *)",
      "Bash(go run *)",
      "Bash(go vet *)",
      "Bash(golangci-lint *)"
    ]
  }
}
```

### Universal safe commands
```json
{
  "permissions": {
    "allow": [
      "Bash(git status *)",
      "Bash(git log *)",
      "Bash(git diff *)",
      "Bash(git branch *)",
      "Bash(git show *)",
      "Bash(ls *)",
      "Bash(mkdir *)",
      "Bash(cat *)",
      "Bash(wc *)",
      "Bash(head *)",
      "Bash(tail *)",
      "Bash(find *)",
      "Bash(grep *)",
      "Bash(which *)"
    ]
  }
}
```

### Commands that should ALWAYS prompt
Never auto-allow these — the blast radius is too high:
- `git push` — affects remote repository
- `git reset --hard` — destroys local changes
- `rm -rf` — irreversible deletion
- `docker push` — publishes images
- `npm publish` — publishes packages
- `kubectl delete` — destroys infrastructure
- `terraform apply` — modifies cloud resources
- `curl | bash` — arbitrary code execution

## Step 4: Configure MCP Server Permissions

If MCP servers are installed, they need their own permissions:

```json
{
  "permissions": {
    "allow": [
      "mcp__linear-server__*",
      "mcp__slack-server__read_*",
      "mcp__github-server__get_*"
    ]
  }
}
```

For MCP servers, follow the same principle: auto-allow reads, prompt for writes.

## Step 5: Choose the Right Settings File

| File | Scope | Committed to git? | Use for |
|------|-------|-------------------|---------|
| `~/.claude/settings.json` | All projects | No | Personal tool preferences (git, ls, etc.) |
| `.claude/settings.json` | This project | Yes | Team-shared project permissions |
| `.claude/settings.local.json` | This project, this machine | No | Personal overrides, secrets-adjacent tools |

Recommendation:
- Universal safe commands → user-level settings
- Project-specific build/test tools → project settings (committed)
- Personal workflow tools → local settings (gitignored)

## Step 6: Write and Verify

Generate the settings.json content. Before writing:
1. Merge with existing settings (don't overwrite other config like hooks)
2. Validate JSON syntax
3. Show the user what's being added and why
4. Write to the appropriate file

After writing, suggest the user test by running a common command to verify it doesn't prompt.

## Maintenance

Permissions should evolve with the project:
- New tool added? Add its permission pattern.
- Switched package managers? Update the patterns.
- New team member? Review if project-level permissions are appropriate.
- Too many prompts creeping in? Run this skill again to audit.
