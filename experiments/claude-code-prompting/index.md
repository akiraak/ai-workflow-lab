# Claude Code プロンプティング調査

Claude Code に指示をするときの最適解を調査するシリーズ。

## Phase 1: 指示チャネルの整理と特性調査

| # | テーマ | 状態 |
|---|--------|------|
| 1-1 | [対話プロンプト（直接指示）の特性](./01-prompt-characteristics.md) | 完了 |
| 1-2 | [CLAUDE.md の活用法](./02-claude-md.md) | 完了 |
| 1-3 | [Plan mode の活用法](./03-plan-mode.md) | 完了 |
| 1-4 | [slash commands・ツール連携](./04-slash-commands.md) | 完了 |
| 1-5 | [Claude Code に最適なディレクトリ構成](./05-directory-structure.md) | 完了 |
| 1-6 | [.claude ディレクトリの内容と動作](./06-dot-claude.md) | 完了 |
| 1-7 | [ファイルを把握しやすくするための仕組み](./07-file-discovery.md) | 完了 |
| 1-8 | [コンテキスト制御](./08-context-control.md) | 完了 |

## Phase 2: タスク別の最適な指示パターンの調査

| # | テーマ | 状態 |
|---|--------|------|
| 2-1 | [バグ修正タスクにおける指示パターン](./09-task-bug-fix.md) | 完了 |
| 2-2 | [新機能実装タスクにおける指示パターン](./10-task-new-feature.md) | 完了 |
| 2-3 | [リファクタリングタスクにおける指示パターン](./11-task-refactoring.md) | 完了 |
| 2-4 | [コードレビュー・説明タスクにおける指示パターン](./12-task-code-review.md) | 完了 |

## Phase 3: 既存のベストプラクティス・アンチパターンの調査

| # | テーマ | 状態 |
|---|--------|------|
| 3-1 | [推奨パターン（ベストプラクティス）](./13-best-practices.md) | 完了 |
| 3-2 | [アンチパターン（避けるべき指示方法）](./14-anti-patterns.md) | 完了 |
| 3-3 | [CLAUDE.md の実例調査](./15-claude-md-examples.md) | 完了 |

## 横断分析

| # | テーマ | 状態 |
|---|--------|------|
| - | [Phase 1〜3 横断分析レポート](./16-cross-analysis.md) | 完了 |

## Phase 4B: 実証実験（コア仮説の検証）

| # | テーマ | 状態 |
|---|--------|------|
| B1 | [事実形式 vs 命令形式の遵守率比較](./17-B1-factual-vs-imperative.md) | 設計完了 |
| B2 | [否定形 vs 肯定形の違反率比較](./17-B2-positive-vs-negative.md) | 設計完了 |
| B3 | [CLAUDE.md 行数と遵守率の関係](./17-B3-claude-md-length.md) | 設計完了 |
| B4 | [Plan mode の初回成功率測定](./17-B4-plan-mode-success-rate.md) | 設計完了 |
| B5 | [TDD Bug Fix パターンの効果測定](./17-B5-tdd-bug-fix.md) | 設計完了 |
| B6 | [Hooks（lint 自動実行）の品質影響測定](./17-B6-hooks-lint-quality.md) | 設計完了 |
