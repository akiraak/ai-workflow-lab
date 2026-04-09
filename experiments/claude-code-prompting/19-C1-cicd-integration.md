# C1: CI/CD 統合パターン

Phase 4C 追加調査 — Claude Code を CI/CD パイプラインに統合する方法の調査結果。

**調査日**: 2026-04-09
**参照キャッシュ**: `research/cache/2026-04-09T100000/001〜011`

---

## 1. claude-code-action（GitHub Actions 公式アクション）

`anthropics/claude-code-action@v1` は Anthropic 公式の GitHub Action。2025年9月に Claude Code 2.0 の一部として GA リリース。

### 主要な特徴

| 特徴 | 説明 |
|------|------|
| インテリジェントモード検出 | ワークフローコンテキストに基づき、インタラクティブ（`@claude` メンション応答）と自動化（`prompt` パラメータで即時実行）を自動切り替え |
| 認証 | Anthropic API 直接、AWS Bedrock（OIDC）、Google Vertex AI（WIF）、Microsoft Foundry の4種 |
| Structured Outputs | `--json-schema` で検証済み JSON を出力。後続ステップでの条件分岐に活用可能 |
| プラグイン対応 | `plugins` / `plugin_marketplaces` でプラグイン自動インストール |

### セットアップ

最も簡単な方法は Claude Code ターミナルで `/install-github-app` を実行すること。手動セットアップも可能:

1. Claude GitHub App をインストール
2. `ANTHROPIC_API_KEY` を GitHub Secrets に追加
3. ワークフローファイルを配置

### 主要パラメータ

| パラメータ | 説明 |
|-----------|------|
| `prompt` | Claude への指示（省略時は `@claude` メンション応答） |
| `claude_args` | CLI 引数のパススルー（`--max-turns`, `--model`, `--allowedTools` 等） |
| `anthropic_api_key` | API キー |
| `trigger_phrase` | トリガーフレーズ（デフォルト: `@claude`） |
| `settings` | Claude Code 設定 JSON またはファイルパス |
| `track_progress` | 進捗トラッキングコメントの有効化 |
| `use_bedrock` / `use_vertex` | クラウドプロバイダ切替 |

### v1.0 での変更

- `mode` パラメータ廃止（自動検出に移行）
- `direct_prompt` → `prompt` に統一
- CLI オプションは全て `claude_args` に集約

---

## 2. GitHub Actions 連携パターン

公式 Solutions Guide に8つの実用パターンが提供されている。

### 高優先度パターン

| パターン | トリガー | 内容 |
|---------|---------|------|
| **自動 PR コードレビュー** | `pull_request: [opened, synchronize]` | 全 PR を自動レビュー。`track_progress: true` で進捗表示 |
| **パス限定レビュー** | `paths:` フィルタ | `src/auth/**` 等の重要ファイル変更時のみセキュリティレビュー |
| **外部コントリビューターレビュー** | `author_association == 'FIRST_TIME_CONTRIBUTOR'` | 初回コントリビュータに厳格レビュー適用 |
| **カスタムレビューチェックリスト** | `pull_request` | チーム固有のチェックリストを埋め込み体系的にレビュー |

### 自動化パターン

| パターン | トリガー | 内容 |
|---------|---------|------|
| **定期メンテナンス** | `schedule: cron` | 週次の依存関係チェック、セキュリティスキャン、TODO 確認 |
| **Issue 自動トリアージ** | `issues: [opened]` | バグ/機能要望/質問に分類し、優先度判定・ラベル付与 |
| **API ドキュメント同期** | API コード変更 | ドキュメントを自動更新し PR にコミット |
| **セキュリティ重点レビュー** | `pull_request` | OWASP Top 10 に基づいたセキュリティ分析 |

### コミュニティ追加パターン（systemprompt.io）

- **テスト自動生成**: PR 作成時にテストファイルを自動生成（パスフィルタで無限ループ防止）
- **リリースノート生成**: `release` イベントで `fetch-depth: 0` によるフル履歴から要約
- **マルチステップワークフロー**: 複数の Claude 呼び出しをチェーン

---

## 3. ヘッドレスモード（`-p` フラグ）

`-p`（`--print`）フラグで非インタラクティブ実行。CI/CD 統合の基盤。

### 主要機能

| 機能 | フラグ | 説明 |
|------|--------|------|
| bare モード | `--bare` | hooks, skills, plugins, MCP, auto memory, CLAUDE.md の自動読み込みをスキップ。環境差異なく同じ結果を得るための推奨モード |
| 出力形式 | `--output-format` | `text`（デフォルト）/ `json`（メタデータ付き）/ `stream-json`（リアルタイム） |
| JSON スキーマ | `--json-schema` | 検証済み構造化出力を `structured_output` フィールドに返す |
| セッション継続 | `--continue` / `--resume` | 直前の会話を継続 / 特定セッションを再開 |
| ツール承認 | `--allowedTools` | プレフィックスマッチング（例: `Bash(git diff *)`） |
| 権限モード | `--permission-mode` | `acceptEdits` でファイル書き込みを自動承認 |
| システムプロンプト | `--append-system-prompt` / `--system-prompt` | 追加 / 完全置換 |
| パイプ入力 | stdin | `gh pr diff | claude -p ...` のように利用 |

### CI/CD でのベストプラクティス

1. `--bare` を常に使用して環境依存を排除
2. `--allowedTools` でツールを最小限に制限
3. `--max-turns` でイテレーション上限を設定
4. `--output-format json` で構造化出力を取得
5. 認証は `ANTHROPIC_API_KEY` 環境変数で管理

---

## 4. その他の CI/CD プラットフォーム

### GitLab CI/CD（公式ベータ）

Anthropic 公式ドキュメントに GitLab CI/CD 統合が記載されている（GitLab 管理のベータ機能）。

**セットアップ手順:**
1. `ANTHROPIC_API_KEY` を GitLab CI/CD のマスク済み変数として追加
2. `.gitlab-ci.yml` に Claude ジョブを追加
3. `node:24-alpine3.21` イメージ上で CLI をインストール

**GitHub Actions との違い:**
- 専用アクションではなく CLI（`claude -p`）を直接呼び出す
- `AI_FLOW_INPUT`, `AI_FLOW_CONTEXT`, `AI_FLOW_EVENT` 変数でコンテキスト受け渡し
- MR 経由の変更管理（PR ではなく MR）
- `mcp__gitlab` ツールで GitLab API 操作
- Webhook による `@claude` メンション駆動のパイプライン起動も可能

### その他

- Jenkins, CircleCI 等の公式ドキュメントは未提供
- ヘッドレスモード（`claude -p`）を使えば、原理的にはどのプラットフォームでも統合可能

---

## 5. セキュリティ・権限管理

### GitHub Actions 固有のセキュリティ

**アクセス制御:**
- デフォルトではリポジトリの write 権限を持つユーザーのみがトリガー可能
- Bot ユーザーは `allowed_bots` で明示的に許可が必要
- `allowed_non_write_users` は重大なセキュリティリスクあり — 極めて限定的なワークフロー（Issue ラベリング等）のみに使用

**プロンプトインジェクション対策:**
- HTML コメント、不可視文字、隠し属性の自動除去
- `include_comments_by_actor` / `exclude_comments_by_actor` で信頼ユーザーのみ処理

**コミット署名:**
- `use_commit_signing: true`: GitHub API 経由（簡単だが rebase 不可）
- `ssh_signing_key`: SSH 鍵による署名（フル git 操作可能）

### CI 環境での推奨事項

| カテゴリ | 推奨事項 |
|---------|---------|
| シークレット | GitHub Secrets / GitLab マスク済み変数で管理。OIDC / WIF による短命トークンを推奨 |
| ツール制限 | `--allowedTools` で最小限に制限（レビューパイプラインでは `Bash` を除外） |
| ランナウェイ防止 | `--max-turns` と `timeout-minutes` を設定 |
| 実行権限 | Claude を root で実行しない |
| 組織標準 | `managed-settings.json` で deny ルール等を強制 |
| 監査 | 定期的な設定監査（月次） |

### 権限管理の3層モデル

| 層 | 設定項目 | 説明 |
|----|---------|------|
| `permissions.allow` | 安全なコマンドのみ | 例: `Bash(echo Hello)` |
| `permissions.ask` | リスクのある操作 | 例: `Bash(git push:*)` |
| `permissions.deny` | 絶対に許可しない操作 | 例: `WebFetch`, `Read(./secrets/**)` |

---

## 主要な知見まとめ

| 知見 | 確度 | 出典 |
|------|------|------|
| claude-code-action v1 は GA リリース済みで本番利用可能 | 公式 | Anthropic ドキュメント |
| `--bare` モードが CI/CD での推奨モード | 公式 | ヘッドレスモードドキュメント |
| 8つの実用パターン（PR レビュー〜セキュリティ分析）が公式提供 | 公式 | solutions.md |
| GitLab CI/CD は公式ベータとして対応 | 公式 | GitLab CI/CD ドキュメント |
| Structured Outputs で後続ステップとの連携が可能 | 公式 | claude-code-action ドキュメント |
| プロンプトインジェクション対策が組み込み済み | 公式 | security.md |
| Jenkins/CircleCI 等は CLI 経由で非公式に統合可能 | 推測 | ヘッドレスモード仕様から |
