# 1-6. .claude ディレクトリの内容と動作

## 調査目的

.claude ディレクトリの構成、各ファイルの役割、Claude Code が読み書きするタイミング、settings.json の設定項目、バージョン管理との関係を調査し、効果的な運用方法を明らかにする。

---

## 1. .claude ディレクトリの構成

### プロジェクトレベル（`.claude/`）

```
your-project/
├── CLAUDE.md                    # [committed] プロジェクト指示
├── CLAUDE.local.md              # [gitignored] 個人用指示
├── .mcp.json                    # [committed] MCP サーバー設定
├── .worktreeinclude             # [committed] worktree にコピーする gitignore ファイル
└── .claude/
    ├── settings.json            # [committed] チーム共有設定
    ├── settings.local.json      # [gitignored] 個人用設定オーバーライド
    ├── rules/                   # [committed] トピック別ルール
    │   ├── testing.md
    │   └── api-design.md
    ├── skills/                  # [committed] 再利用可能プロンプト
    │   └── security-review/
    │       ├── SKILL.md
    │       └── checklist.md
    ├── commands/                # [committed] 単一ファイルコマンド
    │   └── fix-issue.md
    ├── output-styles/           # [committed] カスタム出力スタイル
    ├── agents/                  # [committed] サブエージェント定義
    │   └── code-reviewer.md
    ├── agent-memory/            # [committed] サブエージェント用永続メモリ
    │   └── <agent-name>/
    │       └── MEMORY.md
    └── agent-memory-local/      # [gitignored] ローカル用サブエージェントメモリ
```

### グローバルレベル（`~/.claude/`）

```
~/
├── .claude.json                 # アプリ状態、UIプレファレンス、MCP サーバー設定
└── .claude/
    ├── CLAUDE.md                # 全プロジェクト共通の個人指示
    ├── settings.json            # 全プロジェクト共通の設定
    ├── keybindings.json         # キーボードショートカット
    ├── rules/                   # 全プロジェクト共通ルール
    ├── skills/                  # 全プロジェクト共通スキル
    ├── commands/                # 全プロジェクト共通コマンド
    ├── output-styles/           # 個人用出力スタイル
    ├── agents/                  # 全プロジェクト共通サブエージェント
    ├── agent-memory/            # memory: user のサブエージェントメモリ
    ├── projects/                # [自動生成] プロジェクト別オートメモリ
    │   └── <project>/memory/
    │       ├── MEMORY.md
    │       └── debugging.md
    ├── plans/                   # [自動生成] プランモード文書
    ├── file-history/            # [自動生成] ファイル変更履歴
    ├── debug/                   # [自動生成] デバッグログ
    ├── session-env/             # [自動生成] セッション環境
    ├── shell-snapshots/         # [自動生成] シェルスナップショット
    └── stats-cache.json         # [自動生成] 統計キャッシュ
```

---

## 2. 各ファイルの役割

| ファイル | 役割 | スコープ |
|---------|------|---------|
| `CLAUDE.md` | セッション開始時に読み込まれるプロジェクト指示 | プロジェクト |
| `CLAUDE.local.md` | 個人用のプロジェクト指示（gitignore 対象） | ローカル |
| `settings.json` | permissions、hooks、env、model 等の設定 | プロジェクト / ユーザー |
| `settings.local.json` | チーム設定の個人オーバーライド | ローカル |
| `rules/*.md` | トピック別指示ファイル（`paths:` で条件付き読み込み可） | プロジェクト |
| `skills/*/SKILL.md` | 再利用可能プロンプト + 補助ファイル | プロジェクト / ユーザー |
| `commands/*.md` | 単一ファイルの slash コマンド（skills の前身） | プロジェクト / ユーザー |
| `agents/*.md` | サブエージェント定義 | プロジェクト / ユーザー |
| `agent-memory/` | サブエージェントの永続メモリ | プロジェクト |
| `output-styles/*.md` | 出力スタイル定義 | プロジェクト / ユーザー |
| `.mcp.json` | MCP サーバー設定 | プロジェクト |
| `~/.claude.json` | アプリ状態、テーマ、OAuth、パーソナル MCP | ユーザー |
| `~/.claude/projects/` | オートメモリ（セッション跨ぎの自動知識蓄積） | ユーザー（プロジェクト別） |
| `keybindings.json` | キーボードショートカットのカスタマイズ | ユーザー |

> "Commands and skills are now the same mechanism. For new workflows, use skills/ instead: same /name invocation, plus you can bundle supporting files."
> — [Explore the .claude directory](https://code.claude.com/docs/en/claude-directory)

---

## 3. 読み書きのタイミング

### セッション開始時に読み込まれるもの

- `CLAUDE.md`（プロジェクト + グローバル + 親ディレクトリ + CLAUDE.local.md）
- `settings.json`（全スコープがマージ）
- `rules/*.md` のうち `paths:` フロントマターが**ない**もの
- `~/.claude/projects/<project>/memory/MEMORY.md`（先頭200行、25KB上限）
- MCP サーバー設定（`.mcp.json`, `~/.claude.json`）
- `keybindings.json`
- `output-styles/` から選択中のスタイル

### オンデマンドで読み込まれるもの

| ファイル | トリガー |
|---------|---------|
| `rules/*.md`（`paths:` あり） | マッチするファイルがコンテキストに入った時 |
| 子ディレクトリの `CLAUDE.md` | そのディレクトリのファイルを読んだ時 |
| `skills/` | `/skill-name` 呼び出し時、または Claude がタスクにマッチした時 |
| `commands/` | `/command-name` 呼び出し時 |
| `agents/` | 委譲時または `@` メンション時 |
| オートメモリのトピックファイル | 関連タスク発生時 |

### Claude Code が書き込むもの

| ファイル | タイミング |
|---------|-----------|
| `settings.local.json` | セッション内で許可した権限ルール |
| `~/.claude/projects/<project>/memory/` | 作業中に自動更新（オートメモリ） |
| `agent-memory/<agent>/MEMORY.md` | サブエージェント動作中 |
| `~/.claude/file-history/` | ファイル変更時（チェックポイント用） |
| `~/.claude/debug/` | デバッグログ |
| `~/.claude/plans/` | プランモード使用時 |

---

## 4. settings.json の設定項目

### 設定スコープの優先順位（上が最優先）

| 優先度 | スコープ | 配置場所 |
|--------|---------|---------|
| 1 | **Managed** | 組織ポリシー（他で上書き不可） |
| 2 | **Command line** | セッション一時オーバーライド |
| 3 | **Local** | `.claude/settings.local.json` |
| 4 | **Project** | `.claude/settings.json` |
| 5 | **User** | `~/.claude/settings.json` |

**重要**: 配列設定（`permissions.allow` 等）は全スコープで**結合**される。スカラー値（`model` 等）はより具体的なスコープの値が採用される。

> "Unlike CLAUDE.md, which Claude reads as guidance, these [settings.json] are enforced whether Claude follows them or not."
> — [Claude Code settings](https://code.claude.com/docs/en/settings)

### permissions（権限制御）

```json
{
  "permissions": {
    "allow": ["Bash(npm test *)", "Bash(npm run *)"],
    "deny": ["Bash(rm -rf *)", "Read(./.env)", "Read(./secrets/**)"],
    "ask": ["Bash(git push *)"]
  }
}
```

- `deny` → `ask` → `allow` の順で評価（最初にマッチしたルールが適用）
- パターン構文: `Tool(specifier)` 形式。ワイルドカード `*` 対応

### hooks（ライフサイクルフック）

```json
{
  "hooks": {
    "PreToolUse": [{
      "matcher": "Bash",
      "hooks": [{
        "type": "command",
        "command": "path/to/validator.sh"
      }]
    }],
    "PostToolUse": [{
      "matcher": "Edit|Write",
      "hooks": [{
        "type": "command",
        "command": "jq -r '.tool_input.file_path' | xargs npx prettier --write"
      }]
    }]
  }
}
```

| イベント | タイミング | 活用例 |
|---------|-----------|--------|
| `SessionStart` | セッション開始時 | 環境チェック |
| `UserPromptSubmit` | プロンプト送信時 | 入力検証 |
| `PreToolUse` | ツール実行前 | バリデーション（exit code 2 でブロック） |
| `PostToolUse` | ツール実行後 | フォーマッター自動実行 |
| `Stop` | 応答完了時 | 追加処理（exit code 2 で停止阻止） |
| `Notification` | 通知送信時 | カスタム通知 |

Hook タイプ: `command`（シェル）、`http`（HTTPエンドポイント）、`prompt`（LLMプロンプト）、`agent`（エージェント）

### その他の主要設定項目

| 設定 | 説明 | 例 |
|------|------|-----|
| `model` | デフォルトモデル | `"claude-sonnet-4-6"` |
| `env` | 環境変数 | `{"NODE_ENV": "test"}` |
| `statusLine` | ステータスライン表示 | — |
| `outputStyle` | 出力スタイル選択 | — |
| `language` | 応答言語 | `"japanese"` |
| `sandbox` | Bash サンドボックス | filesystem, network 制限 |
| `autoUpdatesChannel` | 更新チャンネル | `"stable"` / `"latest"` |
| `cleanupPeriodDays` | セッション自動削除期間 | デフォルト30日 |
| `attribution` | Git コミットのアトリビューション | — |

---

## 5. バージョン管理との関係

### Git にコミットすべきもの（チーム共有）

| ファイル | 理由 |
|---------|------|
| `.claude/settings.json` | チームの権限・フック設定 |
| `.claude/rules/*.md` | プロジェクトルール |
| `.claude/skills/` | プロジェクトスキル |
| `.claude/commands/` | プロジェクトコマンド |
| `.claude/agents/` | サブエージェント定義 |
| `.claude/agent-memory/` | プロジェクトスコープのメモリ |
| `.claude/output-styles/` | チーム共有スタイル |
| `CLAUDE.md` | プロジェクト指示 |
| `.mcp.json` | MCP サーバー設定 |

### Git にコミットしないもの（自動 gitignore）

| ファイル | 理由 |
|---------|------|
| `.claude/settings.local.json` | 個人設定（Claude Code が自動 gitignore） |
| `CLAUDE.local.md` | 個人用指示 |
| `.claude/agent-memory-local/` | ローカルサブエージェントメモリ |

> "Claude Code will configure git to ignore .claude/settings.local.json when it is created."
> — [Explore the .claude directory](https://code.claude.com/docs/en/claude-directory)

> "If you use git, commit most files here so your team shares them; a few, like settings.local.json, are automatically gitignored."

### `~/.claude/` のバージョン管理

グローバルの `~/.claude/` は通常バージョン管理しないが、`settings.json`、`CLAUDE.md`、`commands/`、`skills/` 等の個人設定ファイルを dotfiles リポジトリで管理する手法がコミュニティで提案されている。

---

## 6. 自動生成ファイルの仕組みと活用法

### オートメモリ（`~/.claude/projects/<project>/memory/`）

> "Auto memory lets Claude accumulate knowledge across sessions without you writing anything. Claude saves notes as it works: build commands, debugging insights, architecture notes."
> — [Memory](https://code.claude.com/docs/en/memory)

- `MEMORY.md` がインデックスファイル、セッション開始時に先頭200行（25KB上限）が読み込まれる
- 内容が増えると `debugging.md`、`architecture.md` 等のトピックファイルに自動分割
- トピックファイルは関連タスク発生時にオンデマンドで読み込まれる
- `/memory` コマンドで手動編集可能
- `autoMemoryEnabled` 設定でオン/オフ切り替え可能

### サブエージェントメモリ

| メモリスコープ | 配置先 | Git |
|-------------|--------|-----|
| `memory: project` | `.claude/agent-memory/` | committed |
| `memory: local` | `.claude/agent-memory-local/` | gitignored |
| `memory: user` | `~/.claude/agent-memory/` | — |

### file-history（ファイル変更履歴）

- Claude が編集したファイルの変更履歴を自動保存
- チェックポイント・巻き戻し機能で利用される
- **肥大化リスクが高い**（300GB の事例報告あり）

### rules/ の条件付き読み込み

```yaml
---
paths:
  - "**/*.test.ts"
  - "**/*.test.tsx"
---

# Testing Rules
- Use descriptive test names
- Mock external dependencies, not internal modules
```

`paths:` フロントマターで条件を指定すると、マッチするファイルがコンテキストに入った場合のみ読み込まれる。

### skills/ の高度な機能

| 機能 | 説明 |
|------|------|
| `disable-model-invocation: true` | ユーザー手動呼び出し専用（例: `/deploy`） |
| `user-invocable: false` | Claude 自動呼び出し専用 |
| `$ARGUMENTS` | パラメータ受け取り |
| `$0`, `$1` | 位置引数アクセス |
| `` !`command` `` | シェルコマンドを inline 実行して出力を注入 |
| `${CLAUDE_SKILL_DIR}` | スキルディレクトリのパスを参照 |

---

## 7. 肥大化対策

### サイズ監視

```bash
# サイズ確認用コマンド
du -sh ~/.claude/ && du -sh ~/.claude/* | sort -h
```

### 対策

| 対策 | 方法 |
|------|------|
| セッション自動削除 | `cleanupPeriodDays` 設定（デフォルト30日） |
| file-history の監視 | 定期的にサイズを確認し、古いものを手動削除 |
| 削除してはいけないもの | `settings.json`、`commands/`、`skills/`、`rules/` |

---

## 総合的なベストプラクティス

### .claude ディレクトリ運用の原則

1. **チーム共有ファイルはコミット**: `settings.json`, `rules/`, `skills/`, `agents/`
2. **個人設定は `.local` 系に**: `settings.local.json`, `CLAUDE.local.md`
3. **秘密情報は permissions.deny で保護**: `.claudeignore` はアクセス制御ではない
4. **skills/ を新しいワークフローに使う**: commands/ は後方互換のみ
5. **rules/ でパス指定**: 必要な時だけ読み込ませてコンテキスト節約
6. **オートメモリを活用**: セッション跨ぎの知識を自動蓄積
7. **定期的にサイズ監視**: file-history の肥大化に注意
8. **hooks で確実なルール強制**: CLAUDE.md は助言的、hooks は決定論的

---

## 調査ソース

- [Explore the .claude directory](https://code.claude.com/docs/en/claude-directory) — 公式 .claude ディレクトリ解説
- [Claude Code settings](https://code.claude.com/docs/en/settings) — 公式設定ドキュメント
- [Best Practices for Claude Code](https://code.claude.com/docs/en/best-practices) — 公式ベストプラクティス
- [Hooks reference](https://code.claude.com/docs/en/hooks) — 公式フック解説
- [~/.claude/ ディレクトリ - 肥大化問題と対策について](https://zenn.dev/dk_/articles/f788096aa1a770) — Zenn（肥大化対策）
- [CLAUDE.md はどこに置けばいいの？読み込み順を図解で解説](https://zenn.dev/76hata/articles/6744b16d2241ad) — Zenn（配置と優先順位）
- [Claude Code メモリ運用の教科書](https://zenn.dev/caphtech/articles/claude-code-memory-guide) — Zenn（メモリ運用）
- [Claude Code 設定ファイル配置ガイド](https://zenn.dev/76hata/articles/4f3a78b377bcd2) — Zenn（設定ファイル配置）
- [Anatomy of the .claude/ Folder](https://blog.dailydoseofds.com/p/anatomy-of-the-claude-folder) — Daily Dose of DS
- [Claude Code settings.json: Complete config guide](https://www.eesel.ai/blog/settings-json-claude-code) — eesel AI
- [You Should Be Versioning Your ~/.claude Config](https://felipeelias.github.io/2026/02/27/version-your-claude-files.html) — dotfiles 管理の提案
- [Claude Code 設定ファイル完全ガイド](https://qiita.com/KM-Eye/items/f0ab76a91e93189ec492) — Qiita
