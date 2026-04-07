# 推奨パターン（ベストプラクティス）

## 概要

Claude Code に指示をする際の推奨パターンを、公式ドキュメントとコミュニティの知見から整理する。Phase 1・2 で調査した個別の指示チャネルやタスク別パターンを横断し、共通して有効とされるプラクティスをまとめる。

---

## 公式推奨パターン

Anthropic 公式ドキュメント（code.claude.com/docs/en/best-practices）が示す推奨事項を整理する。

### 1. 検証手段を与える（最重要）

公式が「single highest-leverage thing you can do」と明言するパターン。テスト・スクリーンショット・期待出力など、Claude が自分自身の出力を検証できる手段を提供する。

| 戦略 | 悪い例 | 良い例 |
|------|--------|--------|
| 検証基準の提示 | "メールアドレスを検証する関数を作って" | "validateEmail 関数を書いて。テストケース: user@example.com → true, invalid → false, user@.com → false。実装後にテスト実行して" |
| UI 変更の視覚検証 | "ダッシュボードをよくして" | "[スクリーンショット貼付] このデザインを実装して。結果のスクリーンショットを撮って元と比較し、差異を修正して" |
| 根本原因への対処 | "ビルドが落ちてる" | "このエラーでビルドが失敗する: [エラー貼付]。修正してビルド成功を確認して。エラーを抑制せず根本原因を直して" |

### 2. Explore → Plan → Code → Commit の4フェーズワークフロー

公式が推奨する基本ワークフロー。

1. **Explore**: Plan Mode でコードベースを読み、質問に答える（変更はしない）
2. **Plan**: 詳細な実装計画を作成させる（Ctrl+G でエディタで直接編集可能）
3. **Implement**: Normal Mode に切り替え、計画に沿ってコードを書かせる
4. **Commit**: コミットメッセージと PR を作成させる

**使い分けの基準**: スコープが明確で小さい修正（タイポ修正、ログ追加など）は直接実行。アプローチが不明確、複数ファイルにまたがる変更、不慣れなコードの修正時に計画を立てる。

### 3. 具体的なコンテキストの提供

指示が具体的であるほど修正回数が減る。

- **スコープの限定**: ファイル名・シナリオ・テスト方針を指定
- **ソースの指示**: 情報源（git history、特定ファイル）を直接指定
- **既存パターンの参照**: コードベース内の既存パターンを例として指示
- **症状の詳細記述**: 症状・原因の推測箇所・「修正済み」の定義を明示

### 4. リッチコンテンツの活用

- `@` でファイルを直接参照
- 画像をコピー&ペーストまたはドラッグ&ドロップ
- ドキュメントや API リファレンスの URL を提供
- `cat error.log | claude` でデータをパイプ
- Claude 自身に Bash コマンド・MCP ツール・ファイル読み込みでコンテキストを取得させる

### 5. CLAUDE.md の効果的な設計

- `/init` でスターターファイルを生成し、徐々に洗練する
- 簡潔に保つ: 各行について「これを削除したら Claude がミスするか？」と自問
- 肥大化した CLAUDE.md は重要なルールが埋もれ、逆効果になる
- `IMPORTANT` や `YOU MUST` で強調して遵守率を上げる
- git にコミットしてチーム共有する
- CLAUDE.md は Skills（オンデマンド読み込み）と使い分ける

**含めるべきもの**: Claude が推測できないコマンド、デフォルトと異なるコードスタイル、テスト手順、リポジトリ規約、プロジェクト固有の設計判断、環境の癖、非自明な挙動

**含めないもの**: コードを読めばわかること、標準的な言語規約、詳細な API ドキュメント（リンクで代替）、頻繁に変わる情報、長い説明やチュートリアル、自明な慣行

### 6. コンテキスト管理

公式ベストプラクティスの根底にある原則: **コンテキストウィンドウが最も重要なリソース**。

- タスク間で `/clear` を頻繁に使う
- `/compact <instructions>` でコンテキストを制御付きで圧縮
- `/btw` でコンテキストに残らない一時的な質問
- サブエージェントで調査を別コンテキストに分離
- 2回修正に失敗したら `/clear` してより良い初期プロンプトで再開

### 7. セッション管理とコース修正

- `Esc` で即座に停止、`Esc+Esc` でリワインド
- "Undo that" で変更を元に戻す
- `/rewind` でチェックポイントに戻る
- `claude --continue` / `--resume` でセッション再開
- セッションに名前を付ける（`/rename`）

### 8. CLI ツールの活用

外部サービスとの連携には CLI ツール（`gh`, `aws`, `gcloud`, `sentry-cli` 等）が最もコンテキスト効率が良い。Claude は未知の CLI ツールも `--help` で学習できる。

### 9. 自動化とスケーリング

- `claude -p "prompt"` で非対話モード（CI/CD 連携）
- 複数セッションの並列実行（Writer/Reviewer パターン）
- ファイルごとのファンアウト処理（`--allowedTools` でスコープ制限）
- Auto Mode で安全な自律実行

---

## コミュニティで評価されているテクニック

公式以外のブログ記事・技術記事から収集した、実践者に評価されているテクニック。

### 1. 5項目チェックリスト（Qiita: nogataka）

指示を出す前に5項目を確認する:
- **What**: 対象ファイル・関数・コンポーネント
- **Where**: 変更すべき具体的な場所
- **Why**: 変更の目的と背景
- **How far**: 期待する完了基準
- **Constraints**: ライブラリ・コーディング規約・互換性

### 2. 「1タスク1セッション」ルール（Qiita: nogataka）

長いセッションは出力品質を劣化させる。コンテキスト劣化の3つのサイン:
1. 以前述べた指示を忘れる
2. コードの一貫性が崩れる（命名規則のドリフト）
3. 関係ないファイルが編集される

### 3. 「5分ルール」で計画判断（Qiita: nogataka）

手作業で5分以上かかるタスクは計画から始める。それ以下なら直接実行。

### 4. コンテキストファーストプロンプティング（SmartScope）

プロジェクト概要・現在の課題・技術的制約をリクエストの**前に**提示すると、実装精度が向上する。

```
Project Overview: Node.js Express API, 月間10万リクエスト
Current Challenge: ユーザー体験に影響する500エラーが頻発
Technical Constraints: TypeScript必須、既存DBスキーマ維持
上記コンテキストに基づき、エラーハンドリングを改善してください。
```

### 5. 具体例の先行提示（ENECHANGE テックブログ）

複数箇所に同様の変更が必要な場合、まず1つ手動で例を作り、「path/to/example の diff を修正例として参照して」と指示する。

### 6. 必要情報の明示的提供（ENECHANGE テックブログ）

Claude に自力で探させるのではなく、事前にファイルパス・URL・MCP 経由のドキュメントを明示的に渡す。

### 7. /wizard スキル — 8フェーズ方法論（dev.to: vlad-ko）

シニアエンジニアの習慣をスキルとしてエンコードする手法:
1. コードを触る前に計画
2. 仮定する前に探索（grep で確認）
3. テストを先に書く（TDD）
4. 最小限の実装
5. リグレッションがないことを確認
6. 新鮮なうちにドキュメント化
7. 敵対的レビュー（自分のコードを攻撃者視点で検証）
8. 品質ゲートサイクル

核心的洞察: 「知性は有用だが、プロセスこそが知性を安全にする」

### 8. 4ブロックパターン（コミュニティ共通）

プロンプトを以下の4ブロックで構造化する:
1. **INSTRUCTIONS**: Claude への指示
2. **CONTEXT**: プロジェクト・タスクの背景
3. **TASK**: 具体的な作業内容
4. **OUTPUT FORMAT**: 出力形式の指定

### 9. Writer/Reviewer パターン（公式 + コミュニティ）

2つのセッションを使い、1つで実装、もう1つでレビューする。書いたコードに対するバイアスを排除し、エッジケースや競合状態の検出精度を上げる。

### 10. Git ワークフローの安全策（eesel AI）

- 機能/バグ修正ごとに新しいブランチを作成
- 並列開発には Git worktree を活用し、各 Claude インスタンスを隔離

---

## まとめ

### 最重要パターン（公式が特に強調）

1. **検証手段を与える** — テスト・スクリーンショット・期待出力で Claude が自己検証できるようにする
2. **Explore → Plan → Code → Commit** — 4フェーズワークフローで段階的に進める
3. **コンテキストを積極的に管理する** — `/clear`、サブエージェント、`/compact` を活用

### 指示の質を上げるパターン

4. **具体的に指示する** — ファイル名・制約・パターン例を明示
5. **コンテキストファーストで書く** — 背景→制約→タスクの順
6. **リッチコンテンツを活用する** — `@` 参照、画像貼付、URL 提供

### 環境設定パターン

7. **CLAUDE.md を簡潔に保つ** — Claude が推測できないことだけ書く
8. **CLI ツールを活用する** — 外部サービスとの効率的な連携
9. **Hooks・Skills で拡張する** — 確実に実行すべきことは Hooks、知識拡張は Skills

### ワークフロー最適化パターン

10. **1タスク1セッション** — コンテキスト劣化を防ぐ
11. **2回失敗したらリセット** — 汚染されたコンテキストで粘らない
12. **並列セッション・サブエージェントで分離** — コンテキストの独立性を保つ

---

## 参考資料

- [Best Practices for Claude Code（公式）](https://code.claude.com/docs/en/best-practices)
- [Claude Code ベストプラクティス（公式日本語）](https://code.claude.com/docs/ja/best-practices)
- [Claude Code Prompting Guide 2025 — SmartScope](https://smartscope.blog/en/generative-ai/claude/claude-code-prompting-official-guidelines-2025/)
- [50 Claude Code Tips and Best Practices — builder.io](https://www.builder.io/blog/claude-code-tips-best-practices)
- [Claude Codeベストプラクティス 7つの鉄則 — Qiita (nogataka)](https://qiita.com/nogataka/items/392934f79e943e8b9228)
- [7 Claude Code Best Practices from Real Projects — eesel AI](https://www.eesel.ai/blog/claude-code-best-practices)
- [Claude Codeで品質の高いコードを書くために — ENECHANGE](https://tech.enechange.co.jp/entry/2025/07/14/144750)
- [I Made Claude Code Think Before It Codes — dev.to (vlad-ko)](https://dev.to/_vjk/i-made-claude-code-think-before-it-codes-heres-the-prompt-bf)
- [claude-code-best-practice — GitHub (shanraisshan)](https://github.com/shanraisshan/claude-code-best-practice)
