---
url: https://code.claude.com/docs/en/output-styles
fetched_at: 2026-04-06T06:00:00+09:00
---

# Output styles

> Adapt Claude Code for uses beyond software engineering

Output styles allow you to use Claude Code as any type of agent while keeping its core capabilities.

## Built-in output styles

* **Default**: The existing system prompt for software engineering tasks.
* **Explanatory**: Provides educational "Insights" in between helping you complete software engineering tasks. Helps you understand implementation choices and codebase patterns.
* **Learning**: Collaborative, learn-by-doing mode where Claude shares "Insights" while coding, and asks you to contribute small, strategic pieces of code yourself with `TODO(human)` markers.

## How output styles work

Output styles directly modify Claude Code's system prompt.

* Custom output styles exclude instructions for coding unless `keep-coding-instructions` is true.
* All output styles have their own custom instructions added to the end of the system prompt.
* All output styles trigger reminders for Claude to adhere to the output style instructions during the conversation.

## Create a custom output style

Custom output styles are Markdown files with frontmatter:

```markdown
---
name: My Custom Style
description: A brief description of what this style does
---

# Custom Style Instructions

You are an interactive CLI tool that helps users with software engineering tasks.

## Specific Behaviors

[Define how the assistant should behave in this style...]
```

Save these files at user level (`~/.claude/output-styles`) or project level (`.claude/output-styles`).

### Frontmatter

| Frontmatter                | Purpose                                                                     | Default                 |
| :------------------------- | :-------------------------------------------------------------------------- | :---------------------- |
| `name`                     | Name of the output style                                                    | Inherits from file name |
| `description`              | Description shown in the `/config` picker                                   | None                    |
| `keep-coding-instructions` | Whether to keep coding-related system prompt parts                          | false                   |

## Comparisons

### Output Styles vs. CLAUDE.md vs. --append-system-prompt

Output styles completely "turn off" the parts of Claude Code's default system prompt specific to software engineering. Neither CLAUDE.md nor `--append-system-prompt` edit the default system prompt.

### Output Styles vs. Skills

Output styles modify how Claude responds (formatting, tone, structure) and are always active once selected. Skills are task-specific prompts invoked with `/skill-name` or loaded automatically when relevant.

## --output-format flag

Controls how Claude Code structures its responses in non-interactive mode:
- **text**: Human-readable plain text (default)
- **json**: Structured data with metadata
- **stream-json**: Real-time streaming JSON for progressive processing
