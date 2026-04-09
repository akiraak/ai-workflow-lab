# AI Workflow Lab

AI を普段の開発・作業ワークフローに組み込む手法の調査・検証。

## Claude Code プロンプティング調査

### Phase 1: 指示チャネルの整理と特性調査

| # | テーマ | 状態 |
|---|--------|------|
| 1-1 | [対話プロンプト（直接指示）の特性](./experiments/claude-code-prompting/01-prompt-characteristics.md) | 完了 |
| 1-2 | [CLAUDE.md の活用法](./experiments/claude-code-prompting/02-claude-md.md) | 完了 |
| 1-3 | [Plan mode の活用法](./experiments/claude-code-prompting/03-plan-mode.md) | 完了 |
| 1-4 | [slash commands・ツール連携](./experiments/claude-code-prompting/04-slash-commands.md) | 完了 |
| 1-5 | [Claude Code に最適なディレクトリ構成](./experiments/claude-code-prompting/05-directory-structure.md) | 完了 |
| 1-6 | [.claude ディレクトリの内容と動作](./experiments/claude-code-prompting/06-dot-claude.md) | 完了 |
| 1-7 | [ファイルを把握しやすくするための仕組み](./experiments/claude-code-prompting/07-file-discovery.md) | 完了 |
| 1-8 | [コンテキスト制御](./experiments/claude-code-prompting/08-context-control.md) | 完了 |

### Phase 2: タスク別の最適な指示パターン

| # | テーマ | 状態 |
|---|--------|------|
| 2-1 | [バグ修正タスクにおける指示パターン](./experiments/claude-code-prompting/09-task-bug-fix.md) | 完了 |
| 2-2 | [新機能実装タスクにおける指示パターン](./experiments/claude-code-prompting/10-task-new-feature.md) | 完了 |
| 2-3 | [リファクタリングタスクにおける指示パターン](./experiments/claude-code-prompting/11-task-refactoring.md) | 完了 |
| 2-4 | [コードレビュー・説明タスクにおける指示パターン](./experiments/claude-code-prompting/12-task-code-review.md) | 完了 |

### Phase 3: 既存のベストプラクティス・アンチパターン

| # | テーマ | 状態 |
|---|--------|------|
| 3-1 | [推奨パターン（ベストプラクティス）](./experiments/claude-code-prompting/13-best-practices.md) | 完了 |
| 3-2 | [アンチパターン（避けるべき指示方法）](./experiments/claude-code-prompting/14-anti-patterns.md) | 完了 |
| 3-3 | [CLAUDE.md の実例調査](./experiments/claude-code-prompting/15-claude-md-examples.md) | 完了 |

### 横断分析

| # | テーマ | 状態 |
|---|--------|------|
| — | [Phase 1〜3 横断分析レポート](./experiments/claude-code-prompting/16-cross-analysis.md) | 完了 |

### Phase 4B: 実証実験

コミュニティ知見のうち定量データが存在しなかった 6 仮説を実証実験で検証。

| # | テーマ | 判定 |
|---|--------|------|
| — | [概要・全体サマリー](./experiments/phase-4b/index.md) | — |
| B1 | [事実形式 vs 命令形式](./experiments/phase-4b/B1.md) | 不支持 |
| B2 | [否定形 vs 肯定形](./experiments/phase-4b/B2.md) | 不支持 |
| B3 | [CLAUDE.md 行数と遵守率](./experiments/phase-4b/B3.md) | 不支持（逆転） |
| B4 | [Plan mode 初回成功率](./experiments/phase-4b/B4.md) | 不支持 |
| B5 | [TDD Bug Fix 効果](./experiments/phase-4b/B5.md) | 不支持 |
| B6 | [Hooks 品質影響](./experiments/phase-4b/B6.md) | 支持 |
| — | [統合レポート](./experiments/claude-code-prompting/18-phase4b-integrated-report.md) | 完了 |

## Web 調査キャッシュ

調査時に参照した Web ページのキャッシュを日付ごとに保存しています。

| 日付 | テーマ |
|------|--------|
| [2026-04-05](./research/cache/2026-04-05T000000/) | 対話プロンプトの特性調査 (Phase 1-1) |
| [2026-04-06](./research/cache/2026-04-06T000000/) | CLAUDE.md の活用法 (Phase 1-2) |
| [2026-04-06 (2)](./research/cache/2026-04-06T060000/) | タスク別指示パターン (Phase 2) |
| [2026-04-06 (3)](./research/cache/2026-04-06T120000/) | ベストプラクティス・アンチパターン・CLAUDE.md 実例 (Phase 3) |
