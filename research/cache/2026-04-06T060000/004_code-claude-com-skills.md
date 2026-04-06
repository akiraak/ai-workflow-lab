---
url: https://code.claude.com/docs/en/skills
fetched_at: 2026-04-06T06:00:00+09:00
---

# Extend Claude with skills - Claude Code Docs

> Create, manage, and share skills to extend Claude's capabilities in Claude Code.

Skills extend what Claude can do. Create a SKILL.md file with instructions, and Claude adds it to its toolkit.

## Bundled skills

| Skill | Purpose |
| --- | --- |
| `/batch <instruction>` | Orchestrate large-scale changes across a codebase in parallel |
| `/claude-api` | Load Claude API reference material |
| `/debug [description]` | Enable debug logging for the current session and troubleshoot issues |
| `/loop [interval] <prompt>` | Run a prompt repeatedly on an interval |
| `/simplify [focus]` | Review your recently changed files for code reuse, quality, and efficiency issues |

## Fix-Issue Skill Example

```yaml
---
name: fix-issue
description: Fix a GitHub issue
disable-model-invocation: true
---

Fix GitHub issue $ARGUMENTS following our coding standards.

1. Read the issue description
2. Understand the requirements
3. Implement the fix
4. Write tests
5. Create a commit
```

When you run `/fix-issue 123`, Claude receives "Fix GitHub issue 123 following our coding standards..."

## Types of skill content

**Task content** gives Claude step-by-step instructions for a specific action:

```yaml
---
name: deploy
description: Deploy the application to production
context: fork
disable-model-invocation: true
---

Deploy the application:
1. Run the test suite
2. Build the application
3. Push to the deployment target
```

## Inject dynamic context

The `!command` syntax runs shell commands before the skill content is sent to Claude:

```yaml
---
name: pr-summary
description: Summarize changes in a pull request
context: fork
agent: Explore
allowed-tools: Bash(gh *)
---

## Pull request context
- PR diff: !`gh pr diff`
- PR comments: !`gh pr view --comments`
- Changed files: !`gh pr diff --name-only`

## Your task
Summarize this pull request...
```
