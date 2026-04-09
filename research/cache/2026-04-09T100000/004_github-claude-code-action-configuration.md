---
url: https://github.com/anthropics/claude-code-action/blob/main/docs/configuration.md
fetched_at: 2026-04-09T10:00:00+09:00
---

# Advanced Configuration

## Using Custom MCP Configuration

You can add custom MCP (Model Context Protocol) servers to extend Claude's capabilities using the `--mcp-config` flag in `claude_args`. These servers merge with the built-in GitHub MCP servers.

### Basic Example: Adding a Sequential Thinking Server

```yaml
- uses: anthropics/claude-code-action@v1
  with:
    anthropic_api_key: ${{ secrets.ANTHROPIC_API_KEY }}
    claude_args: |
      --mcp-config '{"mcpServers": {"sequential-thinking": {"command": "npx", "args": ["-y", "@modelcontextprotocol/server-sequential-thinking"]}}}'
      --allowedTools mcp__sequential-thinking__sequentialthinking
```

### Passing Secrets to MCP Servers

```yaml
- name: Create MCP Config
  run: |
    cat > /tmp/mcp-config.json <<'EOF'
    {
      "mcpServers": {
        "custom-api-server": {
          "command": "npx",
          "args": ["-y", "@example/api-server"],
          "env": {
            "API_KEY": "${{ secrets.CUSTOM_API_KEY }}",
            "BASE_URL": "https://api.example.com"
          }
        }
      }
    }
    EOF

- uses: anthropics/claude-code-action@v1
  with:
    anthropic_api_key: ${{ secrets.ANTHROPIC_API_KEY }}
    claude_args: |
      --mcp-config /tmp/mcp-config.json
```

### Multiple MCP Servers

```yaml
claude_args: |
  --mcp-config /tmp/config1.json
  --mcp-config /tmp/config2.json
  --mcp-config '{"mcpServers": {"inline-server": {"command": "npx", "args": ["@example/server"]}}}'
```

## Additional Permissions for CI/CD Integration

The `additional_permissions` input allows Claude to access GitHub Actions workflow information when you grant the necessary permissions. This is particularly useful for analyzing CI/CD failures and debugging workflow issues.

### Enabling GitHub Actions Access

```yaml
permissions:
  contents: write
  pull-requests: write
  issues: write
  actions: read

# ...
- uses: anthropics/claude-code-action@v1
  with:
    anthropic_api_key: ${{ secrets.ANTHROPIC_API_KEY }}
    additional_permissions: |
      actions: read
```

When you enable `actions: read`, Claude can use the following MCP tools:
- `mcp__github_ci__get_ci_status` - View workflow run statuses
- `mcp__github_ci__get_workflow_run_details` - Get detailed workflow information
- `mcp__github_ci__download_job_log` - Download and analyze job logs

### Example: Debugging Failed CI Runs

```yaml
name: Claude CI Helper
on:
  issue_comment:
    types: [created]

permissions:
  contents: write
  pull-requests: write
  issues: write
  actions: read

jobs:
  claude-ci-helper:
    runs-on: ubuntu-latest
    steps:
      - uses: anthropics/claude-code-action@v1
        with:
          anthropic_api_key: ${{ secrets.ANTHROPIC_API_KEY }}
          additional_permissions: |
            actions: read
```

## Custom Environment Variables

```yaml
- uses: anthropics/claude-code-action@v1
  with:
    settings: |
      {
        "env": {
          "NODE_ENV": "test",
          "CI": "true",
          "DATABASE_URL": "postgres://test:test@localhost:5432/test_db"
        }
      }
```

## Limiting Conversation Turns

```yaml
claude_args: |
  --max-turns 5
```

## Custom Tools

By default, Claude only has access to:
- File operations (reading, committing, editing files, read-only git commands)
- Comment management (creating/updating comments)
- Basic GitHub operations

Claude does **not** have access to execute arbitrary Bash commands by default. You must explicitly allow them:

```yaml
claude_args: |
  --allowedTools "Bash(npm install),Bash(npm run test),Edit,Replace,NotebookEditCell"
  --disallowedTools "TaskOutput,KillTask"
```

## Custom Model

```yaml
# Direct API
claude_args: |
  --model claude-4-0-sonnet-20250805

# AWS Bedrock
claude_args: |
  --model anthropic.claude-4-0-sonnet-20250805-v1:0

# Google Vertex AI
claude_args: |
  --model claude-4-0-sonnet@20250805
```

## Claude Code Settings

### Option 1: Settings File

```yaml
settings: "path/to/settings.json"
```

### Option 2: Inline Settings

```yaml
settings: |
  {
    "model": "claude-opus-4-1-20250805",
    "env": {
      "DEBUG": "true",
      "API_URL": "https://api.example.com"
    },
    "permissions": {
      "allow": ["Bash", "Read"],
      "deny": ["WebFetch"]
    },
    "hooks": {
      "PreToolUse": [{
        "matcher": "Bash",
        "hooks": [{
          "type": "command",
          "command": "echo Running bash command..."
        }]
      }]
    }
  }
```

## Migration from Deprecated Inputs

| Old Input | New Approach |
|-----------|--------------|
| `allowed_tools` | `claude_args: "--allowedTools Tool1,Tool2"` |
| `disallowed_tools` | `claude_args: "--disallowedTools Tool1,Tool2"` |
| `max_turns` | `claude_args: "--max-turns 10"` |
| `model` | `claude_args: "--model claude-4-0-sonnet-20250805"` |
| `claude_env` | `settings` with `"env"` object |
| `custom_instructions` | `claude_args: "--system-prompt 'Your instructions'"` |
| `mcp_config` | `claude_args: "--mcp-config '{...}'"` |
| `direct_prompt` | `prompt` input |
| `override_prompt` | `prompt` with GitHub context variables |

## Custom Executables for Specialized Environments

```yaml
# Custom Claude Code executable
path_to_claude_code_executable: "/path/to/custom/claude"

# Custom Bun executable
path_to_bun_executable: "/path/to/custom/bun"
```
