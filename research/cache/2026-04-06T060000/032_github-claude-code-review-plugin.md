---
url: https://github.com/anthropics/claude-code/blob/main/plugins/code-review/README.md
fetched_at: 2026-04-06T06:00:00+09:00
---

# Code Review Plugin

## Overview

The Code Review Plugin automates pull request review by launching multiple agents in parallel to independently audit changes from different perspectives. It uses confidence scoring to filter out false positives, ensuring only high-quality, actionable feedback is posted.

## Commands

### `/code-review`

Performs automated code review on a pull request using multiple specialized agents.

#### What it does:

1. Checks if review is needed (skips closed, draft, trivial, or already-reviewed PRs)
2. Gathers relevant CLAUDE.md guideline files from the repository
3. Summarizes the pull request changes
4. Launches 4 parallel agents to independently review:
   - **Agents #1 & #2**: Audit for CLAUDE.md compliance
   - **Agent #3**: Scan for obvious bugs in changes
   - **Agent #4**: Analyze git blame/history for context-based issues
5. Scores each issue 0-100 for confidence level
6. Filters out issues below 80 confidence threshold
7. Outputs review (to terminal by default, or as PR comment with `--comment` flag)

#### Usage:

```bash
/code-review [--comment]
```

#### Confidence scoring:

- **0**: Not confident, false positive
- **25**: Somewhat confident, might be real
- **50**: Moderately confident, real but minor
- **75**: Highly confident, real and important
- **100**: Absolutely certain, definitely real

#### False positives filtered:

- Pre-existing issues not introduced in PR
- Code that looks like a bug but isn't
- Pedantic nitpicks
- Issues linters will catch
- General quality issues (unless in CLAUDE.md)
- Issues with lint ignore comments

#### Review comment format:

```markdown
## Code review

Found 3 issues:

1. Missing error handling for OAuth callback (CLAUDE.md says "Always handle OAuth errors")
   https://github.com/owner/repo/blob/abc123.../src/auth.ts#L67-L72

2. Memory leak: OAuth state not cleaned up (bug due to missing cleanup in finally block)
   https://github.com/owner/repo/blob/abc123.../src/auth.ts#L88-L95

3. Inconsistent naming pattern (src/conventions/CLAUDE.md says "Use camelCase for functions")
   https://github.com/owner/repo/blob/abc123.../src/utils.ts#L23-L28
```

## Best Practices

- Maintain clear CLAUDE.md files for better compliance checking
- Trust the 80+ confidence threshold - false positives are filtered
- Run on all non-trivial pull requests
- Review agent findings as a starting point for human review
- Update CLAUDE.md based on recurring review patterns

## Tips

- Write specific CLAUDE.md files: Clear guidelines = better reviews
- Include context in PRs: Helps agents understand intent
- Use confidence scores: Issues ≥80 are usually correct
- Iterate on guidelines: Update CLAUDE.md based on patterns
- Review automatically: Set up as part of PR workflow
- Trust the filtering: Threshold prevents noise

### Adjusting confidence threshold

The default threshold is 80. To adjust, modify the command file to change the threshold (0-100).

### Customizing review focus

Edit the command file to add or modify agent tasks:
- Add security-focused agents
- Add performance analysis agents
- Add accessibility checking agents
- Add documentation quality checks

Author: Boris Cherny (boris@anthropic.com)
