---
url: https://github.com/anthropics/claude-code-action/blob/main/CLAUDE.md
fetched_at: 2026-04-06T12:00:00Z
---

# CLAUDE.md — anthropics/claude-code-action

## Commands
```bash
bun test              # Run tests
bun run typecheck     # TypeScript type checking
bun run format        # Format with prettier
bun run format:check  # Check formatting
```

## What This Is
A GitHub Action that lets Claude respond to @claude mentions on issues/PRs (tag mode) or run tasks via prompt input (agent mode). Mode is auto-detected. See src/modes/detector.ts.

## How It Runs
Single entrypoint: src/entrypoints/run.ts orchestrates everything — prepare (auth, permissions, trigger check, branch/comment creation), install Claude Code CLI, execute Claude via base-action/ functions (imported directly, not subprocess), then cleanup.

base-action/ is also published standalone as @anthropic-ai/claude-code-base-action. Don't break its public API. It reads config from INPUT_-prefixed env vars.

## Key Concepts
- Auth priority: github_token input > GitHub App OIDC token
- Mode lifecycle: detectMode() picks "tag" or "agent"
- Prompt construction: fetches GitHub data, formats as markdown, writes to temp file

## Things That Will Bite You
- Strict TypeScript: noUnusedLocals and noUnusedParameters enabled
- Discriminated unions for GitHub context: call isEntityContext(context) first
- Token lifecycle matters: revoked in separate always() step
- Error phase attribution: prepareCompleted flag distinguishes failures
- action.yml outputs reference step IDs: don't rename without updating
- Integration testing in separate repo, not here

## Code Conventions
- Runtime is Bun, not Node
- moduleResolution: "bundler" — no .js extensions needed
- GitHub API calls should use retry logic (src/utils/retry.ts)
- MCP servers auto-installed at runtime
