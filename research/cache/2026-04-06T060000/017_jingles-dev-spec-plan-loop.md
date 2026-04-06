---
url: https://jingles.dev/articles/claude-spec-plan-loop
fetched_at: 2026-04-06T06:00:00+09:00
---

# Spec-Driven Development with Claude Code: The 3-Step Framework

## Overview

Spec-Driven Development (SDD) represents a paradigm shift in how software is created with AI assistance. Rather than treating AI coding agents as sophisticated autocomplete tools, SDD establishes specifications as the primary artifact of software development, with code becoming a generated output derived from these human-authored specifications.

## The 3-Step Framework

### Step 1: Specify
- Write a high-level description of what you want to build
- Let the agent generate a detailed specification
- Include objectives, features, constraints
- Clarify ambiguities through dialogue

### Step 2: Plan
- The agent produces a comprehensive technical plan
- Review the plan for architecture, best practices, security risks, and testing strategy
- Iterate until there's no room for misinterpretation
- The spec becomes the "source of truth"

### Step 3: Implement
- The agent tackles tasks sequentially
- Each task references back to the spec
- Tests validate each implementation step
- The spec serves as guardrails throughout

## Key Insights

### Interview Pattern
Start in Plan Mode, describe what you want to build, let the agent draft a spec while exploring existing code, ask it to clarify ambiguities, and have it review the plan.

### Fresh Sessions for Implementation
Once the spec is complete, start a fresh session to execute it. The new session has clean context focused entirely on implementation.

### Workflow

```
Idea → Interview → SPEC.md → Fresh Session → Implementation → Verification
```

## Benefits of SDD

- Defining and documenting requirements early on leads to better outputs
- Less frustrating overall experience
- Agent's code output quality improves when it has a clear reference doc
- Human remains in control of the "what" while AI handles the "how"
