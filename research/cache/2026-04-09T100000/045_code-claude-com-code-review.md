---
url: https://code.claude.com/docs/en/code-review
fetched_at: 2026-04-09T10:00:00+09:00
---

# Code Review

> Set up automated PR reviews that catch logic errors, security vulnerabilities, and regressions using multi-agent analysis of your full codebase

> Note: Code Review is in research preview, available for Team and Enterprise subscriptions. It is not available for organizations with Zero Data Retention enabled.

Code Review analyzes your GitHub pull requests and posts findings as inline comments on the lines of code where it found issues. A fleet of specialized agents examine the code changes in the context of your full codebase, looking for logic errors, security vulnerabilities, broken edge cases, and subtle regressions.

Findings are tagged by severity and don't approve or block your PR, so existing review workflows stay intact. You can tune what Claude flags by adding a `CLAUDE.md` or `REVIEW.md` file to your repository.

## How reviews work

Reviews trigger when a PR opens, on every push, or when manually requested. Multiple agents analyze the diff and surrounding code in parallel on Anthropic infrastructure. Each agent looks for a different class of issue, then a verification step checks candidates against actual code behavior to filter out false positives. Results are deduplicated, ranked by severity, and posted as inline comments.

### Severity levels

| Marker | Severity     | Meaning                                                             |
| :----- | :----------- | :------------------------------------------------------------------ |
| 🔴     | Important    | A bug that should be fixed before merging                           |
| 🟡     | Nit          | A minor issue, worth fixing but not blocking                        |
| 🟣     | Pre-existing | A bug that exists in the codebase but was not introduced by this PR |

### Rate and reply to findings

Each review comment arrives with thumbs up/down for one-click rating. Anthropic collects reaction counts after the PR merges to tune the reviewer. Replying to an inline comment does not prompt Claude to respond.

### Check run output

Each review populates the **Claude Code Review** check run. The check run always completes with a neutral conclusion so it never blocks merging through branch protection rules.

Machine-readable severity data can be extracted:

```bash
gh api repos/OWNER/REPO/check-runs/CHECK_RUN_ID \
  --jq '.output.text | split("bughunter-severity: ")[1] | split(" -->")[0] | fromjson'
```

## Set up Code Review

1. Go to claude.ai/admin-settings/claude-code and find the Code Review section
2. Click Setup to begin the GitHub App installation flow
3. Install the Claude GitHub App to your GitHub organization
4. Select repositories to enable
5. Set review triggers per repo:
   - **Once after PR creation**
   - **After every push**
   - **Manual**: reviews start only when someone comments `@claude review`

## Manually trigger reviews

| Command               | What it does                                                                  |
| :-------------------- | :---------------------------------------------------------------------------- |
| `@claude review`      | Starts a review and subscribes the PR to push-triggered reviews going forward |
| `@claude review once` | Starts a single review without subscribing the PR to future pushes            |

## Customize reviews

### CLAUDE.md

Code Review reads your repository's CLAUDE.md files and treats newly-introduced violations as nit-level findings.

### REVIEW.md

Add a REVIEW.md file to your repository root for review-specific rules:

```markdown
# Code Review Guidelines

## Always check
- New API endpoints have corresponding integration tests
- Database migrations are backward-compatible
- Error messages don't leak internal details to users

## Style
- Prefer `match` statements over chained `isinstance` checks
- Use structured logging, not f-string interpolation in log calls

## Skip
- Generated files under `src/gen/`
- Formatting-only changes in `*.lock` files
```

## Pricing

Code Review is billed based on token usage. Each review averages $15-25 in cost, scaling with PR size, codebase complexity, and how many issues require verification. Usage is billed separately through extra usage.

## Troubleshooting

### Retrigger a failed or timed-out review

Comment `@claude review once` on the PR.

### Find issues that aren't showing as inline comments

Check:
- Check run Details
- Files changed annotations
- Review body under "Additional findings"
