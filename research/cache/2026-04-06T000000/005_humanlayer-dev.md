---
url: https://www.humanlayer.dev/blog/writing-a-good-claude-md
fetched_at: 2026-04-06
---

# Writing a good CLAUDE.md (HumanLayer)

## Core Content Framework (WHAT/WHY/HOW)
- WHAT: Technology stack, project structure, codebase architecture
- WHY: Project purpose and functional goals
- HOW: Development workflow, tooling, testing, verification

## Instruction Economy
- Frontier LLMs follow ~150-200 instructions with reasonable consistency
- Claude Code system prompt already contains ~50 instructions
- Smaller models degrade exponentially; larger models show linear decay

## Length Constraints
- Target: Under 300 lines; ideally less than 60 lines
- Include only universally relevant content

## Progressive Disclosure Pattern
- Store specialized guidance in separate files (agent_docs/)
- Reference from CLAUDE.md with brief descriptions
- Claude selectively retrieves context when needed

## What NOT to Include
- Code style guidelines (use linters instead)
- Exhaustive command libraries
- Formatting rules (use Hooks or Skills)
- Auto-generated content without curation

## Critical Insight
Claude system injects "this context may or may not be relevant to your tasks" reminder, causing Claude to disregard instructions deemed contextually inaccessible.
