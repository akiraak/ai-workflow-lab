---
url: https://platform.claude.com/docs/en/about-claude/pricing
fetched_at: 2026-04-09T10:00:00+09:00
---

# Pricing

Learn about Anthropic's pricing structure for models and features. All prices are in USD.

## Model pricing

| Model             | Base Input Tokens | 5m Cache Writes | 1h Cache Writes | Cache Hits & Refreshes | Output Tokens |
|-------------------|-------------------|-----------------|-----------------|----------------------|---------------|
| Claude Opus 4.6     | $5 / MTok         | $6.25 / MTok    | $10 / MTok      | $0.50 / MTok | $25 / MTok    |
| Claude Opus 4.5   | $5 / MTok         | $6.25 / MTok    | $10 / MTok      | $0.50 / MTok | $25 / MTok    |
| Claude Opus 4.1   | $15 / MTok        | $18.75 / MTok   | $30 / MTok      | $1.50 / MTok | $75 / MTok    |
| Claude Opus 4     | $15 / MTok        | $18.75 / MTok   | $30 / MTok      | $1.50 / MTok | $75 / MTok    |
| Claude Sonnet 4.6   | $3 / MTok         | $3.75 / MTok    | $6 / MTok       | $0.30 / MTok | $15 / MTok    |
| Claude Sonnet 4.5   | $3 / MTok         | $3.75 / MTok    | $6 / MTok       | $0.30 / MTok | $15 / MTok    |
| Claude Sonnet 4   | $3 / MTok         | $3.75 / MTok    | $6 / MTok       | $0.30 / MTok | $15 / MTok    |
| Claude Haiku 4.5  | $1 / MTok         | $1.25 / MTok    | $2 / MTok       | $0.10 / MTok | $5 / MTok     |
| Claude Haiku 3.5  | $0.80 / MTok      | $1 / MTok       | $1.6 / MTok     | $0.08 / MTok | $4 / MTok     |
| Claude Haiku 3    | $0.25 / MTok      | $0.30 / MTok    | $0.50 / MTok    | $0.03 / MTok | $1.25 / MTok  |

MTok = Million tokens.

## Prompt caching

Prompt caching reduces costs and latency by reusing previously processed portions of your prompt across API calls.

Prompt caching pricing multipliers relative to base input token rates:

| Cache operation | Multiplier | Duration |
|:----------------|:-----------|:---------|
| 5-minute cache write | 1.25x base input price | Cache valid for 5 minutes |
| 1-hour cache write | 2x base input price | Cache valid for 1 hour |
| Cache read (hit) | 0.1x base input price | Same duration as the preceding write |

A cache hit costs 10% of the standard input price, meaning caching pays off after just one cache read for the 5-minute duration (1.25x write), or after two cache reads for the 1-hour duration (2x write).

## Data residency pricing

For Claude Opus 4.6 and newer models, specifying US-only inference via the `inference_geo` parameter incurs a 1.1x multiplier on all token pricing categories.

## Fast mode pricing

Fast mode (beta: research preview) for Claude Opus 4.6 provides significantly faster output at premium pricing (6x standard rates).

| Input | Output |
|:------|:-------|
| $30 / MTok | $150 / MTok |

Fast mode pricing stacks with other pricing modifiers (prompt caching multipliers, data residency multipliers). Fast mode is not available with the Batch API.

## Batch processing

The Batch API allows asynchronous processing of large volumes of requests with a 50% discount on both input and output tokens.

| Model             | Batch input      | Batch output    |
|-------------------|------------------|-----------------|
| Claude Opus 4.6       | $2.50 / MTok     | $12.50 / MTok   |
| Claude Sonnet 4.6   | $1.50 / MTok     | $7.50 / MTok    |
| Claude Haiku 4.5  | $0.50 / MTok     | $2.50 / MTok    |

## Long context pricing

Opus 4.6 and Sonnet 4.6 include the full 1M token context window at standard pricing. No premium for tokens beyond 200K.

## Tool use pricing

Tool use requests are priced based on total input tokens (including the `tools` parameter) and output tokens generated. Server-side tools may incur additional charges.

## Web search tool

Web search is available on the Claude API for **$10 per 1,000 searches**, plus standard token costs.

## Web fetch tool

Web fetch is available at **no additional cost**. Only standard token costs for fetched content.

## Cost optimization strategies

1. **Use appropriate models:** Choose Haiku for simple tasks, Sonnet for complex reasoning
2. **Implement prompt caching:** Reduce costs for repeated context
3. **Batch operations:** Use the Batch API for non-time-sensitive tasks
4. **Monitor usage patterns:** Track token consumption to identify optimization opportunities
