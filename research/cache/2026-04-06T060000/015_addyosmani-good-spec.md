---
url: https://addyosmani.com/blog/good-spec/
fetched_at: 2026-04-06T06:00:00+09:00
---

# How to write a good spec for AI agents — Addy Osmani

(Also published on O'Reilly Radar: https://www.oreilly.com/radar/how-to-write-a-good-spec-for-ai-agents/)

## Core Thesis

AI coding quality usually fails at the specification layer before it fails at the model layer. The quality of the spec determines the quality of the code output.

## Framework Overview

Backed by GitHub's analysis of 2,500+ agent configs and Stanford's 'Curse of Instructions' research.

A high-level spec for an AI agent should focus on **what and why**, more than the nitty-gritty how (at least initially), similar to user stories with acceptance criteria asking what success looks like.

## Six Areas of an Effective Spec

1. **Commands** - Build, test, and run commands
2. **Testing** - Test framework, coverage expectations
3. **Project structure** - Directory layout and conventions
4. **Code style** - Formatting, naming, patterns
5. **Git workflow** - Branch naming, commit message format
6. **Boundaries** - What the agent must NOT do

## Key Principles

### Treat the spec as a structured document (PRD)
- Clear sections, not a loose pile of notes
- Machine-readable where possible

### Use LLM-as-a-Judge for hard-to-test criteria
For criteria that are hard to test automatically—code style, readability, adherence to architectural patterns—consider having a second agent review the first agent's output against your spec's quality guidelines.

### Conformance testing
Build language-independent tests (often YAML-based) that any implementation must pass. These act as a contract—the agent's code must satisfy all cases.

## Recommended Workflow

1. **Specify** — Write high-level description; agent generates detailed specification
2. **Plan** — Agent produces comprehensive technical plan
3. **Tasks** — Agent breaks spec into small, reviewable chunks
4. **Implement** — Agent tackles tasks sequentially

## Anti-patterns

- Piling too many rules into a single config file
- Vague or contradictory instructions
- Missing boundaries (what NOT to do)
- No verification criteria
- Spec that's too long for the model to follow consistently

## Key Quote

> "Rules only work when they are small, narrow, and scoped. LLMs have a hard time following too many instructions at once—the fewer rules you load into context, the better the result."
