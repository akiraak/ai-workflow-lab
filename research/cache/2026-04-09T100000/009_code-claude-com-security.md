---
url: https://code.claude.com/docs/en/security
fetched_at: 2026-04-09T10:00:00+09:00
---

# Security

> Learn about Claude Code's security safeguards and best practices for safe usage.

## How we approach security

### Security foundation

Your code's security is paramount. Claude Code is built with security at its core, developed according to Anthropic's comprehensive security program. Learn more at Anthropic Trust Center (https://trust.anthropic.com) — SOC 2 Type 2 report, ISO 27001 certificate, etc.

### Permission-based architecture

Claude Code uses strict read-only permissions by default. When additional actions are needed (editing files, running tests, executing commands), Claude Code requests explicit permission. Users control whether to approve actions once or allow them automatically.

For detailed permission configuration, see Permissions documentation.

### Built-in protections

* **Sandboxed bash tool**: Sandbox bash commands with filesystem and network isolation, reducing permission prompts while maintaining security. Enable with `/sandbox` to define boundaries.
* **Write access restriction**: Claude Code can only write to the folder where it was started and its subfolders. It cannot modify files in parent directories without explicit permission. Read access extends beyond the working directory for system libraries and dependencies.
* **Prompt fatigue mitigation**: Support for allowlisting frequently used safe commands per-user, per-codebase, or per-organization.
* **Accept Edits mode**: Batch accept multiple edits while maintaining permission prompts for commands with side effects.

### User responsibility

Claude Code only has the permissions you grant it. You're responsible for reviewing proposed code and commands for safety before approval.

## Protect against prompt injection

### Core protections

* **Permission system**: Sensitive operations require explicit approval
* **Context-aware analysis**: Detects potentially harmful instructions by analyzing full request
* **Input sanitization**: Prevents command injection by processing user inputs
* **Command blocklist**: Blocks risky commands (curl, wget) by default

### Privacy safeguards

* Limited retention periods for sensitive information
* Restricted access to user session data
* User control over data training preferences

### Additional safeguards

* **Network request approval**: Network tools require user approval by default
* **Isolated context windows**: Web fetch uses separate context window to avoid injecting malicious prompts
* **Trust verification**: First-time codebase runs and new MCP servers require trust verification (disabled in `-p` mode)
* **Command injection detection**: Suspicious bash commands require manual approval even if allowlisted
* **Fail-closed matching**: Unmatched commands default to manual approval
* **Natural language descriptions**: Complex bash commands include explanations
* **Secure credential storage**: API keys and tokens are encrypted

**Best practices for untrusted content:**
1. Review suggested commands before approval
2. Avoid piping untrusted content directly to Claude
3. Verify proposed changes to critical files
4. Use VMs for scripts interacting with external services
5. Report suspicious behavior with `/feedback`

## MCP security

Claude Code allows configuring MCP servers. The allowed list is configured in source code as part of settings checked into source control. Encourage writing your own MCP servers or using trusted providers. Anthropic does not manage or audit MCP servers.

## Cloud execution security

When using Claude Code on the web:
* **Isolated virtual machines**: Each session runs in isolated, Anthropic-managed VM
* **Network access controls**: Limited by default, configurable per domain
* **Credential protection**: Authentication via secure proxy with scoped credentials
* **Branch restrictions**: Git push limited to current working branch
* **Audit logging**: All operations logged for compliance
* **Automatic cleanup**: Environments terminated after session completion

## Security best practices

### Working with sensitive code
* Review all suggested changes before approval
* Use project-specific permission settings
* Consider devcontainers for additional isolation
* Regularly audit permissions with `/permissions`

### Team security
* Use managed settings to enforce organizational standards
* Share approved permission configurations through version control
* Train team members on security best practices
* Monitor usage through OpenTelemetry metrics
* Audit or block settings changes with `ConfigChange` hooks

### Reporting security issues
1. Do not disclose publicly
2. Report through HackerOne program (https://hackerone.com/anthropic-vdp/reports/new)
3. Include detailed reproduction steps
4. Allow time for resolution before disclosure

## Related resources

* Sandboxing - Filesystem and network isolation
* Permissions - Configure permissions and access controls
* Monitoring usage - Track and audit activity
* Development containers - Secure, isolated environments
* Anthropic Trust Center - Security certifications and compliance
