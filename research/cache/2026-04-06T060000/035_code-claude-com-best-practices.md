---
url: https://code.claude.com/docs/en/best-practices
fetched_at: 2026-04-06T06:00:00+09:00
---

# Best Practices for Claude Code

> Tips and patterns for getting the most out of Claude Code

## Give Claude a way to verify its work

Include tests, screenshots, or expected outputs so Claude can check itself. This is the single highest-leverage thing you can do.

| Strategy                              | Before                                                  | After                                                                                                                                                                                                   |
| ------------------------------------- | ------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Provide verification criteria         | "implement a function that validates email addresses"   | "write a validateEmail function. example test cases: user@example.com is true, invalid is false, user@.com is false. run the tests after implementing" |
| Verify UI changes visually            | "make the dashboard look better"                        | "[paste screenshot] implement this design. take a screenshot of the result and compare it to the original." |
| Address root causes, not symptoms     | "the build is failing"                                  | "the build fails with this error: [paste error]. fix it and verify the build succeeds. address the root cause, don't suppress the error" |

## Explore first, then plan, then code

Separate research and planning from implementation. Use Plan Mode.

1. **Explore**: Enter Plan Mode. Claude reads files and answers questions without making changes.
2. **Plan**: Ask Claude to create a detailed implementation plan.
3. **Implement**: Switch back to Normal Mode.
4. **Commit**: Ask Claude to commit and create a PR.

## Provide specific context in your prompts

Reference specific files, mention constraints, and point to example patterns.

| Strategy | Before | After |
|----------|--------|-------|
| Scope the task | "add tests for foo.py" | "write a test for foo.py covering the edge case where the user is logged out. avoid mocks." |
| Point to sources | "why does ExecutionFactory have such a weird api?" | "look through ExecutionFactory's git history and summarize how its api came to be" |
| Reference existing patterns | "add a calendar widget" | "look at how existing widgets are implemented on the home page. HotDogWidget.php is a good example." |
| Describe the symptom | "fix the login bug" | "users report that login fails after session timeout. check the auth flow in src/auth/" |

### Provide rich content

- Reference files with `@`
- Paste images directly
- Give URLs for documentation
- Pipe in data
- Let Claude fetch what it needs

## Writer/Reviewer pattern

Use multiple sessions for quality-focused workflows:

| Session A (Writer)                                                      | Session B (Reviewer)                                                                                                                                                     |
| ----------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| Implement a rate limiter for our API endpoints                          |                                                                                                                                                                          |
|                                                                         | Review the rate limiter implementation in @src/middleware/rateLimiter.ts. Look for edge cases, race conditions, and consistency with our existing middleware patterns.    |
| Here's the review feedback: [Session B output]. Address these issues.   |                                                                                                                                                                          |

A fresh context improves code review since Claude won't be biased toward code it just wrote.

## Create custom subagents

```markdown .claude/agents/security-reviewer.md
---
name: security-reviewer
description: Reviews code for security vulnerabilities
tools: Read, Grep, Glob, Bash
model: opus
---
You are a senior security engineer. Review code for:
- Injection vulnerabilities (SQL, XSS, command injection)
- Authentication and authorization flaws
- Secrets or credentials in code
- Insecure data handling

Provide specific line references and suggested fixes.
```

Tell Claude to use subagents: "Use a subagent to review this code for security issues."

## Ask codebase questions

Use Claude Code for learning and exploration:
- How does logging work?
- How do I make a new API endpoint?
- What does `async move { ... }` do on line 134 of foo.rs?
- What edge cases does `CustomerOnboardingFlowImpl` handle?

## Avoid common failure patterns

- **The kitchen sink session**: `/clear` between unrelated tasks.
- **Correcting over and over**: After two failed corrections, `/clear` and write a better initial prompt.
- **The over-specified CLAUDE.md**: Ruthlessly prune.
- **The trust-then-verify gap**: Always provide verification.
- **The infinite exploration**: Scope investigations or use subagents.
