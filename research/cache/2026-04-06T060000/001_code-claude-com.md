---
url: https://code.claude.com/docs/en/best-practices
fetched_at: 2026-04-06T06:00:00+09:00
---

# Best Practices for Claude Code

> Tips and patterns for getting the most out of Claude Code, from configuring your environment to scaling across parallel sessions.

Claude Code is an agentic coding environment. Unlike a chatbot that answers questions and waits, Claude Code can read your files, run commands, make changes, and autonomously work through problems while you watch, redirect, or step away entirely.

This changes how you work. Instead of writing code yourself and asking Claude to review it, you describe what you want and Claude figures out how to build it. Claude explores, plans, and implements.

But this autonomy still comes with a learning curve. Claude works within certain constraints you need to understand.

This guide covers patterns that have proven effective across Anthropic's internal teams and for engineers using Claude Code across various codebases, languages, and environments.

---

Most best practices are based on one constraint: Claude's context window fills up fast, and performance degrades as it fills.

Claude's context window holds your entire conversation, including every message, every file Claude reads, and every command output. However, this can fill up fast. A single debugging session or codebase exploration might generate and consume tens of thousands of tokens.

This matters since LLM performance degrades as context fills. When the context window is getting full, Claude may start "forgetting" earlier instructions or making more mistakes. The context window is the most important resource to manage.

---

## Give Claude a way to verify its work

> Include tests, screenshots, or expected outputs so Claude can check itself. This is the single highest-leverage thing you can do.

Claude performs dramatically better when it can verify its own work, like run tests, compare screenshots, and validate outputs.

Without clear success criteria, it might produce something that looks right but actually doesn't work. You become the only feedback loop, and every mistake requires your attention.

| Strategy | Before | After |
| --- | --- | --- |
| **Provide verification criteria** | "implement a function that validates email addresses" | "write a validateEmail function. example test cases: user@example.com is true, invalid is false, user@.com is false. run the tests after implementing" |
| **Verify UI changes visually** | "make the dashboard look better" | "[paste screenshot] implement this design. take a screenshot of the result and compare it to the original. list differences and fix them" |
| **Address root causes, not symptoms** | "the build is failing" | "the build fails with this error: [paste error]. fix it and verify the build succeeds. address the root cause, don't suppress the error" |

Your verification can also be a test suite, a linter, or a Bash command that checks output. Invest in making your verification rock-solid.

---

## Explore first, then plan, then code

> Separate research and planning from implementation to avoid solving the wrong problem.

Letting Claude jump straight to coding can produce code that solves the wrong problem. Use Plan Mode to separate exploration from execution.

The recommended workflow has four phases:

1. **Explore**: Enter Plan Mode. Claude reads files and answers questions without making changes.
2. **Plan**: Ask Claude to create a detailed implementation plan.
3. **Implement**: Switch back to Normal Mode and let Claude code, verifying against its plan.
4. **Commit**: Ask Claude to commit with a descriptive message and create a PR.

Plan Mode is useful, but also adds overhead. For tasks where the scope is clear and the fix is small (like fixing a typo, adding a log line, or renaming a variable) ask Claude to do it directly.

Planning is most useful when you're uncertain about the approach, when the change modifies multiple files, or when you're unfamiliar with the code being modified. If you could describe the diff in one sentence, skip the plan.

---

## Provide specific context in your prompts

> The more precise your instructions, the fewer corrections you'll need.

Claude can infer intent, but it can't read your mind. Reference specific files, mention constraints, and point to example patterns.

| Strategy | Before | After |
| --- | --- | --- |
| **Scope the task.** | "add tests for foo.py" | "write a test for foo.py covering the edge case where the user is logged out. avoid mocks." |
| **Point to sources.** | "why does ExecutionFactory have such a weird api?" | "look through ExecutionFactory's git history and summarize how its api came to be" |
| **Reference existing patterns.** | "add a calendar widget" | "look at how existing widgets are implemented on the home page to understand the patterns. HotDogWidget.php is a good example. follow the pattern..." |
| **Describe the symptom.** | "fix the login bug" | "users report that login fails after session timeout. check the auth flow in src/auth/, especially token refresh. write a failing test that reproduces the issue, then fix it" |

### Provide rich content

> Use `@` to reference files, paste screenshots/images, or pipe data directly.

You can provide rich data to Claude in several ways:

* **Reference files with `@`** instead of describing where code lives. Claude reads the file before responding.
* **Paste images directly**. Copy/paste or drag and drop images into the prompt.
* **Give URLs** for documentation and API references.
* **Pipe in data** by running `cat error.log | claude` to send file contents directly.
* **Let Claude fetch what it needs**. Tell Claude to pull context itself using Bash commands, MCP tools, or by reading files.

---

## Course-correct early and often

> Correct Claude as soon as you notice it going off track.

The best results come from tight feedback loops.

* **`Esc`**: stop Claude mid-action with the `Esc` key. Context is preserved, so you can redirect.
* **`Esc + Esc` or `/rewind`**: press `Esc` twice or run `/rewind` to open the rewind menu and restore previous conversation and code state.
* **`"Undo that"`**: have Claude revert its changes.
* **`/clear`**: reset context between unrelated tasks.

If you've corrected Claude more than twice on the same issue in one session, the context is cluttered with failed approaches. Run `/clear` and start fresh with a more specific prompt that incorporates what you learned. A clean session with a better prompt almost always outperforms a long session with accumulated corrections.

---

## Avoid common failure patterns

* **The kitchen sink session.** You start with one task, then ask Claude something unrelated, then go back to the first task. Context is full of irrelevant information.
  > **Fix**: `/clear` between unrelated tasks.
* **Correcting over and over.** Claude does something wrong, you correct it, it's still wrong, you correct again. Context is polluted with failed approaches.
  > **Fix**: After two failed corrections, `/clear` and write a better initial prompt incorporating what you learned.
* **The trust-then-verify gap.** Claude produces a plausible-looking implementation that doesn't handle edge cases.
  > **Fix**: Always provide verification (tests, scripts, screenshots). If you can't verify it, don't ship it.
* **The infinite exploration.** You ask Claude to "investigate" something without scoping it. Claude reads hundreds of files, filling the context.
  > **Fix**: Scope investigations narrowly or use subagents so the exploration doesn't consume your main context.
