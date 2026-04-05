# Claude Code に指示をするときの最適解の調査

## 目的

Claude Code を使った開発で、意図通りの出力を効率よく得るための指示方法を体系的に調査する。

## 背景

Claude Code には複数の指示チャネル（対話プロンプト、CLAUDE.md、slash commands、Plan mode 等）があり、
それぞれの特性を理解して使い分けることで作業効率が大きく変わる。
最適な指示パターンを見つけ、日常のワークフローに組み込む。

---

## 調査フェーズ

### Phase 1: 指示チャネルの整理と特性調査

Claude Code が受け付ける指示の種類を網羅的に把握する。

- [ ] **1-1. 対話プロンプト（直接指示）の特性**
  - 自然言語での指示の粒度（曖昧 vs 具体的）による出力差
  - 1回の指示に含める情報量の適切な範囲
  - 日本語 vs 英語での指示精度の違い

- [ ] **1-2. CLAUDE.md の活用法**
  - プロジェクトルートの CLAUDE.md に書くべき内容の分類
  - ディレクトリ別 CLAUDE.md による階層的な指示
  - ~/.claude/CLAUDE.md（グローバル設定）との使い分け
  - 記述スタイル（箇条書き vs 文章）の効果比較

- [ ] **1-3. Plan mode の活用法**
  - Plan mode が有効なタスクの種類と規模感
  - Plan mode でのやり取りのコツ（フィードバックの与え方）
  - Plan mode → 実装 の流れの最適パターン

- [ ] **1-4. slash commands・ツール連携**
  - 組み込みコマンド（/commit, /clear 等）の活用シーン
  - カスタム slash commands の作成と運用
  - hooks（設定ベースの自動実行）の活用パターン

- [ ] **1-5. Claude Code に最適なディレクトリ構成**
  - Claude Code がプロジェクト構造をどのように認識・探索するか
  - CLAUDE.md の配置階層（ルート / サブディレクトリ）による効果の違い
  - ファイル・ディレクトリの命名規則が探索精度に与える影響
  - モノレポ vs 単一プロジェクトでの最適構成の違い
  - 設定ファイル・ドキュメント・テストの配置と Claude Code の認識しやすさの関係

- [ ] **1-6. .claude ディレクトリの内容と動作**
  - .claude ディレクトリに含まれるファイル・サブディレクトリの構成
  - 各ファイルの役割（設定、メモリ、プロジェクト情報等）
  - Claude Code が .claude ディレクトリをどのタイミングで読み書きするか
  - settings.json の設定項目と挙動への影響
  - .claude をバージョン管理に含めるべきか（.gitignore との関係）
  - .claude 内に生成されるプランファイルの仕組みと活用法
  - 独自の plans/ ディレクトリと .claude のプランファイルを一元管理できるかの調査

- [ ] **1-7. プロジェクト内のファイルを把握しやすくするための仕組み**
  - Claude Code がファイル一覧やプロジェクト構造を認識する仕組み（Glob, Grep 等）
  - README やディレクトリごとの説明ファイルがコンテキスト理解に与える効果
  - .gitignore や .claudeignore によるノイズ除外の影響
  - ファイル数・階層の深さが探索精度やレスポンスに与える影響
  - プロジェクトマップ（構成一覧ファイル）を用意する手法の有効性

- [ ] **1-8. コンテキスト制御**
  - /clear のタイミングと効果
  - ファイルの明示的な読み込み指示の効果
  - 長いコンテキスト vs 短いコンテキストでの品質差

### Phase 2: タスク別の最適な指示パターンの調査

タスクの種類によって有効な指示方法が異なるか、既存の知見を調査する。

- [ ] **2-1. バグ修正タスクにおける指示パターン**
  - 効果的とされる情報の提示方法（症状・再現手順・期待結果の構造化）
  - エラーログやスタックトレースの与え方に関する知見

- [ ] **2-2. 新機能実装タスクにおける指示パターン**
  - 仕様・制約の伝え方に関する知見
  - Plan mode と直接指示の使い分けに関する情報

- [ ] **2-3. リファクタリングタスクにおける指示パターン**
  - 対象範囲の指定方法（ファイル指定 vs 自動探索）の比較情報
  - リファクタリング手法の具体度と出力品質の関係

- [ ] **2-4. コードレビュー・説明タスクにおける指示パターン**
  - レビュー観点の指定方法に関する知見
  - 出力フォーマット指定の効果に関する情報

### Phase 3: 既存のベストプラクティス・アンチパターンの調査

公式ドキュメントやコミュニティで共有されている知見を収集する。

- [ ] **3-1. 推奨パターンの調査**
  - 公式が推奨する指示の書き方・構造
  - コミュニティで評価されている指示テクニック

- [ ] **3-2. アンチパターンの調査**
  - 避けるべき指示方法とその理由
  - よくある失敗パターンとその原因分析

- [ ] **3-3. CLAUDE.md の実例調査**
  - 公開リポジトリでの CLAUDE.md の記述例の収集・分析
  - プロジェクト種別ごとの記述傾向

---

## 成果物

調査項目ごとにファイルを分割して保存する。

| 成果物 | 配置先 |
|--------|--------|
| Phase 1: 対話プロンプトの特性 | `experiments/claude-code-prompting/01-prompt-characteristics.md` |
| Phase 1: CLAUDE.md の活用法 | `experiments/claude-code-prompting/02-claude-md.md` |
| Phase 1: Plan mode の活用法 | `experiments/claude-code-prompting/03-plan-mode.md` |
| Phase 1: slash commands・ツール連携 | `experiments/claude-code-prompting/04-slash-commands.md` |
| Phase 1: 最適なディレクトリ構成 | `experiments/claude-code-prompting/05-directory-structure.md` |
| Phase 1: .claude ディレクトリの内容と動作 | `experiments/claude-code-prompting/06-dot-claude.md` |
| Phase 1: ファイル把握の仕組み | `experiments/claude-code-prompting/07-file-discovery.md` |
| Phase 1: コンテキスト制御 | `experiments/claude-code-prompting/08-context-control.md` |
| Phase 2: バグ修正の指示パターン | `experiments/claude-code-prompting/09-task-bug-fix.md` |
| Phase 2: 新機能実装の指示パターン | `experiments/claude-code-prompting/10-task-new-feature.md` |
| Phase 2: リファクタリングの指示パターン | `experiments/claude-code-prompting/11-task-refactoring.md` |
| Phase 2: コードレビューの指示パターン | `experiments/claude-code-prompting/12-task-code-review.md` |
| Phase 3: 推奨パターン | `experiments/claude-code-prompting/13-best-practices.md` |
| Phase 3: アンチパターン | `experiments/claude-code-prompting/14-anti-patterns.md` |
| Phase 3: CLAUDE.md の実例 | `experiments/claude-code-prompting/15-claude-md-examples.md` |

## 進め方

1. Phase 1〜3 とも公式ドキュメント・Web 情報・公開リポジトリの調査が中心
2. 調査項目ごとに個別ファイルへ記録する
3. 進捗は TODO.md で管理する
