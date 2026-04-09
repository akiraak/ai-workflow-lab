---
url: https://systemprompt.io/guides/claude-code-github-actions
fetched_at: 2026-04-09T10:00:00+09:00
---

# Claude Code GitHub Actions: 5 Copy-Paste Workflow Recipes for CI/CD

## Overview

This comprehensive guide covers five production-tested GitHub Actions workflows for Claude Code CI/CD integration. The article demonstrates how to automate PR reviews, issue-to-PR workflows, documentation updates, test generation, and release notes using `anthropics/claude-code-action@v1`.

## Key Setup Requirements

**API Key Storage:** Store your `ANTHROPIC_API_KEY` as a repository secret under Settings > Secrets and variables > Actions. Never hardcode the key, log it, or pass it as a visible workflow input.

**Basic Workflow Structure:**
```yaml
name: Claude Code Review
on:
  pull_request:
    types: [opened, synchronize]

jobs:
  review:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: anthropics/claude-code-action@v1
        with:
          anthropic_api_key: ${{ secrets.ANTHROPIC_API_KEY }}
          prompt: "Review this PR for bugs, security issues, and code quality."
```

## Five Recipe Patterns

### Recipe 1: Automated PR Code Review

Triggers on pull request events with `types: [opened, synchronize]`. Uses `paths-ignore` to skip documentation changes and reduces noise by explicitly excluding style feedback from the prompt.

### Recipe 2: Issue-to-PR Automation

Triggered by `issue_comment` events when `@claude` is mentioned. Claude reads the issue, implements changes on a new branch, and opens a PR. Works best for small, well-defined tasks.

### Recipe 3: Documentation Updates

Runs on pushes to main when source code changes. Uses `fetch-depth: 2` to compare with the previous commit and automatically updates documentation to match API changes.

### Recipe 4: Test Generation

Activates on PR creation (not subsequent pushes) for changed source files. Path filters prevent infinite loops by excluding test file modifications from triggering the workflow.

### Recipe 5: Release Notes Generation

Triggered by release creation events. Requires `fetch-depth: 0` to access full git history for comparing tags and summarizing changes in user-friendly language.

## Critical Configuration Details

**Permissions Block:**
```yaml
permissions:
  contents: write
  pull-requests: write
  issues: read
```

**Concurrency Control:** Set concurrency groups with `cancel-in-progress: true` to avoid redundant runs on rapid successive pushes.

**Cost Management:** Multiple strategies reduce expenses including filtering by path, using appropriate model tiers, and limiting triggers to specific event types.

## Security Considerations

Fork PRs lack secret access by default, preventing untrusted contributors from consuming API credits. For cross-fork support, use `pull_request_target` with extreme caution. Ensure prompts contain clear instructions that take precedence over user-supplied content to prevent injection attacks.

## The @claude Mention Pattern

Simple trigger: `if: contains(github.event.comment.body, '@claude')`

This pattern allows team members to request Claude's assistance by mentioning it in issue comments or PR discussions.

## Advanced Implementation Patterns

**Multi-step Workflows:** Chain multiple Claude invocations where each step builds on previous outputs.

**Conditional Execution:** Use job outputs and filters to run Claude only when specific files or conditions trigger.

**CLAUDE.md Configuration:** Repository instructions apply to both local and CI contexts, with CI-specific overrides possible through workflow prompts.

## Debugging and Monitoring

Common failure points: authentication errors, rate limiting, timeout issues, checkout problems, permission errors. Use `workflow_dispatch` as additional trigger during development for manual testing.

## Key Takeaways

The quality of automation depends directly on prompt specificity. Generic prompts produce unhelpful feedback, while detailed prompts yield actionable results. CI-based Claude integration complements rather than replaces human review.
