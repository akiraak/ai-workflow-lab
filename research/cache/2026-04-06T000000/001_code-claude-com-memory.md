---
url: https://code.claude.com/docs/en/memory
fetched_at: 2026-04-06
---

# How Claude remembers your project (Official Docs - English)

## CLAUDE.md files

CLAUDE.md files are markdown files that give Claude persistent instructions. Loaded at the start of every session.

### Locations and Scope

| Scope | Location | Purpose | Shared with |
|-------|----------|---------|-------------|
| Managed policy | OS-level paths | Organization-wide instructions | All users |
| Project instructions | ./CLAUDE.md or ./.claude/CLAUDE.md | Team-shared instructions | Team via source control |
| User instructions | ~/.claude/CLAUDE.md | Personal preferences for all projects | Just you |
| Local instructions | ./CLAUDE.local.md | Personal project-specific; add to .gitignore | Just you (current project) |

### Write effective instructions

- **Size**: target under 200 lines per CLAUDE.md file
- **Structure**: use markdown headers and bullets to group related instructions
- **Specificity**: write instructions that are concrete enough to verify
- **Consistency**: if two rules contradict, Claude may pick one arbitrarily

### Import additional files

- Use `@path/to/import` syntax
- Both relative and absolute paths allowed
- Max depth: five hops

### How CLAUDE.md files load

- Walks up directory tree from CWD
- All discovered files concatenated (not overriding)
- CLAUDE.local.md appended after CLAUDE.md at each level
- Subdirectory CLAUDE.md loaded on demand when Claude reads files there
- HTML comments stripped before injection (preserve in code blocks)

### .claude/rules/

- Organize instructions into multiple files
- Each file should cover one topic
- Path-specific rules via YAML frontmatter with `paths` field
- Files without `paths` loaded unconditionally at launch
- Symlinks supported for sharing rules across projects
- User-level rules in ~/.claude/rules/ (lower priority than project rules)

### Large teams

- Managed CLAUDE.md at OS-level paths
- claudeMdExcludes setting to skip specific files
- Managed policy files cannot be excluded

### Auto memory vs CLAUDE.md

| | CLAUDE.md | Auto memory |
|--|-----------|-------------|
| Who writes | You | Claude |
| Contains | Instructions and rules | Learnings and patterns |
| Scope | Project, user, or org | Per working tree |
| Loaded into | Every session | Every session (first 200 lines / 25KB) |
