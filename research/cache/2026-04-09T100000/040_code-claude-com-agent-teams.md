---
url: https://code.claude.com/docs/en/agent-teams
fetched_at: 2026-04-09T10:00:00+09:00
---

# Orchestrate teams of Claude Code sessions

> Coordinate multiple Claude Code instances working together as a team, with shared tasks, inter-agent messaging, and centralized management.

> Warning: Agent teams are experimental and disabled by default. Enable them by adding `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS` to your settings.json or environment. Agent teams have known limitations around session resumption, task coordination, and shutdown behavior.

Agent teams let you coordinate multiple Claude Code instances working together. One session acts as the team lead, coordinating work, assigning tasks, and synthesizing results. Teammates work independently, each in its own context window, and communicate directly with each other.

Unlike subagents, which run within a single session and can only report back to the main agent, you can also interact with individual teammates directly without going through the lead.

> Note: Agent teams require Claude Code v2.1.32 or later. Check your version with `claude --version`.

## When to use agent teams

Agent teams are most effective for tasks where parallel exploration adds real value:

- **Research and review**: multiple teammates can investigate different aspects of a problem simultaneously, then share and challenge each other's findings
- **New modules or features**: teammates can each own a separate piece without stepping on each other
- **Debugging with competing hypotheses**: teammates test different theories in parallel and converge on the answer faster
- **Cross-layer coordination**: changes that span frontend, backend, and tests, each owned by a different teammate

Agent teams add coordination overhead and use significantly more tokens than a single session. They work best when teammates can operate independently. For sequential tasks, same-file edits, or work with many dependencies, a single session or subagents are more effective.

### Compare with subagents

|                   | Subagents                                        | Agent teams                                         |
| :---------------- | :----------------------------------------------- | :-------------------------------------------------- |
| **Context**       | Own context window; results return to the caller | Own context window; fully independent               |
| **Communication** | Report results back to the main agent only       | Teammates message each other directly               |
| **Coordination**  | Main agent manages all work                      | Shared task list with self-coordination             |
| **Best for**      | Focused tasks where only the result matters      | Complex work requiring discussion and collaboration |
| **Token cost**    | Lower: results summarized back to main context   | Higher: each teammate is a separate Claude instance |

## Enable agent teams

Agent teams are disabled by default. Enable them by setting the `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS` environment variable to `1`:

```json
{
  "env": {
    "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"
  }
}
```

## Start your first agent team

After enabling agent teams, tell Claude to create an agent team and describe the task and the team structure you want in natural language.

Example:

```
I'm designing a CLI tool that helps developers track TODO comments across
their codebase. Create an agent team to explore this from different angles: one
teammate on UX, one on technical architecture, one playing devil's advocate.
```

## Control your agent team

### Choose a display mode

- **In-process**: all teammates run inside your main terminal. Use Shift+Down to cycle through teammates.
- **Split panes**: each teammate gets its own pane. Requires tmux or iTerm2.

### Specify teammates and models

Claude decides the number of teammates based on your task, or you can specify:

```
Create a team with 4 teammates to refactor these modules in parallel.
Use Sonnet for each teammate.
```

### Require plan approval for teammates

```
Spawn an architect teammate to refactor the authentication module.
Require plan approval before they make any changes.
```

### Talk to teammates directly

Each teammate is a full, independent Claude Code session. You can message any teammate directly.

### Assign and claim tasks

The shared task list coordinates work across the team. Tasks have three states: pending, in progress, and completed. Tasks can depend on other tasks. Task claiming uses file locking to prevent race conditions.

### Shut down teammates and clean up

```
Ask the researcher teammate to shut down
Clean up the team
```

### Enforce quality gates with hooks

- `TeammateIdle`: runs when a teammate is about to go idle
- `TaskCreated`: runs when a task is being created
- `TaskCompleted`: runs when a task is being marked complete

## How agent teams work

### Architecture

| Component     | Role                                                                                       |
| :------------ | :----------------------------------------------------------------------------------------- |
| **Team lead** | The main Claude Code session that creates the team, spawns teammates, and coordinates work |
| **Teammates** | Separate Claude Code instances that each work on assigned tasks                            |
| **Task list** | Shared list of work items that teammates claim and complete                                |
| **Mailbox**   | Messaging system for communication between agents                                          |

Teams and tasks are stored locally:
- Team config: `~/.claude/teams/{team-name}/config.json`
- Task list: `~/.claude/tasks/{team-name}/`

### Use subagent definitions for teammates

You can reference a subagent type from any subagent scope when spawning a teammate.

### Permissions

Teammates start with the lead's permission settings.

### Context and communication

Each teammate has its own context window. When spawned, a teammate loads the same project context as a regular session: CLAUDE.md, MCP servers, and skills.

Teammates communicate via:
- **Automatic message delivery**
- **Idle notifications**
- **Shared task list**

### Token usage

Each teammate has its own context window, and token usage scales with the number of active teammates.

## Best practices

### Give teammates enough context

Include task-specific details in the spawn prompt.

### Choose an appropriate team size

Start with 3-5 teammates for most workflows. Having 5-6 tasks per teammate keeps everyone productive.

### Size tasks appropriately

- Too small: coordination overhead exceeds the benefit
- Too large: teammates work too long without check-ins
- Just right: self-contained units that produce a clear deliverable

### Wait for teammates to finish

Sometimes the lead starts implementing tasks itself instead of waiting.

### Start with research and review

Start with tasks that have clear boundaries and don't require writing code.

### Avoid file conflicts

Two teammates editing the same file leads to overwrites. Break the work so each teammate owns a different set of files.

### Monitor and steer

Check in on teammates' progress, redirect approaches that aren't working.

## Use case examples

### Run a parallel code review

```
Create an agent team to review PR #142. Spawn three reviewers:
- One focused on security implications
- One checking performance impact
- One validating test coverage
```

### Investigate with competing hypotheses

```
Users report the app exits after one message instead of staying connected.
Spawn 5 agent teammates to investigate different hypotheses. Have them talk to
each other to try to disprove each other's theories, like a scientific debate.
```

## Limitations

- No session resumption with in-process teammates
- Task status can lag
- Shutdown can be slow
- One team per session
- No nested teams
- Lead is fixed
- Permissions set at spawn
- Split panes require tmux or iTerm2

> Tip: CLAUDE.md works normally: teammates read CLAUDE.md files from their working directory.
