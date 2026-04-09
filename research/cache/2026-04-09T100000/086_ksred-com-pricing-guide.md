---
url: https://www.ksred.com/claude-code-pricing-guide-which-plan-actually-saves-you-money/
fetched_at: 2026-04-09T10:00:00+09:00
---

# Claude Code Pricing Guide: Which Plan Saves You Money

## Overview

Kyle Redelinghuys analyzed eight months of Claude Code usage (June 2025 - February 2026) totaling approximately 10 billion tokens to compare subscription plans with API pricing.

## Key Findings

### Cost Comparison
- **API equivalent cost**: Over $15,000
- **Actual subscription cost**: ~$800 (Max plan)
- **Savings**: 93%

"I've been paying roughly $100/month on the Max plan, so around $800 total. That's a 93% saving."

### Monthly Usage Breakdown

| Period | Tokens | API Equivalent | Subscription Cost |
|--------|--------|----------------|-------------------|
| June 2025 | 421M | $897 | ~$100 |
| July 2025 | 2.4B | $5,623 | ~$100 |
| August 2025 | 320M | $771 | ~$100 |
| Oct-Dec 2025 | ~5B est | ~$4,600 | ~$300 |
| Jan-Feb 2026 | ~1.5B est | ~$3,000 | ~$200 |

## The $5,623 Month

July 2025 represented peak usage with 201 sessions across 45+ projects. The author was building analytics dashboards, profiling tools, and email infrastructure simultaneously.

Most intensive day: January 22, 2026 with 8,930 messages across 9 sessions and 2,169 tool calls.

## Token Usage Composition

The breakdown:
- **Cache reads**: Over 90% of total tokens
- **Cache writes**: Approximately 6%
- **Input/output tokens**: Under 1% combined

"If my 4.5 billion cache reads had been billed as fresh input tokens at the Opus rate of $15 per million, the bill would have been $67,500 instead of $6,750."

## Breakeven Analysis

The subscription becomes economical when monthly API costs exceed the plan's price:

- **Light** (under 50M tokens/month): Under $100 on API → Pro or pay-as-you-go works
- **Medium** (50-200M tokens/month): $100-400 on API → Max 5x optimal
- **Heavy** (200M-1B tokens/month): $400-2,000 on API → Max saves hundreds
- **Power** (1B+ tokens/month): $2,000+ on API → Max saves thousands

## Model Selection Impact

Usage was approximately 95% Opus (most expensive model). Using Sonnet at $3/$15 instead would reduce API costs by roughly 40%, though on subscription plans model choice doesn't affect billing.

## Finding Your Own Usage Data

API users can access costs through Anthropic's dashboard. Subscription users must examine local files in `~/.claude/` directory to parse JSONL files for token usage and session data.

## Verdict

For developers relying on Claude Code with Opus models, the Max subscription represents substantial value. The single highest-usage month ($5,623 API equivalent) exceeds four and a half years of Max 5x subscription costs.

Recommendation: Track usage for several weeks if considering the subscription versus API pricing model.
