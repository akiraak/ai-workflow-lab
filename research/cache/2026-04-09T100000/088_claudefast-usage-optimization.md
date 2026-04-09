---
url: https://claudefa.st/blog/guide/development/usage-optimization
fetched_at: 2026-04-09T10:00:00+09:00
---

# Claude Code Pricing: Optimize Your Token Usage & Costs

## Overview

This guide teaches developers how to reduce Claude Code expenses by up to 70% through strategic model selection and usage tracking. The core recommendation is installing `ccusage` to monitor token consumption patterns.

## Subscription Tiers

- **Claude Pro ($20/month)**: Minimum requirement for Claude Code access, providing 5x free tier limits and roughly 45 messages per 5-hour window.
- **Claude Max 5x ($100/month)**: 5x Pro limits (~225 messages/5hr) with generous Opus access.
- **Claude Max 20x ($200/month)**: 20x Pro limits (~900 messages/5hr) for heavy daily usage.
- **API Pay-per-Use**: Sonnet costs $3/$15 per million input/output tokens; Opus runs $5/$25 per million tokens.

## Key Optimization Commands

### Model Switching
```bash
/model sonnet   # Default for most tasks
/model opus     # Complex architecture only
```

Start sessions with Sonnet, switching to Opus only when deep analysis is necessary.

### Context Management
```bash
/compact    # Compress when context grows lengthy
/clear      # Reset for unrelated work
```

### Planning Mode
Press **Shift+Tab** twice to enter plan mode before expensive operations.

## Usage Tracking with ccusage

Monitor consumption patterns:
```bash
ccusage daily              # Daily breakdown
ccusage monthly            # Monthly aggregation
ccusage blocks --live      # Real-time 5-hour windows
ccusage daily --breakdown  # Per-model cost analysis
```

Filter by date range to investigate spending spikes:
```bash
ccusage daily --since 20250101 --until 20250131
```

## Cost-Saving Patterns

- **Specific prompts beat vague requests**: "optimize readability in src/auth.js" generates immediate results versus "make this better" which wastes tokens on clarification.
- **Batch related tasks**: Combine updates across multiple files in single requests.
- **Avoid expensive patterns**: Extended debugging sessions, repeated explanations, full codebase reviews.

Context bloat from irrelevant instructions represents the biggest hidden cost. A skills architecture that loads domain knowledge on-demand recovers approximately 15,000 tokens per session (82% improvement over loading everything upfront).

## Environment Variables

### Reduce Non-Essential Calls
```bash
export DISABLE_NON_ESSENTIAL_MODEL_CALLS=1
```
Disables background model calls for suggestions and tips without affecting core workflows.

### The opusplan Strategy
```bash
claude --model opusplan
```
Hybrid approach: Opus during planning phases for complex reasoning, then automatically switches to Sonnet for code generation. Maximizes reasoning quality while controlling costs.

## Key Takeaways

Most developers achieve 40-70% cost reductions by implementing these strategies systematically:
1. Install and run ccusage for baseline consumption data
2. Master context management techniques
3. Configure model selection for your workflow
4. Review troubleshooting guides to avoid expensive debugging cycles
