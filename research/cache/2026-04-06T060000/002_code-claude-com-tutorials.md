---
url: https://code.claude.com/docs/en/tutorials
fetched_at: 2026-04-06T06:00:00+09:00
---

# Common workflows - Claude Code Docs

> Step-by-step guides for exploring codebases, fixing bugs, refactoring, testing, and other everyday tasks with Claude Code.

This page covers practical workflows for everyday development: exploring unfamiliar code, debugging, refactoring, writing tests, creating PRs, and managing sessions. Each section includes example prompts you can adapt to your own projects.

## Fix bugs efficiently

Suppose you've encountered an error message and need to find and fix its source.

1. **Share the error with Claude**
   ```
   I'm seeing an error when I run npm test
   ```

2. **Ask for fix recommendations**
   ```
   suggest a few ways to fix the @ts-ignore in user.ts
   ```

3. **Apply the fix**
   ```
   update user.ts to add the null check you suggested
   ```

Tips:
- Tell Claude the command to reproduce the issue and get a stack trace
- Mention any steps to reproduce the error
- Let Claude know if the error is intermittent or consistent

## Use Plan Mode for safe code analysis

Plan Mode instructs Claude to create a plan by analyzing the codebase with read-only operations, perfect for exploring codebases, planning complex changes, or reviewing code safely.

### When to use Plan Mode
- **Multi-step implementation**: When your feature requires making edits to many files
- **Code exploration**: When you want to research the codebase thoroughly before changing anything
- **Interactive development**: When you want to iterate on the direction with Claude

## Work with tests

1. **Identify untested code**
   ```
   find functions in NotificationsService.swift that are not covered by tests
   ```

2. **Generate test scaffolding**
   ```
   add tests for the notification service
   ```

3. **Add meaningful test cases**
   ```
   add test cases for edge conditions in the notification service
   ```

4. **Run and verify tests**
   ```
   run the new tests and fix any failures
   ```

Claude can generate tests that follow your project's existing patterns and conventions. For comprehensive coverage, ask Claude to identify edge cases you might have missed. Claude can analyze your code paths and suggest tests for error conditions, boundary values, and unexpected inputs that are easy to overlook.

## Use Claude as a unix-style utility

### Pipe in, pipe out

Pipe data through Claude:
```bash
cat build-error.txt | claude -p 'concisely explain the root cause of this build error' > output.txt
```

Tips:
- Use pipes to integrate Claude into existing shell scripts
- Combine with other Unix tools for powerful workflows
- Consider using `--output-format` for structured output
