---
url: https://www.mindstudio.ai/blog/gsd-framework-claude-code-clean-context-phases
fetched_at: 2026-04-06T06:00:00+09:00
---

# What Is the GSD Framework for Claude Code? How to Break Complex Tasks Into Clean Context Phases

## Overview

GSD (Get Stuff Done) is a structured prompt engineering approach that splits complex coding tasks into three distinct phases: plan, execute, and review. Each phase gets its own clean context window, its own clear objective, and Claude's full attention.

## The Problem GSD Solves

When you ask Claude to plan, implement, and review code inside a single conversation, you're stacking three cognitively distinct tasks on top of each other. Mixing planning artifacts, code, and debugging feedback into one session creates noise that degrades each subsequent output.

## The Three Core Phases

### Phase 1: Plan
- Define scope
- Break down the problem
- Produce a structured spec
- Each plan is 2-3 tasks, designed to fit in ~50% of a fresh context window

### Phase 2: Execute
- Write code against that spec, nothing else
- For larger tasks, break the Execute phase into sub-phases covering logical implementation chunks
- No single task is big enough to degrade quality

### Phase 3: Review
- Evaluate the output against original requirements
- Identify issues
- Flag any deviations from spec

## Key Design Principles

### Fresh Subagent Contexts
Instead of one long session that gradually degrades, GSD spawns fresh Claude instances for each task. Each subagent gets a clean 200,000 token context window.

### Task Size Guidelines
- Keep each task under 200 lines of changes
- Write tests before implementation
- Commit after each successful step

## GSD Workflow Commands

- `/gsd:new-project` — Captures the idea and generates specs
- `/gsd:discuss-phase` — Clarifies details
- `/gsd:plan-phase` — Breaks work into tasks
- `/gsd:execute-phase` — Runs those tasks in parallel
- `/gsd:verify-work` — Validates the output
- `/gsd:complete-milestone` — Archives and releases

## Benefits

GSD doesn't make Claude Code smarter. It makes Claude Code reliable. By solving context rot through disciplined context engineering, every task gets the full power of Claude's 200K context window.

The result is consistently better outputs with fewer correction cycles.
