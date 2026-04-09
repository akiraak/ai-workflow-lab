---
url: https://www.news.aakashg.com/p/claude-code-team-os
fetched_at: 2026-04-09T10:00:00+09:00
---

# Build a Team OS with Claude Code

By Aakash Gupta, featuring Hannah Stulberg (PM @ DoorDash)

## Overview

Hannah Stulberg presents a framework for creating a shared GitHub repository that enables product teams to self-serve context without depending on a single PM as the "human router."

## The Team OS Structure

### Component 1: Root Claude MD

The foundation loads three critical elements each session:

1. **Doc Index**: Maps where information lives, preventing Claude from running expensive explore agents
2. **Team Roster**: Lists each person with their role, Slack ID, and GitHub handle
3. **Key Slack Channels**: Channel names mapped to IDs and purposes

Keep this file to one page maximum. "If it is longer than one page, you are burning context on information not needed in 80% of sessions."

### Component 2: Nested Doc Indexes

Each major folder gets its own Claude MD serving as navigation maps, not content files.

### Component 3: Folder Architecture

Three top-level sections:

- **.claude/** — Shared agents, commands, and skills
- **Product Development** — Organized by function and product area
- **Team** — Onboarding guides and retros

## Context Management Theory

Four pillars:
1. **Context**: Information available in an LLM session
2. **Context Window**: Capacity (~1 million tokens)
3. **Compaction**: Information compression when window fills
4. **Thinking Room**: Space remaining for reasoning

### Token Efficiency Framework

- **Tier 1**: Root file and rosters (always loaded, ~500 tokens)
- **Tier 2**: Folder indexes (loaded on query, 200-500 tokens)
- **Tier 3**: Content files (loaded on demand, hundreds to thousands)

## Scaling Analytics Across Functions

### Layer 1: Metrics, Queries, and Schemas

```
analytics/
├── billing/
│   ├── metrics.md
│   ├── queries/
│   └── schemas/
└── onboarding/
```

### Layer 2: Playbooks and Verified Approaches

Document processes as playbooks. "Your data scientist must own and verify the analytics folder."

### Layer 3: Feature Launch Gate

Make repository updates non-negotiable for launches.

## Writing Effective Documentation with Planning

### Three Prompting Tiers

1. **Basic Prompt**: Type request, Claude decides everything
2. **Lightweight Alignment**: Add "give me a proposal first"
3. **Full Plan Mode**: Press Shift+Tab twice for comprehensive planning

### Five-Phase Process

1. Load context (read relevant files in parallel)
2. Ask user questions about audience and focus
3. Build the plan file with section structure
4. Push thinking by requesting Claude challenge assumptions
5. Review agent prompts before execution

The principle: "The plan is not overhead. The plan is the work."

## The Learning Flywheel

1. Automate one task → Free up time
2. Use freed time to learn → Improve repo
3. Better repo → More automation possible
4. More automation → More time freed

### Mistakes That Stall Progress

- Giving up after day one (takes weeks to build)
- Copying skills without understanding them
- Treating Claude Code only as a coding tool
- Not clearing context between tasks
- Allowing context rot through infrequent updates

## Key Takeaway

"The PMs who build a Team OS this quarter multiply their leverage by 10x. The PMs who keep being the bottleneck for context just made themselves the slowest person on the team."
