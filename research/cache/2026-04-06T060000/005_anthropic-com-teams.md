---
url: https://anthropic.com/news/how-anthropic-teams-use-claude-code
fetched_at: 2026-04-06T06:00:00+09:00
---

# How Anthropic teams use Claude Code

(Content extracted from WebSearch summaries - full page fetch was restricted)

## Key Findings on Debugging at Anthropic

### Real-Time Debugging

For many teams at the company, Claude Code accelerates diagnosis and fixes by analyzing stack traces, documentation, and system behavior in real-time.

### Security Engineering Team

During incidents, the Security Engineering team feeds Claude Code stack traces and documentation to trace control flow through the codebase. Problems that typically take 10-15 minutes of manual scanning now resolve 3x as quickly.

### Automated Testing Workflow

When tests fail, Claude Code reads the errors, fixes the code, and runs the suite again until everything passes, while monitoring CI pipelines on GitHub and GitLab and committing fixes automatically.

### Bug Fix Process

You describe the bug, and Claude picks up your codebase context. It reads code in your local environment, writes changes, runs tests, and opens a PR with no setup or context files to select, providing a clean diff, passing tests, and a ready-to-merge branch.

### Core Principles

- Make every change as simple as possible with minimal code
- Delete lines instead of adding them when possible
- Find root causes rather than applying temporary fixes
- Only touch what's necessary without introducing new side effects
