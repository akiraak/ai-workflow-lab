---
url: https://medium.com/madhukarkumar/how-i-use-a-coding-agent-to-fix-production-bugs-3af26ce0e777
fetched_at: 2026-04-06T06:00:00+09:00
---

# How I Use a Coding Agent to Fix Production Bugs

(Content extracted from WebSearch summaries - full page fetch was restricted)

## Key Findings

### System Understanding First

Instead of diving straight into the bug, start with a broad question to ensure your AI partner understands the system. Ask it to explain relevant pages, API endpoints being called, and the SQL used to retrieve data.

### Effective Prompt Patterns

Use prompts like "Why do you think..." or "What is the SQL we are using..." that encourage deeper investigation rather than simple commands like "Fix this bug."

### Include Specific Examples

Include specific examples, URLs, or commands in your prompts to ground the conversation in concrete reality.

### Ask for Analysis, Not Just Fixes

Don't just fix symptoms—ask about data flow, performance implications, and backward compatibility. Ask for proposals and plans before making changes, as this often reveals better approaches.

### Verify with Specific Test Cases

After each fix, verify with specific test cases—for example, ask the agent to test with one user showing 252 posts instead of 10.

### Build Context Iteratively

Feed the AI the same information you'd give a colleague when asking for help: what the code is supposed to do, how it's misbehaving, relevant code snippets, and so on.
