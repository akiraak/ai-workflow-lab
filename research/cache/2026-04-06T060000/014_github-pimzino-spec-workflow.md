---
url: https://github.com/Pimzino/claude-code-spec-workflow
fetched_at: 2026-04-06T06:00:00+09:00
---

# claude-code-spec-workflow

Automated workflows for Claude Code. Features spec-driven development for new features (Requirements → Design → Tasks → Implementation) and streamlined bug fix workflow for quick issue resolution (Report → Analyze → Fix → Verify).

## Spec-Driven Development Workflow

Each feature is developed through four sequential phases:

1. **Requirements** - Define WHAT needs to be built
2. **Design** - Determine HOW it will be built
3. **Tasks** - Plan WHEN and in what order
4. **Implementation** - Execute the plan with progress tracking

### Requirements Phase
- Define user stories and acceptance criteria
- Identify technical constraints
- Establish scope boundaries

### Design Phase
- Architecture decisions
- API design
- Data model specification
- Component structure

### Tasks Phase
- Break down into small, reviewable chunks
- Define task dependencies
- Map tasks to specific files
- Write tasks in /specs/tasks/TASKS.md

### Implementation Phase
- Execute tasks sequentially
- Track progress
- Run tests after each task
- Commit after each successful step

## Bug Fix Workflow

1. **Report** - Document the issue
2. **Analyze** - Find root cause
3. **Fix** - Implement the fix
4. **Verify** - Run tests and confirm resolution

## Key Benefits

- Instead of being interrupted dozens of times during implementation, you review three documents upfront (requirements, design, tasks)
- Approval count during implementation drops significantly because the important decisions are already made
- Each task is testable and mapped to specific files
- Structured workflow ensures nothing is missed

## Folder Structure

```
/specs/
  requirements.md    # What to build
  design.md          # How to build it
  tasks/
    TASKS.md         # Task breakdown with status tracking
```
