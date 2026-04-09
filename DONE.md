# DONE

完了したタスクの記録です。

<!-- 形式: - [x] タスク内容 (完了日: YYYY-MM-DD) -->

## 実装
- [x] 調査結果をWebで見れるようにする — VitePress で構築 (完了日: 2026-04-06)

## Claude Code
- [x] Claude Code に指示をするときの最適解の調査 — Phase 1〜3 全完了 (完了日: 2026-04-06)
- [x] Phase 1-1: 対話プロンプト（直接指示）の特性調査 (完了日: 2026-04-05)
- [x] Phase 1-2: CLAUDE.md の活用法調査 (完了日: 2026-04-06)
- [x] Phase 1-3: Plan mode の活用法調査 (完了日: 2026-04-06)
- [x] Phase 1-4: slash commands・ツール連携の調査 (完了日: 2026-04-06)
- [x] Phase 1-5: Claude Code に最適なディレクトリ構成の調査 (完了日: 2026-04-06)
- [x] Phase 1-6: .claude ディレクトリの内容と動作の調査 (完了日: 2026-04-06)
- [x] Phase 1-7: ファイル把握の仕組みの調査 (完了日: 2026-04-06)
- [x] Phase 1-8: コンテキスト制御の調査 (完了日: 2026-04-06)
- [x] Phase 2-1: バグ修正タスクにおける指示パターンの調査 (完了日: 2026-04-06)
- [x] Phase 2-2: 新機能実装タスクにおける指示パターンの調査 (完了日: 2026-04-06)
- [x] Phase 2-3: リファクタリングタスクにおける指示パターンの調査 (完了日: 2026-04-06)
- [x] Phase 2-4: コードレビュー・説明タスクにおける指示パターンの調査 (完了日: 2026-04-06)
- [x] Phase 3-1: 推奨パターンの調査 (完了日: 2026-04-06)
- [x] Phase 3-2: アンチパターンの調査 (完了日: 2026-04-06)
- [x] Phase 3-3: CLAUDE.md の実例調査 (完了日: 2026-04-06)
- [x] Phase 1〜3 横断分析と追加調査の方向性決定 (完了日: 2026-04-07)
- [x] Phase 4A: ガイドライン化（知見の実用化）— 5件の成果物を作成 (完了日: 2026-04-07)
  - A1: CLAUDE.md テンプレート (`templates/claude-md-template.md`)
  - A2: タスク別プロンプトテンプレート (`templates/task-prompts/` — 4種)
  - A3: 段階的ワークフローガイド (`guides/workflow.md`)
  - A4: コンテキスト管理チートシート (`guides/context-management.md`)
  - A5: 検証手段の設計ガイド (`guides/verification.md`)
- [x] Phase 4B: サンプルプロジェクト作成 + 設計書 6 本 (完了日: 2026-04-07)
  - サンプルプロジェクト: `experiments/phase-4b/sample-project/` (TypeScript, vitest, eslint)
  - B1: 事実形式 vs 命令形式 (`17-B1-factual-vs-imperative.md`)
  - B2: 否定形 vs 肯定形 (`17-B2-positive-vs-negative.md`)
  - B3: CLAUDE.md 行数と遵守率 (`17-B3-claude-md-length.md`)
  - B4: Plan mode 初回成功率 (`17-B4-plan-mode-success-rate.md`)
  - B5: TDD Bug Fix 効果 (`17-B5-tdd-bug-fix.md`)
  - B6: Hooks 品質影響 (`17-B6-hooks-lint-quality.md`)
- [x] Phase 4B: 実験素材の作成（CLAUDE.md バリアント、プロンプト、判定スクリプト）(完了日: 2026-04-07)
  - CLAUDE.md バリアント 10 本 (`experiments/phase-4b/claude-md-variants/`)
  - プロンプトファイル 11 本 (`experiments/phase-4b/prompts/`)
  - バグパッチ 2 本 (`experiments/phase-4b/scripts/bug{1,2}-*.patch`)
  - 判定スクリプト 4 本 (`experiments/phase-4b/scripts/judge-*.sh`)
  - 実験ランナースクリプト (`experiments/phase-4b/scripts/run-experiment.sh`)
- [x] Phase 4B-B1: 事実形式 vs 命令形式の遵守率比較 (完了日: 2026-04-07)
  - Factual 平均 9.4/10, Imperative 平均 9.0/10 (各 10 試行)
  - 結果: `experiments/phase-4b/results/B1/results.csv`
- [x] Phase 4B-B2: 否定形 vs 肯定形の違反率比較 (完了日: 2026-04-08)
  - Positive（肯定形）平均 8.9/10, Negative（否定形）平均 9.1/10 (各 10 試行)
  - 差はわずか 0.2 で、フレーミングの影響は限定的
  - 結果: `experiments/phase-4b/results/B2/results.csv`
- [x] Phase 4B-B3: CLAUDE.md 行数と遵守率の関係 (完了日: 2026-04-08)
  - Short（35行）平均 9.43/10, Medium（95行）平均 9.29/10, Long（246行）平均 9.86/10 (各 7 試行)
  - Long（詳細な CLAUDE.md）が最も高い遵守率。情報量が多いほどルール遵守に有利
  - 主な違反は r6（関数サイズ≤30行）に集中。Long 条件では 7 試行中 6 回満点
  - 結果: `experiments/phase-4b/results/B3/results.csv`
- [x] Phase 4B-B5: TDD Bug Fix パターンの効果測定 (完了日: 2026-04-08)
  - TDD 条件: tests_pass 100%, bug_fixed 100%, new_tests 平均 1.6 (各 5 試行 × 2 バグ)
  - Direct 条件: tests_pass 100%, bug_fixed 100%, new_tests 平均 0.8 (各 5 試行 × 2 バグ)
  - バグ修正成功率は両条件とも 100% で差なし。TDD の主効果はテスト追加の確実性（100% vs 50%）
  - TDD はやや多くのターン数を使用（平均 9.1 vs 7.9）
  - 結果: `experiments/phase-4b/results/B5/results.csv`
- [x] Phase 4B-B6: Hooks（lint 自動実行）の品質影響測定 (完了日: 2026-04-08)
  - no-hooks 条件: eslint_errors 平均 1.0（3/7 試行でエラーあり）、テスト全通過
  - hooks 条件: eslint_errors 0（全7試行でエラーゼロ）、テスト全通過
  - Hooks の主効果は ESLint エラーの完全除去。prettier/type_errors は両条件ともゼロ
  - 結果: `experiments/phase-4b/results/B6/results.csv`
- [x] Phase 4B-B4: Plan mode の初回成功率測定 (完了日: 2026-04-09)
  - 4 条件（no-plan/plan × sonnet/opus）各 5 試行 = 20 試行
  - tests_pass が全条件で 0%。タスクの複雑さに対してテスト通過困難
  - Plan mode は改善を示さず（plan+sonnet では subject_id が 40% に低下）
  - Opus は Sonnet より効率的（平均 14.4 turns vs 19.6 turns）だが結果は同等
  - 結果: `experiments/phase-4b/results/B4/results.csv`
