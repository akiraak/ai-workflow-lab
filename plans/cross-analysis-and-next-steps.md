# Phase 1〜3 調査結果の横断分析と追加調査の方向性決定

## 目的

Phase 1（指示チャネルの特性）・Phase 2（タスク別指示パターン）・Phase 3（ベストプラクティス・アンチパターン）の
15 本の調査成果物を横断的に読み解き、以下を明らかにする。

1. Phase 間で共通する重要原則の抽出
2. 矛盾・重複・ギャップの特定
3. 調査だけでは検証できていない仮説の洗い出し
4. 次にやるべき追加調査・実験の方向性の決定

## 背景

Phase 1〜3 はそれぞれ個別テーマの Web 調査として完了しているが、
フェーズ間を横断した分析はまだ行われていない。
調査結果を実際のワークフローに活かすには、知見を統合し、
次のアクション（実験・検証・ガイドライン作成など）を定める必要がある。

---

## 作業ステップ

### Step 1: 全成果物の通読とキーポイント抽出

15 本の調査ファイルを読み、各ファイルから以下を抽出する。

- 主要な知見（3〜5 個）
- 情報の確度（公式ドキュメント由来 / コミュニティ由来 / 推測）
- 未検証の仮説や「要確認」とされている事項

対象ファイル:
- `experiments/claude-code-prompting/01-prompt-characteristics.md`
- `experiments/claude-code-prompting/02-claude-md.md`
- `experiments/claude-code-prompting/03-plan-mode.md`
- `experiments/claude-code-prompting/04-slash-commands.md`
- `experiments/claude-code-prompting/05-directory-structure.md`
- `experiments/claude-code-prompting/06-dot-claude.md`
- `experiments/claude-code-prompting/07-file-discovery.md`
- `experiments/claude-code-prompting/08-context-control.md`
- `experiments/claude-code-prompting/09-task-bug-fix.md`
- `experiments/claude-code-prompting/10-task-new-feature.md`
- `experiments/claude-code-prompting/11-task-refactoring.md`
- `experiments/claude-code-prompting/12-task-code-review.md`
- `experiments/claude-code-prompting/13-best-practices.md`
- `experiments/claude-code-prompting/14-anti-patterns.md`
- `experiments/claude-code-prompting/15-claude-md-examples.md`

### Step 2: 横断テーマの分析

以下の観点で Phase をまたいだ分析を行う。

- [ ] **共通原則の統合**: 複数の Phase で繰り返し登場する原則を特定し、重要度順にまとめる
- [ ] **矛盾・ギャップの特定**: Phase 間で異なる推奨をしている箇所や、カバーされていない領域を洗い出す
- [ ] **「コンテキスト管理」の横断整理**: Phase 1-8 のコンテキスト制御を軸に、各タスクパターンでのコンテキスト戦略を統合する
- [ ] **CLAUDE.md 関連知見の統合**: Phase 1-2 の活用法 + Phase 3-3 の実例 + 各 Phase で言及される CLAUDE.md の役割をまとめる
- [ ] **「検証手段の提供」の横断整理**: Phase 3 で最重要とされた「テスト・スクリーンショット等の検証手段を与える」が各タスク種別でどう適用されるかを整理する

### Step 3: 未検証仮説と追加調査候補のリストアップ

Step 1〜2 を踏まえ、以下を分類・整理する。

- **実験で検証すべき仮説**: 実際にコードを書いて試さないと分からないこと
- **追加の Web 調査が必要な領域**: 情報が不足している / 最新情報の確認が必要なもの
- **ガイドライン化できる知見**: すでに十分な情報があり、まとめるだけで実用できるもの

### Step 4: 追加調査の方向性を決定し、成果物として記録する

Step 3 の結果から優先度を付け、次のアクション（Phase 4 以降の計画）を策定する。

---

## 成果物

| 成果物 | 配置先 |
|--------|--------|
| 横断分析レポート | `experiments/claude-code-prompting/16-cross-analysis.md` |

## 進め方

1. Step 1〜2 は並列で進められる部分もあるが、Step 2 は Step 1 の理解が前提
2. Step 3〜4 は分析結果に基づく判断なので逐次実施
3. 最終的な方向性の決定はユーザーと相談して確定する
