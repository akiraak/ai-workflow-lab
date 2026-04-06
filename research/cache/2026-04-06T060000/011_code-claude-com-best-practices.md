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
|----------|--------|-------|
| **Provide verification criteria** | "implement a function that validates email addresses" | "write a validateEmail function. example test cases: user@example.com is true, invalid is false, user@.com is false. run the tests after implementing" |
| **Verify UI changes visually** | "make the dashboard look better" | "[paste screenshot] implement this design. take a screenshot of the result and compare it to the original. list differences and fix them" |
| **Address root causes, not symptoms** | "the build is failing" | "the build fails with this error: [paste error]. fix it and verify the build succeeds. address the root cause, don't suppress the error" |

---

## Explore first, then plan, then code

> Separate research and planning from implementation to avoid solving the wrong problem.

Letting Claude jump straight to coding can produce code that solves the wrong problem. Use Plan Mode to separate exploration from execution.

The recommended workflow has four phases:

### Phase 1: Explore
Enter Plan Mode. Claude reads files and answers questions without making changes.

```
read /src/auth and understand how we handle sessions and login.
also look at how we manage environment variables for secrets.
```

### Phase 2: Plan
Ask Claude to create a detailed implementation plan.

```
I want to add Google OAuth. What files need to change?
What's the session flow? Create a plan.
```

Press Ctrl+G to open the plan in your text editor for direct editing before Claude proceeds.

### Phase 3: Implement
Switch back to Normal Mode and let Claude code, verifying against its plan.

```
implement the OAuth flow from your plan. write tests for the
callback handler, run the test suite and fix any failures.
```

### Phase 4: Commit
Ask Claude to commit with a descriptive message and create a PR.

```
commit with a descriptive message and open a PR
```

> Plan Mode is useful, but also adds overhead. For tasks where the scope is clear and the fix is small (like fixing a typo, adding a log line, or renaming a variable) ask Claude to do it directly.
> Planning is most useful when you're uncertain about the approach, when the change modifies multiple files, or when you're unfamiliar with the code being modified. If you could describe the diff in one sentence, skip the plan.

---

## Provide specific context in your prompts

> The more precise your instructions, the fewer corrections you'll need.

Claude can infer intent, but it can't read your mind. Reference specific files, mention constraints, and point to example patterns.

| Strategy | Before | After |
|----------|--------|-------|
| **Scope the task** | "add tests for foo.py" | "write a test for foo.py covering the edge case where the user is logged out. avoid mocks." |
| **Point to sources** | "why does ExecutionFactory have such a weird api?" | "look through ExecutionFactory's git history and summarize how its api came to be" |
| **Reference existing patterns** | "add a calendar widget" | "look at how existing widgets are implemented on the home page to understand the patterns. HotDogWidget.php is a good example. follow the pattern to implement a new calendar widget..." |
| **Describe the symptom** | "fix the login bug" | "users report that login fails after session timeout. check the auth flow in src/auth/, especially token refresh. write a failing test that reproduces the issue, then fix it" |

### Provide rich content

- **Reference files with @** instead of describing where code lives
- **Paste images directly** into the prompt
- **Give URLs** for documentation and API references
- **Pipe in data** by running `cat error.log | claude`
- **Let Claude fetch what it needs**

---

## Let Claude interview you

> For larger features, have Claude interview you first. Start with a minimal prompt and ask Claude to interview you using the AskUserQuestion tool.

Claude asks about things you might not have considered yet, including technical implementation, UI/UX, edge cases, and tradeoffs.

```
I want to build [brief description]. Interview me in detail using the AskUserQuestion tool.

Ask about technical implementation, UI/UX, edge cases, concerns, and tradeoffs. Don't ask obvious questions, dig into the hard parts I might not have considered.

Keep interviewing until we've covered everything, then write a complete spec to SPEC.md.
```

Once the spec is complete, start a fresh session to execute it. The new session has clean context focused entirely on implementation, and you have a written spec to reference.

---

## Write an effective CLAUDE.md

CLAUDE.md is a special file that Claude reads at the start of every conversation. Include Bash commands, code style, and workflow rules. This gives Claude persistent context it can't infer from code alone.

Keep it concise. For each line, ask: "Would removing this cause Claude to make mistakes?" If not, cut it. Bloated CLAUDE.md files cause Claude to ignore your actual instructions!

| ✅ Include | ❌ Exclude |
|-----------|-----------|
| Bash commands Claude can't guess | Anything Claude can figure out by reading code |
| Code style rules that differ from defaults | Standard language conventions Claude already knows |
| Testing instructions and preferred test runners | Detailed API documentation (link to docs instead) |
| Repository etiquette (branch naming, PR conventions) | Information that changes frequently |
| Architectural decisions specific to your project | Long explanations or tutorials |
| Developer environment quirks (required env vars) | File-by-file descriptions of the codebase |
| Common gotchas or non-obvious behaviors | Self-evident practices like "write clean code" |

---

## Manage your session

### Course-correct early and often
- **Esc**: stop Claude mid-action
- **Esc + Esc** or **/rewind**: restore previous conversation and code state
- **"Undo that"**: have Claude revert its changes
- **/clear**: reset context between unrelated tasks

If you've corrected Claude more than twice on the same issue in one session, the context is cluttered with failed approaches. Run /clear and start fresh with a more specific prompt.

### Use subagents for investigation
> Delegate research with "use subagents to investigate X". They explore in a separate context, keeping your main conversation clean for implementation.

---

## Avoid common failure patterns

- **The kitchen sink session** — Fix: /clear between unrelated tasks.
- **Correcting over and over** — Fix: After two failed corrections, /clear and write a better initial prompt.
- **The over-specified CLAUDE.md** — Fix: Ruthlessly prune.
- **The trust-then-verify gap** — Fix: Always provide verification (tests, scripts, screenshots).
- **The infinite exploration** — Fix: Scope investigations narrowly or use subagents.

---

## Automate and scale

- Run non-interactive mode with `claude -p "prompt"` in CI, pre-commit hooks, or scripts
- Run multiple Claude sessions in parallel
- Fan out across files for large migrations
- Use auto mode for uninterrupted execution
