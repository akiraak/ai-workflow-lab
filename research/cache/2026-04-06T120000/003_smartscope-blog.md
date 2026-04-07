---
url: https://smartscope.blog/en/generative-ai/claude/claude-code-prompting-official-guidelines-2025/
fetched_at: 2026-04-06T12:00:00Z
---

# Claude Code Prompting Guide 2025 | 10 Essential Practical Techniques

## The Official 4-Phase Workflow

Phase 1: Explore → Phase 2: Plan → Phase 3: Implement → Phase 4: Verify & Commit

| Phase | Purpose | Recommended Mode |
|-------|---------|------------------|
| Phase 1: Explore | Understand the codebase | Plan Mode (Shift+Tab) |
| Phase 2: Plan | Design the solution | Plan Mode |
| Phase 3: Implement | Execute changes | Normal Mode |
| Phase 4: Verify | Test, review, and commit | Normal Mode |

## Phase 1: Explore Prompts
- "Explain the overall structure of this repository."
- "Read @src/auth/handler.ts and explain the complete authentication flow."

## Phase 2: Plan Prompts
- 制約を明示した実装計画の作成
- 複数アプローチの比較分析

## Phase 3: Implement Prompts

### Context-First Prompting
コンテキストをリクエストの前に提示すると実装精度が向上する。

### Clear Constraint Specification
明示的な制約指定がコード品質を大幅に改善する。

### CLI Tool Usage
外部サービス連携には CLI ツールが最も効率的。

## Phase 4: Verify Prompts
- テスト実行と修正
- 多角的レビュー（エッジケース、セキュリティ、パフォーマンス、後方互換性）

## Extended Thinking Configuration
- Settings file: alwaysThinkingEnabled: true
- Environment variable: CLAUDE_CODE_EFFORT_LEVEL
- Plan Mode: Shift+Tab

## Context Management Techniques
- @filepath でファイル追加
- /compact でコンテキスト圧縮
- /clear でリセット
- 2回修正失敗したらリセット

## Common Failure Patterns
1. Kitchen Sink Session — タスクごとにセッション分離
2. Repeated Corrections — /clear でリセット
3. Over-Specified CLAUDE.md — 簡潔に保つ
4. Trust-then-Verify Gap — 検証を必ず含める
5. Infinite Exploration — スコープを限定
