---
url: https://code.claude.com/docs/en/common-workflows
fetched_at: 2026-04-06T06:00:00+09:00
---

# Common workflows - Claude Code Docs

## Refactor code

Suppose you need to update old code to use modern patterns and practices.

1. **Identify legacy code for refactoring**
   ```
   find deprecated API usage in our codebase
   ```

2. **Get refactoring recommendations**
   ```
   suggest how to refactor utils.js to use modern JavaScript features
   ```

3. **Apply the changes safely**
   ```
   refactor utils.js to use ES2024 features while maintaining the same behavior
   ```

4. **Verify the refactoring**
   ```
   run tests for the refactored code
   ```

Tips:
- Ask Claude to explain the benefits of the modern approach
- Request that changes maintain backward compatibility when needed
- Do refactoring in small, testable increments

## Use Plan Mode for safe code analysis

Plan Mode instructs Claude to create a plan by analyzing the codebase with read-only operations, perfect for exploring codebases, planning complex changes, or reviewing code safely.

### When to use Plan Mode
- Multi-step implementation: When your feature requires making edits to many files
- Code exploration: When you want to research the codebase thoroughly before changing anything
- Interactive development: When you want to iterate on the direction with Claude

### Example: Planning a complex refactor

```
claude --permission-mode plan
```

```
I need to refactor our authentication system to use OAuth2. Create a detailed migration plan.
```

Claude analyzes the current implementation and creates a comprehensive plan. Refine with follow-ups:
- "What about backward compatibility?"
- "How should we handle database migration?"

Press Ctrl+G to open the plan in your default text editor, where you can edit it directly before Claude proceeds.

## Fan out across files

For large migrations or analyses, distribute work across many parallel Claude invocations:
1. Generate a task list
2. Write a script to loop through the list using claude -p
3. Test on a few files, then run at scale

## Run multiple Claude sessions

Use a Writer/Reviewer pattern:
- Session A (Writer): "Implement a rate limiter for our API endpoints"
- Session B (Reviewer): "Review the rate limiter implementation in @src/middleware/rateLimiter.ts. Look for edge cases, race conditions, and consistency with our existing middleware patterns."
