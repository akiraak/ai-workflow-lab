---
url: https://github.com/anthropics/claude-code/blob/main/plugins/code-review/commands/code-review.md
fetched_at: 2026-04-06T06:00:00+09:00
---

# Code Review Command Definition

## Metadata
- Allowed Tools: Bash(gh issue view:*), Bash(gh search:*), Bash(gh issue list:*), Bash(gh pr comment:*), Bash(gh pr diff:*), Bash(gh pr view:*), Bash(gh pr list:*), mcp__github_inline_comment__create_inline_comment
- Description: Code review a pull request

## Overview

Provide a code review for the given pull request.

### Agent Assumptions:
- All tools are functional and will work without error
- Only call a tool if it is required to complete the task

## Step-by-Step Instructions

### Step 1: Initial Validation (Haiku Agent)
Launch a haiku agent to check if any of the following are true:
- The pull request is closed
- The pull request is a draft
- The pull request does not need code review (e.g. automated PR, trivial change)
- Claude has already commented on this PR

### Step 2: Identify CLAUDE.md Files (Haiku Agent)
Launch a haiku agent to return a list of file paths for all relevant CLAUDE.md files.

### Step 3: Summarize Changes (Sonnet Agent)
Launch a sonnet agent to view the pull request and return a summary.

### Step 4: Parallel Code Review (4 Agents)
Launch 4 agents in parallel to independently review the changes:

#### Agents 1 + 2: CLAUDE.md Compliance (Sonnet Agents)
Audit changes for CLAUDE.md compliance in parallel.

#### Agent 3: Bug Detection (Opus Agent)
Scan for obvious bugs. Focus only on the diff itself without reading extra context.

#### Agent 4: Security & Logic Issues (Opus Agent)
Look for problems in the introduced code - security issues, incorrect logic, etc.

#### Issue Flagging Criteria (HIGH SIGNAL ONLY)

**Flag issues where:**
- Code will fail to compile or parse (syntax errors, type errors, missing imports)
- Code will definitely produce wrong results regardless of inputs (clear logic errors)
- Clear, unambiguous CLAUDE.md violations with exact rule citation

**Do NOT flag:**
- Code style or quality concerns
- Potential issues depending on specific inputs or state
- Subjective suggestions or improvements

**Critical Rule:** If you are not certain an issue is real, do not flag it. False positives erode trust and waste reviewer time.

### Step 5: Issue Validation (Parallel Subagents)
For each issue found in Step 4 by agents 3 and 4, launch parallel subagents to validate:
- Use Opus subagents for bugs and logic issues
- Use Sonnet agents for CLAUDE.md violations

### Step 6: Filter Issues
Filter out any issues that were not validated in Step 5.

### Step 7: Output Summary
- If issues found: List each issue with brief description
- If no issues: State "No issues found. Checked for bugs and CLAUDE.md compliance."
- If --comment argument provided and issues found: Continue to Step 8

### Step 8: Plan Comments
Create a list of all comments to leave (internal only).

### Step 9: Post Inline Comments
Post inline comments for each issue with:
- Brief description of the issue
- For small fixes: committable suggestion block
- For larger fixes: describe without suggestion block
- Only ONE comment per unique issue

## False Positives to Avoid
- Pre-existing issues
- Correct code that appears buggy
- Pedantic nitpicks
- Issues linters will catch
- General code quality concerns (unless in CLAUDE.md)
- Issues silenced via lint ignore comments

## Comment Format (No Issues Found)

```
---
## Code review
No issues found. Checked for bugs and CLAUDE.md compliance.
---
```
