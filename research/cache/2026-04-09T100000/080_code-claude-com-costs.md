---
url: https://code.claude.com/docs/en/costs
fetched_at: 2026-04-09T10:00:00+09:00
---

# Manage costs effectively

> Track token usage, set team spend limits, and reduce Claude Code costs with context management, model selection, extended thinking settings, and preprocessing hooks.

Claude Code consumes tokens for each interaction. Costs vary based on codebase size, query complexity, and conversation length. The average cost is $6 per developer per day, with daily costs remaining below $12 for 90% of users.

For team usage, Claude Code charges by API token consumption. On average, Claude Code costs ~$100-200/developer per month with Sonnet 4.6 though there is large variance depending on how many instances users are running and whether they're using it in automation.

This page covers how to track your costs, manage costs for teams, and reduce token usage.

## Track your costs

### Using the `/cost` command

Note: The `/cost` command shows API token usage and is intended for API users. Claude Max and Pro subscribers have usage included in their subscription, so `/cost` data isn't relevant for billing purposes. Subscribers can use `/stats` to view usage patterns.

The `/cost` command provides detailed token usage statistics for your current session:

```
Total cost:            $0.55
Total duration (API):  6m 19.7s
Total duration (wall): 6h 33m 10.2s
Total code changes:    0 lines added, 0 lines removed
```

## Managing costs for teams

When using Claude API, you can set workspace spend limits on the total Claude Code workspace spend. Admins can view cost and usage reporting in the Console.

When you first authenticate Claude Code with your Claude Console account, a workspace called "Claude Code" is automatically created for you. This workspace provides centralized cost tracking and management for all Claude Code usage in your organization. You cannot create API keys for this workspace; it is exclusively for Claude Code authentication and usage.

For organizations with custom rate limits, Claude Code traffic in this workspace counts toward your organization's overall API rate limits. You can set a workspace rate limit on this workspace's Limits page in the Claude Console to cap Claude Code's share and protect other production workloads.

On Bedrock, Vertex, and Foundry, Claude Code does not send metrics from your cloud. To get cost metrics, several large enterprises reported using LiteLLM, which is an open-source tool that helps companies track spend by key.

### Rate limit recommendations

When setting up Claude Code for teams, consider these Token Per Minute (TPM) and Request Per Minute (RPM) per-user recommendations based on your organization size:

| Team size     | TPM per user | RPM per user |
| ------------- | ------------ | ------------ |
| 1-5 users     | 200k-300k    | 5-7          |
| 5-20 users    | 100k-150k    | 2.5-3.5      |
| 20-50 users   | 50k-75k      | 1.25-1.75    |
| 50-100 users  | 25k-35k      | 0.62-0.87    |
| 100-500 users | 15k-20k      | 0.37-0.47    |
| 500+ users    | 10k-15k      | 0.25-0.35    |

The TPM per user decreases as team size grows because fewer users tend to use Claude Code concurrently in larger organizations.

### Agent team token costs

Agent teams spawn multiple Claude Code instances, each with its own context window. Token usage scales with the number of active teammates and how long each one runs.

To keep agent team costs manageable:

- Use Sonnet for teammates. It balances capability and cost for coordination tasks.
- Keep teams small. Each teammate runs its own context window, so token usage is roughly proportional to team size.
- Keep spawn prompts focused.
- Clean up teams when work is done. Active teammates continue consuming tokens even if idle.

## Reduce token usage

Token costs scale with context size: the more context Claude processes, the more tokens you use. Claude Code automatically optimizes costs through prompt caching (which reduces costs for repeated content like system prompts) and auto-compaction (which summarizes conversation history when approaching context limits).

### Manage context proactively

Use `/cost` to check your current token usage, or configure your status line to display it continuously.

- **Clear between tasks**: Use `/clear` to start fresh when switching to unrelated work. Stale context wastes tokens on every subsequent message. Use `/rename` before clearing so you can easily find the session later, then `/resume` to return to it.
- **Add custom compaction instructions**: `/compact Focus on code samples and API usage` tells Claude what to preserve during summarization.

You can also customize compaction behavior in your CLAUDE.md:

```markdown
# Compact instructions

When you are using compact, please focus on test output and code changes
```

### Choose the right model

Sonnet handles most coding tasks well and costs less than Opus. Reserve Opus for complex architectural decisions or multi-step reasoning. Use `/model` to switch models mid-session, or set a default in `/config`. For simple subagent tasks, specify `model: haiku` in your subagent configuration.

### Reduce MCP server overhead

MCP tool definitions are deferred by default, so only tool names enter context until Claude uses a specific tool. Run `/context` to see what's consuming space.

- **Prefer CLI tools when available**: Tools like `gh`, `aws`, `gcloud`, and `sentry-cli` are still more context-efficient than MCP servers because they don't add any per-tool listing.
- **Disable unused servers**: Run `/mcp` to see configured servers and disable any you're not actively using.

### Install code intelligence plugins for typed languages

Code intelligence plugins give Claude precise symbol navigation instead of text-based search, reducing unnecessary file reads when exploring unfamiliar code.

### Offload processing to hooks and skills

Custom hooks can preprocess data before Claude sees it. Instead of Claude reading a 10,000-line log file to find errors, a hook can grep for ERROR and return only matching lines, reducing context from tens of thousands of tokens to hundreds.

A skill can give Claude domain knowledge so it doesn't have to explore. For example, a "codebase-overview" skill could describe your project's architecture, key directories, and naming conventions.

### Move instructions from CLAUDE.md to skills

Your CLAUDE.md file is loaded into context at session start. If it contains detailed instructions for specific workflows (like PR reviews or database migrations), those tokens are present even when you're doing unrelated work. Skills load on-demand only when invoked, so moving specialized instructions into skills keeps your base context smaller. Aim to keep CLAUDE.md under 200 lines by including only essentials.

### Adjust extended thinking

Extended thinking is enabled by default because it significantly improves performance on complex planning and reasoning tasks. Thinking tokens are billed as output tokens. For simpler tasks where deep reasoning isn't needed, you can reduce costs by:
- lowering the effort level with `/effort` or in `/model`
- disabling thinking in `/config`
- lowering the budget with `MAX_THINKING_TOKENS=8000`

### Delegate verbose operations to subagents

Running tests, fetching documentation, or processing log files can consume significant context. Delegate these to subagents so the verbose output stays in the subagent's context while only a summary returns to your main conversation.

### Write specific prompts

Vague requests like "improve this codebase" trigger broad scanning. Specific requests like "add input validation to the login function in auth.ts" let Claude work efficiently with minimal file reads.

### Work efficiently on complex tasks

- **Use plan mode for complex tasks**: Press Shift+Tab to enter plan mode before implementation.
- **Course-correct early**: If Claude starts heading the wrong direction, press Escape to stop immediately. Use `/rewind` or double-tap Escape to restore conversation and code to a previous checkpoint.
- **Give verification targets**: Include test cases, paste screenshots, or define expected output in your prompt.
- **Test incrementally**: Write one file, test it, then continue.

## Background token usage

Claude Code uses tokens for some background functionality even when idle:

- **Conversation summarization**: Background jobs that summarize previous conversations for the `claude --resume` feature
- **Command processing**: Some commands like `/cost` may generate requests to check status

These background processes consume a small amount of tokens (typically under $0.04 per session) even without active interaction.
