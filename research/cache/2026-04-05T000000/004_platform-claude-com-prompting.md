---
url: https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/claude-prompting-best-practices
fetched_at: 2026-04-05
---

# Prompting best practices (Claude API)

## General principles

### Be clear and direct
- Claude responds well to clear, explicit instructions
- Think of Claude as a brilliant but new employee who lacks context
- Golden rule: Show your prompt to a colleague with minimal context. If they'd be confused, Claude will be too.
- Be specific about output format and constraints
- Use numbered lists or bullet points when order/completeness matters

### Add context to improve performance
- Provide motivation behind instructions (why such behavior is important)
- Claude is smart enough to generalize from explanations

### Use examples effectively
- 3-5 examples for best results (few-shot/multishot prompting)
- Make examples relevant, diverse, and structured
- Wrap in <example> tags

### Structure prompts with XML tags
- Use consistent, descriptive tag names
- Nest tags for natural hierarchy

### Give Claude a role
- Setting a role focuses behavior and tone

### Long context prompting
- Put longform data at the top of prompt
- Structure with XML tags
- Ground responses in quotes for long documents

## Tool use
- Be explicit about taking action: "Change this function" not "Can you suggest changes"
- Claude's latest models benefit from explicit direction

## Agentic systems
- Claude Opus 4.6 may overengineer by default
- Add guidance to keep solutions minimal when needed
- Avoid focusing on passing tests and hard-coding
