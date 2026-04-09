---
url: https://github.com/anthropics/claude-code-action/blob/main/docs/usage.md
fetched_at: 2026-04-09T10:00:00+09:00
---

# Claude Code Action - Usage Documentation

## Usage

Add a workflow file to your repository (e.g., `.github/workflows/claude.yml`):

```yaml
name: Claude Assistant
on:
  issue_comment:
    types: [created]
  pull_request_review_comment:
    types: [created]
  issues:
    types: [opened, assigned, labeled]
  pull_request_review:
    types: [submitted]

jobs:
  claude-response:
    runs-on: ubuntu-latest
    steps:
      - uses: anthropics/claude-code-action@v1
        with:
          anthropic_api_key: ${{ secrets.ANTHROPIC_API_KEY }}
```

## Inputs

| Input | Description | Required | Default |
| --- | --- | --- | --- |
| `anthropic_api_key` | Anthropic API key | No* | - |
| `claude_code_oauth_token` | Claude Code OAuth token (alternative) | No* | - |
| `prompt` | Instructions for Claude | No | - |
| `track_progress` | Force tag mode with tracking comments | No | `false` |
| `include_fix_links` | Include 'Fix this' links in PR code review feedback | No | `true` |
| `claude_args` | Additional CLI arguments | No | "" |
| `base_branch` | Base branch for new branches | No | - |
| `use_sticky_comment` | Use one comment for PR comments | No | `false` |
| `classify_inline_comments` | Buffer inline comments and classify via Haiku | No | `true` |
| `github_token` | GitHub token (only for custom GitHub apps) | No | - |
| `use_bedrock` | Use Amazon Bedrock | No | `false` |
| `use_vertex` | Use Google Vertex AI | No | `false` |
| `assignee_trigger` | Assignee username trigger | No | - |
| `label_trigger` | Label name trigger | No | - |
| `trigger_phrase` | Trigger phrase in comments | No | `@claude` |
| `branch_prefix` | Prefix for Claude branches | No | `claude/` |
| `settings` | Claude Code settings JSON or file path | No | "" |
| `additional_permissions` | Additional permissions to enable | No | "" |
| `use_commit_signing` | Enable commit signing via GitHub API | No | `false` |
| `ssh_signing_key` | SSH key for commit signing | No | "" |
| `bot_id` | GitHub user ID for git operations | No | `41898282` |
| `bot_name` | GitHub username for git operations | No | `claude[bot]` |
| `include_comments_by_actor` | Actors to INCLUDE in comments | No | "" |
| `exclude_comments_by_actor` | Actors to EXCLUDE from comments | No | "" |
| `allowed_bots` | Allowed bot usernames | No | "" |
| `allowed_non_write_users` | Users allowed without write permissions | No | "" |
| `path_to_claude_code_executable` | Custom Claude Code executable path | No | "" |
| `path_to_bun_executable` | Custom Bun executable path | No | "" |
| `plugin_marketplaces` | Plugin marketplace Git URLs | No | "" |
| `plugins` | Plugin names to install | No | "" |

## Structured Outputs

Get validated JSON results from Claude that automatically become GitHub Action outputs.

### Basic Example

```yaml
- name: Detect flaky tests
  id: analyze
  uses: anthropics/claude-code-action@v1
  with:
    anthropic_api_key: ${{ secrets.ANTHROPIC_API_KEY }}
    prompt: |
      Check the CI logs and determine if this is a flaky test.
      Return: is_flaky (boolean), confidence (0-1), summary (string)
    claude_args: |
      --json-schema '{"type":"object","properties":{"is_flaky":{"type":"boolean"},"confidence":{"type":"number"},"summary":{"type":"string"}},"required":["is_flaky"]}'

- name: Retry if flaky
  if: fromJSON(steps.analyze.outputs.structured_output).is_flaky == true
  run: gh workflow run CI
```

### How It Works

1. **Define Schema**: Provide JSON schema via `--json-schema` in `claude_args`
2. **Claude Executes**: Claude uses tools to complete your task
3. **Validated Output**: Result is validated against your schema
4. **JSON Output**: All fields returned in `structured_output` JSON string

## Ways to Tag @claude

### Ask Questions
```
@claude What does this function do and how could we improve it?
```

### Request Fixes
```
@claude Can you add error handling to this function?
```

### Code Review
```
@claude Please review this PR and suggest improvements
```

### Fix Bugs from Screenshots
```
@claude Here's a screenshot of a bug I'm seeing [upload screenshot]. Can you fix it?
```
