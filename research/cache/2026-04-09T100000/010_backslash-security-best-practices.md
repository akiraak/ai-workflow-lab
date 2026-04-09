---
url: https://www.backslash.security/blog/claude-code-security-best-practices
fetched_at: 2026-04-09T10:00:00+09:00
---

# Claude Code Security Best Practices

How to safely set Claude Code's configuration settings, and beyond

By Ben Kishaless | Backslash Research Team | Published: September 18, 2025

## Why Security in Claude Code Matters

When integrating AI into your coding environment, the IDE transforms into a privileged system component with significant capabilities:

- **Filesystem access** to your entire project structure
- **Command execution** permissions in your terminal
- **Dependency installation** capabilities that can introduce supply chain risks
- **API connectivity** and configuration modification abilities

These powers introduce real threat scenarios. Example: Claude could suggest adding a seemingly legitimate npm package. Without proper safeguards, that installation executes a malicious postinstall script that copies SSH keys to external servers.

## Understanding the Threat Model

Claude Code operates simultaneously as assistant and system operator. Every command execution and file read happens with your system permissions:

**Command Injection**: Malicious inputs or prompts could convince Claude to execute destructive commands.

**Data Exfiltration**: Without restrictions, Claude can access environment files, AWS credentials, or secret configurations.

**Persistence Mechanisms**: Improperly configured hooks or MCP servers can reintroduce malicious code on restart.

**Safeguard Bypasses**: Unsafe defaults—particularly auto-approval of servers—create exploitable gaps.

## The Heart of Security: managed-settings.json

Claude Code's security controls reside in:
`/Library/Application Support/ClaudeCode/managed-settings.json`

This file functions as your firewall rules for what Claude can execute, what requires permission, and what is inaccessible.

## Critical Security Settings

| Setting Name | Recommended | Security Level | Explanation |
|---|---|---|---|
| `env` | ON | Limited Control | Sets environment variables. Never include secrets unless encrypted. |
| `cleanupPeriodDays` | ON | Not Safe Enough | Chat transcript retention. Keep at 7-14 days for sensitive work. |
| `disableAllHooks` | ON | Safe for All | Completely disables hooks, preventing pre/post-tool scripts. |

## MCP Servers: The Hidden Danger

**Dangerous Configuration:**
```json
{ "enableAllProjectMcpServers": true }
```
This instructs Claude to execute any discovered server without verification.

**Secure Configuration:**
```json
{ "enabledMcpjsonServers": ["github", "memory"] }
```
Explicitly allowlist only evaluated and trusted servers.

**Proactive Blocking:**
```json
{ "disabledMcpjsonServers": ["filesystem"] }
```

## Permissions: Your Last Line of Defense

**Allowlist (permissions.allow)**: Only 100% harmless commands.
```json
{ "permissions": { "allow": ["Bash(echo Hello)"] } }
```

**Asklist (permissions.ask)**: Occasionally useful but risky operations.
```json
{ "permissions": { "ask": ["Bash(git push:*)", "Bash(docker run:*)"] } }
```

**Denylist (permissions.deny)**: Strongest defensive measure.
```json
{ "permissions": { "deny": ["WebFetch", "Bash(curl:*)", "Read(./secrets/**)"] } }
```
Claude cannot bypass these restrictions.

## Best Practices in Action

1. **Disable all hooks completely** - prevents surprise code execution
2. **Explicitly approve only safe MCP servers** - github and memory are generally safe
3. **Use deny rules aggressively** - block curl, fetch, and .env file access
4. **Keep transcript retention minimal** - 7-14 days for sensitive projects
5. **Sandbox Claude Code execution** - run within VMs or containers
6. **Never grant administrative privileges** - AI should never run as root
7. **Audit configuration monthly** - review for drift or unauthorized changes
8. **Test in isolated environments** - validate before deploying to production

## Beyond Configuration: External Defenses

**OS-Level Sandboxing**: Deploy within Docker containers, Podman, or VMs.

**Filesystem Restrictions**: OS-level controls preventing access to ~/.ssh/, secret vaults.

**Secrets Management**: Replace plaintext .env files with vault solutions.

**Activity Monitoring**: Track unusual file modifications, network connections, suspicious commands.

## Summary

Treat Claude Code as an untrusted but capable intern. Grant only minimum necessary permissions, isolate execution environments, and conduct regular configuration audits.

## References

1. Anthropic's Claude Code settings documentation
2. ClaudeLog essential configuration guide
3. Shipyard's Claude Code cheat sheet
4. fcakyon's recommended Claude Code settings
5. Builder.io how I use Claude Code
6. Net Ninja's Claude Code Tutorial
