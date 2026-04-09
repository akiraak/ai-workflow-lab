---
url: https://github.com/anthropics/claude-code-action/blob/main/docs/solutions.md
fetched_at: 2026-04-09T10:00:00+09:00
---

# Solutions & Use Cases

This guide provides complete, ready-to-use solutions for common automation scenarios with Claude Code Action. Each solution includes working examples, configuration details, and expected outcomes.

## Table of Contents

- Automatic PR Code Review
- Review Only Specific File Paths
- Review PRs from External Contributors
- Custom PR Review Checklist
- Scheduled Repository Maintenance
- Issue Auto-Triage and Labeling
- Documentation Sync on API Changes
- Security-Focused PR Reviews

## Automatic PR Code Review

**When to use:** Automatically review every PR opened or updated in your repository.

### Basic Example (No Tracking)

```yaml
name: Claude Auto Review
on:
  pull_request:
    types: [opened, synchronize]

jobs:
  review:
    runs-on: ubuntu-latest
    permissions:
      contents: read
      pull-requests: write
      id-token: write
    steps:
      - uses: actions/checkout@v6
        with:
          fetch-depth: 1

      - uses: anthropics/claude-code-action@v1
        with:
          anthropic_api_key: ${{ secrets.ANTHROPIC_API_KEY }}
          prompt: |
            REPO: ${{ github.repository }}
            PR NUMBER: ${{ github.event.pull_request.number }}

            Please review this pull request with a focus on:
            - Code quality and best practices
            - Potential bugs or issues
            - Security implications
            - Performance considerations

            Use `gh pr comment` for top-level feedback.
            Use `mcp__github_inline_comment__create_inline_comment` (with `confirmed: true`) to highlight specific code issues.
            Only post GitHub comments - don't submit review text as messages.

          claude_args: |
            --allowedTools "mcp__github_inline_comment__create_inline_comment,Bash(gh pr comment:*),Bash(gh pr diff:*),Bash(gh pr view:*)"
```

### Enhanced Example (With Progress Tracking)

```yaml
- uses: anthropics/claude-code-action@v1
  with:
    anthropic_api_key: ${{ secrets.ANTHROPIC_API_KEY }}
    track_progress: true
    prompt: |
      REPO: ${{ github.repository }}
      PR NUMBER: ${{ github.event.pull_request.number }}
      Please review this pull request...
```

## Review Only Specific File Paths

```yaml
name: Review Critical Files
on:
  pull_request:
    types: [opened, synchronize]
    paths:
      - "src/auth/**"
      - "src/api/**"
      - "config/security.yml"

jobs:
  security-review:
    runs-on: ubuntu-latest
    steps:
      - uses: anthropics/claude-code-action@v1
        with:
          anthropic_api_key: ${{ secrets.ANTHROPIC_API_KEY }}
          prompt: |
            This PR modifies critical authentication or API files.
            Please provide a security-focused review...
```

## Review PRs from External Contributors

```yaml
jobs:
  external-review:
    if: github.event.pull_request.author_association == 'FIRST_TIME_CONTRIBUTOR'
    runs-on: ubuntu-latest
    steps:
      - uses: anthropics/claude-code-action@v1
        with:
          prompt: |
            This is a first-time contribution from @${{ github.event.pull_request.user.login }}.
            Please provide a comprehensive review focusing on:
            - Compliance with project coding standards
            - Proper test coverage
            - Documentation for new features
            - Potential breaking changes
```

## Custom PR Review Checklist

```yaml
prompt: |
  Review this PR against our team checklist:
  ## Code Quality
  - [ ] Code follows our style guide
  - [ ] No commented-out code
  - [ ] Meaningful variable names
  - [ ] DRY principle followed
  ## Testing
  - [ ] Unit tests for new functions
  - [ ] Integration tests for new endpoints
  - [ ] Edge cases covered
  - [ ] Test coverage > 80%
  ## Documentation
  - [ ] README updated if needed
  - [ ] API docs updated
  - [ ] Inline comments for complex logic
  ## Security
  - [ ] No hardcoded credentials
  - [ ] Input validation implemented
  - [ ] Proper error handling
  - [ ] No sensitive data in logs
```

## Scheduled Repository Maintenance

```yaml
name: Weekly Maintenance
on:
  schedule:
    - cron: "0 0 * * 0"
  workflow_dispatch:

jobs:
  maintenance:
    runs-on: ubuntu-latest
    steps:
      - uses: anthropics/claude-code-action@v1
        with:
          prompt: |
            Perform weekly repository maintenance:
            1. Check for outdated dependencies in package.json
            2. Scan for security vulnerabilities using `npm audit`
            3. Review open issues older than 90 days
            4. Check for TODO comments in recent commits
            5. Verify README.md examples still work
            Create a single issue summarizing any findings.
          claude_args: |
            --allowedTools "Read,Bash(npm:*),Bash(gh issue:*),Bash(git:*)"
```

## Issue Auto-Triage and Labeling

```yaml
name: Issue Triage
on:
  issues:
    types: [opened]

jobs:
  triage:
    runs-on: ubuntu-latest
    steps:
      - uses: anthropics/claude-code-action@v1
        with:
          prompt: |
            Analyze this new issue and:
            1. Determine if it's a bug report, feature request, or question
            2. Assess priority (critical, high, medium, low)
            3. Suggest appropriate labels
            4. Check if it duplicates existing issues
```

## Documentation Sync on API Changes

```yaml
name: Sync API Documentation
on:
  pull_request:
    types: [opened, synchronize]
    paths:
      - "src/api/**/*.ts"
      - "src/routes/**/*.ts"

jobs:
  doc-sync:
    runs-on: ubuntu-latest
    steps:
      - uses: anthropics/claude-code-action@v1
        with:
          prompt: |
            This PR modifies API endpoints. Please:
            1. Review the API changes
            2. Update API.md to document any new or changed endpoints
            3. Ensure OpenAPI spec is updated if needed
            4. Update example requests/responses
            Commit any documentation updates to this PR branch.
          claude_args: |
            --allowedTools "Read,Write,Edit,Bash(git:*)"
```

## Security-Focused PR Reviews

```yaml
prompt: |
  Perform a comprehensive security review:
  ## OWASP Top 10 Analysis
  - SQL Injection vulnerabilities
  - Cross-Site Scripting (XSS)
  - Broken Authentication
  - Sensitive Data Exposure
  - XML External Entities (XXE)
  - Broken Access Control
  - Security Misconfiguration
  - Cross-Site Request Forgery (CSRF)
  - Using Components with Known Vulnerabilities
  - Insufficient Logging & Monitoring
  ## Additional Security Checks
  - Hardcoded secrets or credentials
  - Insecure cryptographic practices
  - Unsafe deserialization
  - Server-Side Request Forgery (SSRF)
  - Race conditions or TOCTOU issues
  Rate severity as: CRITICAL, HIGH, MEDIUM, LOW, or NONE.
```

## Tips for All Solutions

### Always Include GitHub Context

```yaml
prompt: |
  REPO: ${{ github.repository }}
  PR NUMBER: ${{ github.event.pull_request.number }}
  [Your specific instructions]
```

### Common Tool Permissions

- **PR Comments**: `Bash(gh pr comment:*)`
- **Inline Comments**: `mcp__github_inline_comment__create_inline_comment` (pass `confirmed: true` to post immediately)
- **File Operations**: `Read,Write,Edit`
- **Git Operations**: `Bash(git:*)`

### Best Practices

- Be specific in your prompts
- Include expected output format
- Set clear success criteria
- Provide context about the repository
- Use inline comments for code-specific feedback
