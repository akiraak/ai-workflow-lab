---
url: https://code.claude.com/docs/en/best-practices
fetched_at: 2026-04-06T06:00:00+09:00
---

# Best Practices for Claude Code

> Tips and patterns for getting the most out of Claude Code, from configuring your environment to scaling across parallel sessions.

Claude Code is an agentic coding environment. Unlike a chatbot that answers questions and waits, Claude Code can read your files, run commands, make changes, and autonomously work through problems while you watch, redirect, or step away entirely.

This changes how you work. Instead of writing code yourself and asking Claude to review it, you describe what you want and Claude figures out how to build it. Claude explores, plans, and implements.

But this autonomy still comes with a learning curve. Claude works within certain constraints you need to understand.

Most best practices are based on one constraint: Claude's context window fills up fast, and performance degrades as it fills.

## Give Claude a way to verify its work

Include tests, screenshots, or expected outputs so Claude can check itself. This is the single highest-leverage thing you can do.

| Strategy | Before | After |
|----------|--------|-------|
| Provide verification criteria | "implement a function that validates email addresses" | "write a validateEmail function. example test cases: user@example.com is true, invalid is false, user@.com is false. run the tests after implementing" |
| Verify UI changes visually | "make the dashboard look better" | "[paste screenshot] implement this design. take a screenshot of the result and compare it to the original. list differences and fix them" |
| Address root causes, not symptoms | "the build is failing" | "the build fails with this error: [paste error]. fix it and verify the build succeeds. address the root cause, don't suppress the error" |

## Explore first, then plan, then code

Separate research and planning from implementation to avoid solving the wrong problem.

The recommended workflow has four phases:

1. **Explore**: Enter Plan Mode. Claude reads files and answers questions without making changes.
2. **Plan**: Ask Claude to create a detailed implementation plan.
3. **Implement**: Switch back to Normal Mode and let Claude code, verifying against its plan.
4. **Commit**: Ask Claude to commit with a descriptive message and create a PR.

Plan Mode is useful, but also adds overhead. For tasks where the scope is clear and the fix is small (like fixing a typo, adding a log line, or renaming a variable) ask Claude to do it directly. Planning is most useful when you're uncertain about the approach, when the change modifies multiple files, or when you're unfamiliar with the code being modified. If you could describe the diff in one sentence, skip the plan.

## Provide specific context in your prompts

The more precise your instructions, the fewer corrections you'll need.

| Strategy | Before | After |
|----------|--------|-------|
| Scope the task | "add tests for foo.py" | "write a test for foo.py covering the edge case where the user is logged out. avoid mocks." |
| Point to sources | "why does ExecutionFactory have such a weird api?" | "look through ExecutionFactory's git history and summarize how its api came to be" |
| Reference existing patterns | "add a calendar widget" | "look at how existing widgets are implemented on the home page. HotDogWidget.php is a good example. follow the pattern..." |
| Describe the symptom | "fix the login bug" | "users report that login fails after session timeout. check the auth flow in src/auth/, especially token refresh. write a failing test that reproduces the issue, then fix it" |

Vague prompts can be useful when you're exploring and can afford to course-correct.

## Configure your environment - CLAUDE.md

CLAUDE.md is a special file that Claude reads at the start of every conversation. Include Bash commands, code style, and workflow rules. This gives Claude persistent context it can't infer from code alone.

Keep it concise. For each line, ask: "Would removing this cause Claude to make mistakes?" If not, cut it.

## Manage your session

- Course-correct early and often
- Manage context aggressively: Run /clear between unrelated tasks
- Use subagents for investigation

If you've corrected Claude more than twice on the same issue in one session, the context is cluttered with failed approaches. Run /clear and start fresh with a more specific prompt.

## Automate and scale

### Fan out across files

For large migrations or analyses, you can distribute work across many parallel Claude invocations:

1. Have Claude list all files that need migrating
2. Write a script to loop through the list
3. Test on a few files, then run at scale

## Avoid common failure patterns

- The kitchen sink session
- Correcting over and over
- The over-specified CLAUDE.md
- The trust-then-verify gap
- The infinite exploration
