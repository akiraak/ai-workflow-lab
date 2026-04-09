---
url: https://www.truefoundry.com/blog/claude-code-governance-building-an-enterprise-usage-policy-from-scratch
fetched_at: 2026-04-09T10:00:00+09:00
---

# Claude Code Governance: Building an Enterprise Usage Policy from Scratch

## Introduction

Organizations face a critical challenge: Claude Code is already in use across teams, often without proper oversight. The tool operates with user-level terminal privileges, reads files, executes bash commands, and sends code context to Anthropic's servers. "Without a usage policy, you've got API keys in Slack channels, no visibility into what the tool accesses" and no audit trail for compliance purposes.

Three primary risks emerge quickly:

1. **Shadow AI**: Developers using personal Pro/Max accounts may inadvertently send proprietary code under consumer terms, potentially exposing it to training data inclusion.
2. **Scattered credentials**: API keys proliferate across dotfiles, environment files, and messaging channels without centralized management.
3. **Audit trail gaps**: Organizations cannot answer fundamental compliance questions about tool usage and access patterns.

## Step 1: Choose Your Plan and Authentication Model

Governance capabilities depend entirely on your Anthropic plan:

- **Free/Pro/Max**: No managed settings or admin controls available
- **Team**: Self-serve seat management, spend caps, Claude Code analytics
- **Enterprise**: SCIM provisioning, role-based permissions, Compliance API access, custom data retention, IP allowlisting

SSO integration typically requires 2-4 hours.

## Step 2: Deploy Managed Settings

The `managed-settings.json` file enforces organization-wide policies developers cannot override. Two delivery methods:

**Server-managed settings**: Configure in Claude.ai Admin Settings.
**Endpoint-managed settings**: Deploy via MDM (Jamb, Kandji, Intune) to OS-level paths.

### Baseline Policy Configuration

```json
{
  "permissions": {
    "disableBypassPermissionsMode": "disable",
    "deny": [
      "Bash(curl*)",
      "Bash(wget*)",
      "Read(**/.env)",
      "Read(*/.env.)",
      "Read(*/secrets/*)",
      "Read(*/.ssh/*)"
    ],
    "ask": [
      "Bash(git push:*)",
      "Write(**)"
    ]
  },
  "allowManagedPermissionRulesOnly": true,
  "allowManagedHooksOnly": true,
  "cleanupPeriodDays": 14
}
```

## Step 3: Lock Down MCP Servers

- **allowManagedMcpServersOnly: true**: Only approved MCP servers can execute
- **Explicit allowlist**: Pre-vetted approved servers only
- **Default read-only access**: Write operations require separate approval workflows

## Step 4: Set Spend Controls

Implement controls at two levels:
- **Organization-level caps**: Hard monthly spending ceiling
- **Per-user caps**: Prevent disproportionate individual consumption

## Step 5: Build the Audit Trail

**Claude Code session transcripts**: Local logging in `~/.claude/`.

**Anthropic's Compliance API**: Enterprise-only programmatic access to real-time usage data and customer content. Integration approach: Feed into Grafana, Datadog, or Splunk via OpenTelemetry.

## Step 6: Write the Actual Policy Document

- **Access eligibility**: Which roles and teams qualify
- **Data classification**: What data types are permitted (PHI, PII, production credentials typically restricted)
- **Repository scope**: Which codebases warrant Claude Code access
- **MCP governance**: Approval workflows for new tool connections
- **Incident response**: Escalation procedures when improper access occurs
- **Cost ownership**: Budget responsibility and overage handling

Keep documentation concise — two pages of clear rules outperform lengthy compliance documents.

## Step 7: Roll Out in Phases

**Phase 1 (pilot)**: 5-10 developers, two weeks.
**Phase 2 (department)**: 20-50 developers.
**Phase 3 (organization-wide)**: Push managed settings via MDM across the entire fleet.

## Final Verdict

Enterprise governance for Claude Code is now essential. Anthropic built real governance tooling — managed settings developers cannot bypass, real-time Compliance API access, SSO, SCIM, spend caps, and sandboxing capabilities.
