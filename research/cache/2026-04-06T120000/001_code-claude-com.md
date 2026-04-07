---
url: https://code.claude.com/docs/en/best-practices
fetched_at: 2026-04-06T12:00:00Z
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

Include tests, screenshots, or expected outputs so Claude can check itself. This is the single highest-leverage thing you can do.

Claude performs dramatically better when it can verify its own work, like run tests, compare screenshots, and validate outputs.

Without clear success criteria, it might produce something that looks right but actually doesn't work. You become the only feedback loop, and every mistake requires your attention.

| Strategy | Before | After |
|----------|--------|-------|
| Provide verification criteria | "implement a function that validates email addresses" | "write a validateEmail function. example test cases: user@example.com is true, invalid is false, user@.com is false. run the tests after implementing" |
| Verify UI changes visually | "make the dashboard look better" | "[paste screenshot] implement this design. take a screenshot of the result and compare it to the original. list differences and fix them" |
| Address root causes, not symptoms | "the build is failing" | "the build fails with this error: [paste error]. fix it and verify the build succeeds. address the root cause, don't suppress the error" |

---

## Explore first, then plan, then code

Separate research and planning from implementation to avoid solving the wrong problem. Use Plan Mode to separate exploration from execution.

The recommended workflow has four phases:

1. **Explore**: Enter Plan Mode. Claude reads files and answers questions without making changes.
2. **Plan**: Ask Claude to create a detailed implementation plan.
3. **Implement**: Switch back to Normal Mode and let Claude code, verifying against its plan.
4. **Commit**: Ask Claude to commit with a descriptive message and create a PR.

Plan Mode is useful, but also adds overhead. For tasks where the scope is clear and the fix is small, ask Claude to do it directly. Planning is most useful when you're uncertain about the approach, when the change modifies multiple files, or when you're unfamiliar with the code being modified.

---

## Provide specific context in your prompts

The more precise your instructions, the fewer corrections you'll need.

Claude can infer intent, but it can't read your mind. Reference specific files, mention constraints, and point to example patterns.

| Strategy | Before | After |
|----------|--------|-------|
| Scope the task | "add tests for foo.py" | "write a test for foo.py covering the edge case where the user is logged out. avoid mocks." |
| Point to sources | "why does ExecutionFactory have such a weird api?" | "look through ExecutionFactory's git history and summarize how its api came to be" |
| Reference existing patterns | "add a calendar widget" | "look at how existing widgets are implemented on the home page to understand the patterns. HotDogWidget.php is a good example. follow the pattern..." |
| Describe the symptom | "fix the login bug" | "users report that login fails after session timeout. check the auth flow in src/auth/, especially token refresh. write a failing test that reproduces the issue, then fix it" |

### Provide rich content

- Reference files with `@` instead of describing where code lives.
- Paste images directly.
- Give URLs for documentation and API references.
- Pipe in data by running `cat error.log | claude`.
- Let Claude fetch what it needs.

---

## Configure your environment

### Write an effective CLAUDE.md

Run `/init` to generate a starter CLAUDE.md file. Include Bash commands, code style, and workflow rules. This gives Claude persistent context it can't infer from code alone.

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

### Configure permissions

Use auto mode, permission allowlists, or sandboxing to reduce interruptions.

### Use CLI tools

Tell Claude Code to use CLI tools like `gh`, `aws`, `gcloud`, and `sentry-cli` when interacting with external services. CLI tools are the most context-efficient way to interact with external services.

### Connect MCP servers

With MCP servers, you can ask Claude to implement features from issue trackers, query databases, analyze monitoring data, integrate designs from Figma, and automate workflows.

### Set up hooks

Hooks run scripts automatically at specific points in Claude's workflow. Unlike CLAUDE.md instructions which are advisory, hooks are deterministic and guarantee the action happens.

### Create skills

Skills extend Claude's knowledge with information specific to your project, team, or domain. Claude applies them automatically when relevant.

### Create custom subagents

Subagents run in their own context with their own set of allowed tools. They're useful for tasks that read many files or need specialized focus.

---

## Communicate effectively

### Ask codebase questions

Ask Claude questions you'd ask a senior engineer.

### Let Claude interview you

For larger features, have Claude interview you first. Start with a minimal prompt and ask Claude to interview you using the AskUserQuestion tool.

---

## Manage your session

### Course-correct early and often

- `Esc`: stop Claude mid-action
- `Esc + Esc` or `/rewind`: restore previous state
- `"Undo that"`: have Claude revert its changes
- `/clear`: reset context between unrelated tasks

If you've corrected Claude more than twice on the same issue in one session, the context is cluttered with failed approaches. Run `/clear` and start fresh.

### Manage context aggressively

- Use `/clear` frequently between tasks
- Run `/compact <instructions>` for more control
- Use `/btw` for quick questions that don't need to stay in context

### Use subagents for investigation

Subagents run in separate context windows and report back summaries. This keeps your main conversation clean.

### Rewind with checkpoints

Every action Claude makes creates a checkpoint. Double-tap `Escape` or run `/rewind` to open the rewind menu.

### Resume conversations

Run `claude --continue` to pick up where you left off, or `--resume` to choose from recent sessions.

---

## Automate and scale

### Run non-interactive mode

Use `claude -p "prompt"` in CI, pre-commit hooks, or scripts.

### Run multiple Claude sessions

Run multiple Claude sessions in parallel to speed up development. Use a Writer/Reviewer pattern.

### Fan out across files

Loop through tasks calling `claude -p` for each. Use `--allowedTools` to scope permissions for batch operations.

### Run autonomously with auto mode

For uninterrupted execution with background safety checks, use auto mode.

---

## Avoid common failure patterns

- **The kitchen sink session**: `/clear` between unrelated tasks.
- **Correcting over and over**: After two failed corrections, `/clear` and write a better initial prompt.
- **The over-specified CLAUDE.md**: Ruthlessly prune.
- **The trust-then-verify gap**: Always provide verification.
- **The infinite exploration**: Scope investigations narrowly or use subagents.

---

## Develop your intuition

Pay attention to what works. When Claude produces great output, notice what you did. Over time, you'll develop intuition that no guide can capture.
