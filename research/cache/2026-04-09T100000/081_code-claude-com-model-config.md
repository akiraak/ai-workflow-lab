---
url: https://code.claude.com/docs/en/model-config
fetched_at: 2026-04-09T10:00:00+09:00
---

# Model configuration

> Learn about the Claude Code model configuration, including model aliases like `opusplan`

## Available models

For the `model` setting in Claude Code, you can configure either:

- A **model alias**
- A **model name** (full model name for Anthropic API, inference profile ARN for Bedrock, deployment name for Foundry, version name for Vertex)

### Model aliases

| Model alias      | Behavior                                                                                          |
| ---------------- | ------------------------------------------------------------------------------------------------- |
| **`default`**    | Clears any model override and reverts to the recommended model for your account type              |
| **`best`**       | Uses the most capable available model, currently equivalent to `opus`                             |
| **`sonnet`**     | Uses the latest Sonnet model (currently Sonnet 4.6) for daily coding tasks                       |
| **`opus`**       | Uses the latest Opus model (currently Opus 4.6) for complex reasoning tasks                      |
| **`haiku`**      | Uses the fast and efficient Haiku model for simple tasks                                          |
| **`sonnet[1m]`** | Uses Sonnet with a 1 million token context window for long sessions                              |
| **`opus[1m]`**   | Uses Opus with a 1 million token context window for long sessions                                |
| **`opusplan`**   | Special mode that uses `opus` during plan mode, then switches to `sonnet` for execution          |

### Setting your model

You can configure your model in several ways, listed in order of priority:

1. **During session** - Use `/model <alias|name>` to switch models mid-session
2. **At startup** - Launch with `claude --model <alias|name>`
3. **Environment variable** - Set `ANTHROPIC_MODEL=<alias|name>`
4. **Settings** - Configure permanently in your settings file using the `model` field.

## Special model behavior

### `default` model setting

The behavior of `default` depends on your account type:

- **Max and Team Premium**: defaults to Opus 4.6
- **Pro and Team Standard**: defaults to Sonnet 4.6
- **Enterprise**: Opus 4.6 is available but not the default

Claude Code may automatically fall back to Sonnet if you hit a usage threshold with Opus.

### `opusplan` model setting

The `opusplan` model alias provides an automated hybrid approach:

- **In plan mode** - Uses `opus` for complex reasoning and architecture decisions
- **In execution mode** - Automatically switches to `sonnet` for code generation and implementation

This gives you the best of both worlds: Opus's superior reasoning for planning, and Sonnet's efficiency for execution.

### Adjust effort level

Effort levels control adaptive reasoning, which dynamically allocates thinking based on task complexity. Lower effort is faster and cheaper for straightforward tasks, while higher effort provides deeper reasoning for complex problems.

Three levels persist across sessions: **low**, **medium**, and **high**. A fourth level, **max**, provides the deepest reasoning with no constraint on token spending, so responses are slower and cost more than at `high`. `max` is available on Opus 4.6 only and does not persist across sessions.

The default effort level depends on your plan. Pro and Max subscribers default to medium effort. All other users default to high effort.

Setting effort:

- **`/effort`**: run `/effort low`, `/effort medium`, `/effort high`, or `/effort max`
- **In `/model`**: use left/right arrow keys to adjust the effort slider
- **`--effort` flag**: pass `low`, `medium`, `high`, or `max` at launch
- **Environment variable**: set `CLAUDE_CODE_EFFORT_LEVEL`
- **Settings**: set `effortLevel` in your settings file
- **Skill and subagent frontmatter**: set `effort` in a skill or subagent markdown file

For one-off deep reasoning without changing your session setting, include "ultrathink" in your prompt to trigger high effort for that turn.

### Extended context

Opus 4.6 and Sonnet 4.6 support a 1 million token context window for long sessions with large codebases.

| Plan                      | Opus 4.6 with 1M context | Sonnet 4.6 with 1M context |
| ------------------------- | ------------------------ | -------------------------- |
| Max, Team, and Enterprise | Included with subscription | Requires extra usage       |
| Pro                       | Requires extra usage     | Requires extra usage       |
| API and pay-as-you-go     | Full access              | Full access                |

The 1M context window uses standard model pricing with no premium for tokens beyond 200K.

## Restrict model selection

Enterprise administrators can use `availableModels` in managed or policy settings to restrict which models users can select.

## Environment variables

| Environment variable             | Description                                                              |
| -------------------------------- | ------------------------------------------------------------------------ |
| `ANTHROPIC_DEFAULT_OPUS_MODEL`   | The model to use for `opus`, or for `opusplan` when Plan Mode is active  |
| `ANTHROPIC_DEFAULT_SONNET_MODEL` | The model to use for `sonnet`, or for `opusplan` in execution mode       |
| `ANTHROPIC_DEFAULT_HAIKU_MODEL`  | The model to use for `haiku`, or background functionality                |
| `CLAUDE_CODE_SUBAGENT_MODEL`     | The model to use for subagents                                           |

### Prompt caching configuration

| Environment variable            | Description                                                       |
| ------------------------------- | ----------------------------------------------------------------- |
| `DISABLE_PROMPT_CACHING`        | Set to `1` to disable prompt caching for all models               |
| `DISABLE_PROMPT_CACHING_HAIKU`  | Set to `1` to disable prompt caching for Haiku models only        |
| `DISABLE_PROMPT_CACHING_SONNET` | Set to `1` to disable prompt caching for Sonnet models only       |
| `DISABLE_PROMPT_CACHING_OPUS`   | Set to `1` to disable prompt caching for Opus models only         |
