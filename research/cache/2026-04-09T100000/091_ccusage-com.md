---
url: https://ccusage.com/
fetched_at: 2026-04-09T10:00:00+09:00
---

# ccusage - Claude Code Usage Analysis Tool

## Overview

ccusage is a command-line interface tool designed to analyze Claude Code usage from locally stored JSONL files. The tool provides comprehensive reporting capabilities for tracking token consumption and associated costs.

## Key Features

- **Daily Reports**: View token usage and costs aggregated by date with detailed breakdowns
- **Weekly Reports**: Track usage patterns by week with configurable start day
- **Monthly Reports**: Analyze usage patterns over monthly periods with cost tracking
- **Session Reports**: Group usage by conversation sessions for detailed analysis
- **5-Hour Blocks**: Track usage within Claude's billing windows with active monitoring
- **Model Tracking**: Identify which Claude models are being used (Opus, Sonnet, etc.)
- **Enhanced Display**: Beautiful tables with responsive layout and smart formatting
- **JSON Output**: Export data in structured JSON format for programmatic use
- **Cost Analysis**: Shows estimated costs in USD for each reporting period
- **Cache Support**: Tracks cache creation and cache read tokens separately
- **Offline Mode**: Use pre-cached pricing data without network connectivity
- **MCP Integration**: Built-in Model Context Protocol server for tool integration

## Usage Examples

```bash
ccusage daily              # Daily breakdown
ccusage weekly             # Weekly aggregation
ccusage monthly            # Monthly aggregation
ccusage blocks --live      # Real-time 5-hour windows
ccusage daily --breakdown  # Per-model cost analysis
ccusage daily --since 20250101 --until 20250131  # Date range filter
```

## Installation

Available on npm: https://www.npmjs.com/package/ccusage
GitHub repository: https://github.com/ryoppippi/ccusage

## License

Released under the MIT License. Copyright 2025 ryoppippi
