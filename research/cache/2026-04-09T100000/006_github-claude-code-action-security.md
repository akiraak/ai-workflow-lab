---
url: https://github.com/anthropics/claude-code-action/blob/main/docs/security.md
fetched_at: 2026-04-09T10:00:00+09:00
---

# Security Documentation for Claude Code Action

## Access Control

- **Repository Access**: The action can only be triggered by users with write access to the repository
- **Bot User Control**: By default, GitHub Apps and bots cannot trigger this action for security reasons. Use the `allowed_bots` parameter to enable specific bots or all bots
  - Allowed bots are not checked for repository permissions. On public repos, external Apps may invoke this action with `'*'`
  - Prefer an explicit list over `'*'`
  - Only list App names you trust
- **Non-Write User Access (RISKY)**: The `allowed_non_write_users` parameter allows bypassing write permission requirement. Only use for workflows with extremely limited permissions (e.g., issue labeling with only `issues: write`)
  - Only works with `github_token` input (not GitHub App auth)
  - When set, Claude does best-effort secret scrubbing from subprocess environments
  - On Linux runners with bubblewrap available, subprocesses run with PID-namespace isolation
  - Use `CLAUDE_CODE_SCRIPT_CAPS` env to limit script calls per run
- **Token Permissions**: GitHub app receives only a short-lived token scoped to the repository
- **No Cross-Repository Access**: Each invocation is limited to the repository where triggered
- **Limited Scope**: Token cannot access other repositories

## Pull Request Creation

In default configuration, Claude does not create pull requests automatically when responding to `@claude` mentions. Instead:

- Claude commits code changes to a new branch
- Claude provides a link to the GitHub PR creation page
- The user must click the link and create the PR themselves

This ensures human oversight before code is proposed for merging.

## Prompt Injection Risks

Beware of potential hidden markdown when tagging Claude on untrusted content. External contributors may include hidden instructions through:
- HTML comments
- Invisible characters
- Hidden attributes

The action sanitizes content by stripping HTML comments, invisible characters, markdown image alt text, hidden HTML attributes, and HTML entities.

On public repos, use `include_comments_by_actor` to allowlist which users' comments are passed to Claude. Use `exclude_comments_by_actor` to filter out noisy bot comments.

## GitHub App Permissions

The Claude Code GitHub app requests:

### Currently Used Permissions
- **Contents** (Read & Write): For reading repository files and creating branches
- **Pull Requests** (Read & Write): For reading PR data and creating/updating pull requests
- **Issues** (Read & Write): For reading issue data and updating issue comments

### Permissions for Future Features
- **Discussions** (Read & Write)
- **Actions** (Read)
- **Checks** (Read)
- **Workflows** (Read & Write)

## Commit Signing

### Option 1: GitHub API Commit Signing (use_commit_signing)

Uses GitHub's API to create commits, which automatically signs them as verified:

```yaml
- uses: anthropics/claude-code-action@main
  with:
    use_commit_signing: true
```

Simple but cannot perform complex git operations like rebasing.

### Option 2: SSH Signing Key (ssh_signing_key)

Uses SSH key to sign commits via git CLI. Supports full git operations:

```yaml
- uses: anthropics/claude-code-action@main
  with:
    ssh_signing_key: ${{ secrets.SSH_SIGNING_KEY }}
    bot_id: "YOUR_GITHUB_USER_ID"
    bot_name: "YOUR_GITHUB_USERNAME"
```

Setup steps:
1. Generate SSH key pair: `ssh-keygen -t ed25519 -f ~/.ssh/signing_key -N "" -C "commit signing key"`
2. Add public key to GitHub as Signing Key
3. Add private key to repository secrets as `SSH_SIGNING_KEY`
4. Get user ID: `gh api users/YOUR_USERNAME --jq '.id'`

## Authentication Protection

**CRITICAL: Never hardcode API keys or OAuth tokens in workflow files!**

```yaml
# CORRECT
anthropic_api_key: ${{ secrets.ANTHROPIC_API_KEY }}

# NEVER DO THIS
anthropic_api_key: "sk-ant-api03-..."
```

## Full Output Security Warning

The `show_full_output` option is disabled by default for security reasons. When enabled, it outputs ALL Claude Code messages including:
- Full outputs from tool executions
- API responses that may contain tokens or credentials
- File contents that may include secrets
- Command outputs that may expose sensitive system information

**These logs are publicly visible in GitHub Actions for public repositories!**

Full output is automatically enabled when GitHub Actions debug mode is active (`ACTIONS_STEP_DEBUG` secret set to `true`).

Only enable `show_full_output: true` when:
- Working in a private repository with controlled access
- Debugging issues in a non-production environment
- You have verified no secrets will be exposed
