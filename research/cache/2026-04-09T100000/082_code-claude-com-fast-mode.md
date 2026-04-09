---
url: https://code.claude.com/docs/en/fast-mode
fetched_at: 2026-04-09T10:00:00+09:00
---

# Speed up responses with fast mode

> Get faster Opus 4.6 responses in Claude Code by toggling fast mode.

Note: Fast mode is in research preview. The feature, pricing, and availability may change based on feedback.

Fast mode is a high-speed configuration for Claude Opus 4.6, making the model 2.5x faster at a higher cost per token. Toggle it on with `/fast` when you need speed for interactive work like rapid iteration or live debugging, and toggle it off when cost matters more than latency.

Fast mode is not a different model. It uses the same Opus 4.6 with a different API configuration that prioritizes speed over cost efficiency. You get identical quality and capabilities, just faster responses.

Requires Claude Code v2.1.36 or later.

What to know:

- Use `/fast` to toggle on fast mode in Claude Code CLI. Also available via `/fast` in Claude Code VS Code Extension.
- Fast mode for Opus 4.6 pricing is $30/150 MTok.
- Available to all Claude Code users on subscription plans (Pro/Max/Team/Enterprise) and Claude Console.
- For subscription plan users, fast mode is available via extra usage only and not included in the subscription rate limits.

## Toggle fast mode

Toggle fast mode in either of these ways:

- Type `/fast` and press Tab to toggle on or off
- Set `"fastMode": true` in your user settings file

By default, fast mode persists across sessions. Administrators can configure fast mode to reset each session.

For the best cost efficiency, enable fast mode at the start of a session rather than switching mid-conversation (switching mid-conversation means paying full fast mode uncached input token price for the entire conversation context).

When you enable fast mode:

- If you're on a different model, Claude Code automatically switches to Opus 4.6
- You'll see a confirmation message: "Fast mode ON"
- A small `↯` icon appears next to the prompt while fast mode is active

When you disable fast mode with `/fast` again, you remain on Opus 4.6. The model does not revert to your previous model.

## Understand the cost tradeoff

| Mode                  | Input (MTok) | Output (MTok) |
| --------------------- | ------------ | ------------- |
| Fast mode on Opus 4.6 | $30          | $150          |

Fast mode pricing is flat across the full 1M token context window.

When you switch into fast mode mid-conversation, you pay the full fast mode uncached input token price for the entire conversation context. This costs more than if you had enabled fast mode from the start.

## Decide when to use fast mode

Fast mode is best for:
- Rapid iteration on code changes
- Live debugging sessions
- Time-sensitive work with tight deadlines

Standard mode is better for:
- Long autonomous tasks where speed matters less
- Batch processing or CI/CD pipelines
- Cost-sensitive workloads

### Fast mode vs effort level

| Setting                | Effect                                                                    |
| ---------------------- | ------------------------------------------------------------------------- |
| **Fast mode**          | Same model quality, lower latency, higher cost                            |
| **Lower effort level** | Less thinking time, faster responses, potentially lower quality on complex tasks |

You can combine both: use fast mode with a lower effort level for maximum speed on straightforward tasks.

## Requirements

- **Not available on third-party cloud providers**: fast mode is not available on Amazon Bedrock, Google Vertex AI, or Microsoft Azure Foundry.
- **Extra usage enabled**: your account must have extra usage enabled, which allows billing beyond your plan's included usage.
- **Admin enablement for Team and Enterprise**: fast mode is disabled by default for Team and Enterprise organizations.

Fast mode usage is billed directly to extra usage, even if you have remaining usage on your plan. Fast mode tokens do not count against your plan's included usage.

## Handle rate limits

Fast mode has separate rate limits from standard Opus 4.6. When you hit the fast mode rate limit or run out of extra usage:

1. Fast mode automatically falls back to standard Opus 4.6
2. The `↯` icon turns gray to indicate cooldown
3. You continue working at standard speed and pricing
4. When the cooldown expires, fast mode automatically re-enables
