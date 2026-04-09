---
url: https://mindwiredai.com/2026/03/25/claude-code-creator-workflow-claudemd/
fetched_at: 2026-04-09T10:00:00+09:00
---

# Claude Code Best Practices: Inside the Creator's 100-Line Workflow

## Who Is Boris Cherny?

Boris Cherny is a Staff Engineer at Anthropic and the creator of Claude Code, the terminal-based AI coding tool. In January 2026, he publicly shared his complete workflow, including his CLAUDE.md configuration file.

## Key Findings

### The CLAUDE.md File

Cherny's configuration spans approximately 100 lines (~2,500 tokens) yet outperforms much longer alternatives. The document covers:

- Workflow orchestration (plan mode, subagents, self-improvement)
- Task management with structured tracking
- Core principles emphasizing simplicity and root-cause analysis

### Workflow Characteristics

- Runs 10-15 Claude sessions simultaneously using separate git worktrees
- Updates CLAUDE.md when errors occur to prevent repetition
- Uses aggressive prompting: "Prove to me this works" rather than step-by-step instructions

## Three Core Principles

1. **Simplicity First** — Minimize code changes; delete lines when possible
2. **No Laziness** — Find root causes; reject temporary fixes
3. **Minimal Impact** — Only modify what's necessary

## Task Management System

The structured 6-step approach: Plan → Verify → Track Progress → Explain Changes → Document Results → Capture Lessons

## The Golden Rule

"Anytime we see Claude do something incorrectly, we add it to CLAUDE.md so it doesn't repeat next time."

The file is checked into git, shared by the whole team, and updated multiple times a week as a living document.

## Universal Applications

These principles apply beyond coding. The philosophy emphasizes planning before execution, maintaining clean context, learning from mistakes, and avoiding micromanagement of AI systems.

The underlying message: build a sustainable system around AI rather than treating it as a one-time tool.
