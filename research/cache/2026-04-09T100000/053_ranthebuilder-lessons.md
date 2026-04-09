---
url: https://ranthebuilder.cloud/blog/claude-code-best-practices-lessons-from-real-projects/
fetched_at: 2026-04-09T10:00:00+09:00
---

# Claude Code Best Practices: Lessons From Real Projects

By Ran Isenberg

## Overview

Ran Isenberg shares practical insights from shipping three real projects with Claude Code, focusing on setup, methodology choices, and production-ready practices.

## Claude Code Setup

Daily toolkit:
- **IDE**: VS Code with Claude Code extension
- **Models**: Opus for complex architecture/security; Sonnet for planning
- **Methodology**: BMAD for substantial projects; plan mode for smaller features
- **MCP Servers**: Chrome Browser, Playwright, GitHub
- **Skills**: Security review, SEO analysis, web accessibility, web design
- **Cowork**: Blog refinement, presentations, creative writing

## Three Project Case Studies

### Project 1: ranthebuilder.cloud Website

Claude Code handled initial development impressively, but doesn't automatically optimize for production concerns like SEO, Google Analytics integration, security hardening, or PageSpeed optimization.

**Key Learning**: "your domain expertise is the bottleneck, not the tool"

### Project 2: Propel Kanban Board (BMAD Method)

For a custom Mac application, BMAD alongside Claude Code. The framework's brainstorming phase identified 36 user flows and uncovered spec contradictions and security risks.

Benefits: discovering scenarios that would have surfaced weeks into development through painful debugging.

### Project 3: mac-folder-sync (Plan Mode)

Smaller project used Claude Code's plan mode. Testing revealed security issues, unexpected behavior with empty syncs, and missed failure modes.

**Rule of Thumb**: Use BMAD for substantial projects with real users, external integrations, or security surface area. Plan mode works for smaller features, but developers must ask difficult questions proactively.

## CLAUDE.md Structure

Project context file includes:
1. Project overview and target audience
2. Tech stack and framework versions
3. Key build, test, deploy commands
4. Project structure documentation
5. Coding conventions
6. Critical rules (no secrets commits, accessibility requirements)

**Guideline**: Keep files under 200 lines; link required skills using "import" statements.

## Key Takeaway

Success with Claude Code depends more on the developer's expertise than the tool itself. Solid context documentation, strategic skill selection, and understanding when to apply different methodologies matter far more than the underlying AI capabilities.
