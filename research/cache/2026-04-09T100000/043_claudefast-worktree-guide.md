---
url: https://claudefa.st/blog/guide/development/worktree-guide
fetched_at: 2026-04-09T10:00:00+09:00
---

# Claude Code Worktrees: Parallel Sessions Without Conflicts

Claude Code v2.1.50 introduces git worktree support for running isolated parallel sessions.

## Core Concept

Worktrees solve a fundamental problem: multiple Claude sessions editing the same files simultaneously cause merge conflicts. Git worktrees create separate checkouts with independent branches and working directories.

## CLI Usage: `--worktree` Flag

### Named Worktrees

```bash
claude --worktree feature-auth
```

Creates `.claude/worktrees/feature-auth/` with branch `worktree-feature-auth`.

### Auto-Named Worktrees

```bash
claude --worktree
```

Claude generates a unique identifier for throwaway sessions.

### Multiple Parallel Sessions

```bash
# Terminal 1
claude --worktree feature-auth

# Terminal 2
claude --worktree bugfix-123

# Terminal 3
claude --worktree experiment-new-router
```

### Mid-Session Activation

Request during any conversation: "work in a worktree" — Claude creates isolation mid-session.

## Desktop App Features

The Desktop application automatically isolates every new session in `.claude/worktrees/`. Settings allow customization of storage location and branch naming conventions. Archive completed sessions to remove their worktrees and branches.

## Subagent Isolation Patterns

### Automatic Agent Isolation

```
You: Use worktrees for your agents when doing this refactor
```

Claude spawns sub-agents in separate worktrees, preventing file conflicts during parallel execution.

### Custom Agent Configuration

```yaml
---
name: refactor-agent
isolation: worktree
---
```

The `isolation: worktree` directive ensures fresh isolation per execution.

## Practical Use Cases

**Ideal for worktrees:**
- Running multiple agents in parallel on overlapping code
- Code migrations across numerous files (distribute across isolated agents)
- Exploring experimental approaches in throwaway sessions
- Simultaneous feature development and bug fixes

**Skip worktrees for:**
- Single-file quick fixes
- Focused individual sessions

## Cleanup & Housekeeping

- **No changes made**: Worktree and branch auto-delete on session end
- **Changes exist**: Claude prompts retention/removal decisions
- Add `.claude/worktrees/` to `.gitignore`
- Prune manually: `git worktree list` and `git worktree prune`

## Non-Git VCS Support

Configure `WorktreeCreate` and `WorktreeRemove` hooks in settings to use Mercurial, Perforce, or SVN instead of git commands.

## Key Workflow Benefits

Worktrees enable true parallel development: Agent A rewrites `src/auth.ts` while Agent B rewrites the same module differently. Review both branches and select the optimal approach without conflicts.
