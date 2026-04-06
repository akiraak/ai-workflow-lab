---
url: https://code.claude.com/docs/en/best-practices
fetched_at: 2026-04-05
---

# Best Practices for Claude Code

> Tips and patterns for getting the most out of Claude Code, from configuring your environment to scaling across parallel sessions.

Claude Code is an agentic coding environment. Unlike a chatbot that answers questions and waits, Claude Code can read your files, run commands, make changes, and autonomously work through problems while you watch, redirect, or step away entirely.

Most best practices are based on one constraint: Claude's context window fills up fast, and performance degrades as it fills.

## Give Claude a way to verify its work

Claude performs dramatically better when it can verify its own work, like run tests, compare screenshots, and validate outputs.

| Strategy | Before | After |
|----------|--------|-------|
| Provide verification criteria | "implement a function that validates email addresses" | "write a validateEmail function. example test cases: user@example.com is true, invalid is false, user@.com is false. run the tests after implementing" |
| Verify UI changes visually | "make the dashboard look better" | "[paste screenshot] implement this design. take a screenshot of the result and compare it to the original. list differences and fix them" |
| Address root causes, not symptoms | "the build is failing" | "the build fails with this error: [paste error]. fix it and verify the build succeeds. address the root cause, don't suppress the error" |

## Explore first, then plan, then code

Recommended workflow has four phases: Explore → Plan → Implement → Commit

Plan Mode is useful when you're uncertain about the approach, when the change modifies multiple files, or when you're unfamiliar with the code. If you could describe the diff in one sentence, skip the plan.

## Provide specific context in your prompts

The more precise your instructions, the fewer corrections you'll need.

| Strategy | Before | After |
|----------|--------|-------|
| Scope the task | "add tests for foo.py" | "write a test for foo.py covering the edge case where the user is logged out. avoid mocks." |
| Point to sources | "why does ExecutionFactory have such a weird api?" | "look through ExecutionFactory's git history and summarize how its api came to be" |
| Reference existing patterns | "add a calendar widget" | "look at how existing widgets are implemented on the home page to understand the patterns. HotDogWidget.php is a good example. follow the pattern..." |
| Describe the symptom | "fix the login bug" | "users report that login fails after session timeout. check the auth flow in src/auth/, especially token refresh. write a failing test that reproduces the issue, then fix it" |

Vague prompts can be useful when you're exploring and can afford to course-correct.

## Communicate effectively

- Ask codebase questions like you'd ask a senior engineer
- Let Claude interview you for larger features (using AskUserQuestion tool)
- Course-correct early and often (Esc, /rewind, /clear)
- After two failed corrections, /clear and write a better initial prompt

## Avoid common failure patterns

- The kitchen sink session: /clear between unrelated tasks
- Correcting over and over: After 2 failures, /clear and better prompt
- The over-specified CLAUDE.md: Ruthlessly prune
- The trust-then-verify gap: Always provide verification
- The infinite exploration: Scope or use subagents
