---
url: https://github.com/anthropics/claude-code/tree/main/plugins/explanatory-output-style
fetched_at: 2026-04-06T06:00:00+09:00
---

# Explanatory Output Style Plugin

## Overview

This plugin recreates the deprecated Explanatory output style as a SessionStart hook for Claude Code.

## What It Does

When enabled, this plugin automatically adds instructions at the start of each session that encourage Claude to:

1. Provide educational insights about implementation choices
2. Explain codebase patterns and decisions
3. Balance task completion with learning opportunities

## How It Works

The plugin uses a SessionStart hook to inject additional context into every session:

```
★ Insight ─────────────────────────────────────
[2-3 key educational points]
─────────────────────────────────────────────────
```

## Focus Areas

The insights concentrate on:
- Specific implementation choices for your codebase
- Patterns and conventions in your code
- Trade-offs and design decisions
- Codebase-specific details rather than general programming concepts

## Migration from Output Styles

This plugin replaces the deprecated "Explanatory" output style setting. Previously:

```json
{
  "outputStyle": "Explanatory"
}
```

Now use this plugin instead.

### Relationship to CLAUDE.md

This SessionStart hook pattern is roughly equivalent to CLAUDE.md, but more flexible and distributable through plugins.

Note: Output styles for tasks besides software development are better expressed as subagents, not SessionStart hooks. Subagents change the system prompt while SessionStart hooks add to the default system prompt.
