---
url: https://alexop.dev/posts/spec-driven-development-claude-code-in-action/
fetched_at: 2026-04-06T06:00:00+09:00
---

# Spec-Driven Development with Claude Code in Action

## Overview

This article demonstrates the practical application of spec-driven development with Claude Code, using exact prompts, tools, and patterns to accomplish significant refactoring in a single day.

## Workflow Structure

A structured workflow — from idea to shipped code — where each phase produces a spec that feeds the next:

1. **Idea Phase**: Describe the feature or change in plain language
2. **Interview Phase**: Claude interviews you about requirements, edge cases, tradeoffs
3. **Spec Phase**: Generate SPEC.md as the source of truth
4. **Planning Phase**: Break spec into tasks with dependencies
5. **Implementation Phase**: Execute tasks with progress tracking
6. **Verification Phase**: Validate against the spec

## Claude Code's Native SDD Support

Claude Code has absorbed much of the SDD tooling natively:
- CLAUDE.md serves as the project constitution
- Subagents handle parallel research
- The interview pattern enables refinement
- The native Tasks system handles implementation delegation with dependency ordering and atomic commits

## Practical Insights

### Interview-First Approach
Instead of writing a detailed specification upfront, let Claude interview you. This surfaces requirements you hadn't considered.

### Spec as Contract
The SPEC.md file acts as a contract between you and Claude:
- If the output doesn't match the spec, it's a bug
- If the spec was wrong, it's a specification issue (easier to fix than implementation issues)

### Task Atomicity
Each task should be:
- Completable in a single session
- Testable independently
- Commitable as a single unit
- Under 200 lines of changes

## Key Takeaway

Defining and documenting requirements early on leads to better outputs and a less frustrating overall experience. The upfront investment in specification pays for itself many times over.
