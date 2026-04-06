---
url: https://www.atlassian.com/blog/developer/how-to-effectively-utilise-ai-to-enhance-large-scale-refactoring
fetched_at: 2026-04-06T06:00:00+09:00
---

# How to effectively utilise AI to enhance large-scale refactoring

Atlassian Blog | Work Life by Atlassian

## Key Strategies for AI-Enhanced Large-Scale Refactoring

### Iterative Workflow
Organizations should iterate by running in small batches, validating diffs, refining prompts, and scaling out. The process involves:
- Making assisted changes to the codebase
- Running integration tests
- Iterating as needed
- Ensuring code remains functional and improves with each step

### Context Management
Teams should establish a durable AI context using a memory file to guide the AI in code generation, edit interpretation, and workflow assistance during each session.

### Safety and Validation
Every refactoring operation includes:
- Multiple safety checks to ensure code behavior remains unchanged
- Atomic commits with detailed change logs
- Instant rollback available at any stage

### Multi-Tool Approach
Claude Code understands your entire codebase through its terminal and IDE integrations, with Agent Teams allowing multiple instances to work in parallel on complex refactoring tasks.

### Incremental Approach
Break down large refactoring tasks into smaller, focused prompts to improve accuracy and avoid unintended changes. Focus on:
1. Dependency analysis: Generate dependency graphs, identify dead code
2. Test coverage first: Generate characterization tests that lock in current behavior
3. Phased implementation: Extract common functionality, improve error handling, update deprecated APIs
4. Human review: Let Claude propose changes, review them, provide feedback
