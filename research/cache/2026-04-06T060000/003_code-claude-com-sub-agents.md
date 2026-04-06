---
url: https://code.claude.com/docs/en/sub-agents
fetched_at: 2026-04-06T06:00:00+09:00
---

# Create custom subagents - Claude Code Docs

> Create and use specialized AI subagents in Claude Code for task-specific workflows and improved context management.

Subagents are specialized AI assistants that handle specific types of tasks. Each subagent runs in its own context window with a custom system prompt, specific tool access, and independent permissions.

## Debugger Subagent Example

A subagent that can both analyze and fix issues. Unlike the code reviewer, this one includes Edit because fixing bugs requires modifying code. The prompt provides a clear workflow from diagnosis to verification.

```markdown
---
name: debugger
description: Debugging specialist for errors, test failures, and unexpected behavior. Use proactively when encountering any issues.
tools: Read, Edit, Bash, Grep, Glob
---

You are an expert debugger specializing in root cause analysis.

When invoked:
1. Capture error message and stack trace
2. Identify reproduction steps
3. Isolate the failure location
4. Implement minimal fix
5. Verify solution works

Debugging process:
- Analyze error messages and logs
- Check recent code changes
- Form and test hypotheses
- Add strategic debug logging
- Inspect variable states

For each issue, provide:
- Root cause explanation
- Evidence supporting the diagnosis
- Specific code fix
- Testing approach
- Prevention recommendations

Focus on fixing the underlying issue, not the symptoms.
```

## Common patterns

### Isolate high-volume operations

One of the most effective uses for subagents is isolating operations that produce large amounts of output. Running tests, fetching documentation, or processing log files can consume significant context.

```
Use a subagent to run the test suite and report only the failing tests with their error messages
```

### Chain subagents

For multi-step workflows, ask Claude to use subagents in sequence:

```
Use the code-reviewer subagent to find performance issues, then use the optimizer subagent to fix them
```

## CLI-defined debugger subagent

```bash
claude --agents '{
  "debugger": {
    "description": "Debugging specialist for errors and test failures.",
    "prompt": "You are an expert debugger. Analyze errors, identify root causes, and provide fixes."
  }
}'
```
