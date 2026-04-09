---
url: https://code.claude.com/docs/en/best-practices
fetched_at: 2026-04-09T10:00:00+09:00
---

# Best Practices for Claude Code (Official Documentation)

## Core Principle

Most best practices are based on one constraint: Claude's context window fills up fast, and performance degrades as it fills.

## Give Claude a way to verify its work

Include tests, screenshots, or expected outputs so Claude can check itself. This is the single highest-leverage thing you can do.

## Explore first, then plan, then code

Separate research and planning from implementation to avoid solving the wrong problem. Use Plan Mode to separate exploration from execution.

Four phases: Explore → Plan → Implement → Commit

## Provide specific context in your prompts

Reference specific files, mention constraints, and point to example patterns. Use `@` to reference files, paste screenshots/images, or pipe data directly.

## Configure your environment

### Write an effective CLAUDE.md

Run `/init` to generate a starter CLAUDE.md. Keep it short and human-readable. Only include things that apply broadly.

CLAUDE.md locations:
- Home folder (`~/.claude/CLAUDE.md`): applies to all sessions
- Project root (`./CLAUDE.md`): check into git to share with team
- Project root (`./CLAUDE.local.md`): personal project-specific notes (add to .gitignore)
- Parent directories: useful for monorepos
- Child directories: pulled in on demand

Include: Bash commands Claude can't guess, code style rules that differ from defaults, testing instructions, repo etiquette, architectural decisions, developer environment quirks, common gotchas.

Exclude: Anything Claude can figure out by reading code, standard language conventions, detailed API documentation, information that changes frequently, long explanations or tutorials.

### Configure permissions

Three ways to reduce interruptions: Auto mode, Permission allowlists, Sandboxing.

### Use CLI tools

Tell Claude Code to use CLI tools like `gh`, `aws`, `gcloud`, `sentry-cli`.

### Connect MCP servers

Run `claude mcp add` to connect external tools like Notion, Figma, or your database.

### Set up hooks

Hooks run scripts automatically at specific points. Unlike CLAUDE.md instructions which are advisory, hooks are deterministic.

### Create skills

SKILL.md files in `.claude/skills/` give Claude domain knowledge and reusable workflows.

### Create custom subagents

Define specialized assistants in `.claude/agents/` that Claude can delegate to for isolated tasks.

### Install plugins

Run `/plugin` to browse the marketplace.

## Communicate effectively

Ask codebase questions like you'd ask a senior engineer. Let Claude interview you for larger features.

## Manage your session

- Course-correct early and often
- Manage context aggressively with `/clear`
- Use subagents for investigation
- Rewind with checkpoints
- Resume conversations with `--continue` or `--resume`

## Automate and scale

- Run non-interactive mode with `claude -p`
- Run multiple Claude sessions in parallel
- Fan out across files
- Run autonomously with auto mode

## Avoid common failure patterns

- The kitchen sink session → `/clear` between unrelated tasks
- Correcting over and over → After two fails, `/clear` and rewrite prompt
- The over-specified CLAUDE.md → Ruthlessly prune
- The trust-then-verify gap → Always provide verification
- The infinite exploration → Scope investigations or use subagents
