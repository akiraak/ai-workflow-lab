---
url: https://code.claude.com/docs/en/code-review
fetched_at: 2026-04-06T06:00:00+09:00
---

# Code Review

> Set up automated PR reviews that catch logic errors, security vulnerabilities, and regressions using multi-agent analysis of your full codebase

Code Review is in research preview, available for Team and Enterprise subscriptions.

Code Review analyzes your GitHub pull requests and posts findings as inline comments on the lines of code where it found issues. A fleet of specialized agents examine the code changes in the context of your full codebase, looking for logic errors, security vulnerabilities, broken edge cases, and subtle regressions.

Findings are tagged by severity and don't approve or block your PR, so existing review workflows stay intact. You can tune what Claude flags by adding a `CLAUDE.md` or `REVIEW.md` file to your repository.

## How reviews work

Once an admin enables Code Review for your organization, reviews trigger when a PR opens, on every push, or when manually requested, depending on the repository's configured behavior. Commenting `@claude review` starts reviews on a PR in any mode.

When a review runs, multiple agents analyze the diff and surrounding code in parallel on Anthropic infrastructure. Each agent looks for a different class of issue, then a verification step checks candidates against actual code behavior to filter out false positives. The results are deduplicated, ranked by severity, and posted as inline comments on the specific lines where issues were found.

### Severity levels

| Marker | Severity     | Meaning                                                             |
| :----- | :----------- | :------------------------------------------------------------------ |
| 🔴     | Important    | A bug that should be fixed before merging                           |
| 🟡     | Nit          | A minor issue, worth fixing but not blocking                        |
| 🟣     | Pre-existing | A bug that exists in the codebase but was not introduced by this PR |

### What Code Review checks

By default, Code Review focuses on correctness: bugs that would break production, not formatting preferences or missing test coverage. You can expand what it checks by adding guidance files to your repository.

## Customize reviews

Code Review reads two files from your repository to guide what it flags. Both are additive on top of the default correctness checks:

* **`CLAUDE.md`**: shared project instructions that Claude Code uses for all tasks, not just reviews. Use it when guidance also applies to interactive Claude Code sessions.
* **`REVIEW.md`**: review-only guidance, read exclusively during code reviews. Use it for rules that are strictly about what to flag or skip during review and would clutter your general `CLAUDE.md`.

### REVIEW.md

Add a `REVIEW.md` file to your repository root for review-specific rules. Use it to encode:

* Company or team style guidelines: "prefer early returns over nested conditionals"
* Language- or framework-specific conventions not covered by linters
* Things Claude should always flag: "any new API route must have an integration test"
* Things Claude should skip: "don't comment on formatting in generated code under `/gen/`"

Example `REVIEW.md`:

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

Claude auto-discovers `REVIEW.md` at the repository root. No configuration needed.

## Manually trigger reviews

| Command               | What it does                                                                  |
| :-------------------- | :---------------------------------------------------------------------------- |
| `@claude review`      | Starts a review and subscribes the PR to push-triggered reviews going forward |
| `@claude review once` | Starts a single review without subscribing the PR to future pushes            |

## Review Behavior options

* **Once after PR creation**: review runs once when a PR is opened or marked ready for review
* **After every push**: review runs on every push to the PR branch
* **Manual**: reviews start only when someone comments `@claude review`

## Check run output

Each review populates the Claude Code Review check run. Findings include a severity table:

| Severity     | File:Line                 | Issue                                                          |
| ------------ | ------------------------- | -------------------------------------------------------------- |
| 🔴 Important | `src/auth/session.ts:142` | Token refresh races with logout, leaving stale sessions active |
| 🟡 Nit       | `src/auth/session.ts:88`  | `parseExpiry` silently returns 0 on malformed input            |

The check run always completes with a neutral conclusion so it never blocks merging through branch protection rules.

Machine-readable severity output:

```bash
gh api repos/OWNER/REPO/check-runs/CHECK_RUN_ID \
  --jq '.output.text | split("bughunter-severity: ")[1] | split(" -->")[0] | fromjson'
```

Returns: `{"normal": 2, "nit": 1, "pre_existing": 0}`
