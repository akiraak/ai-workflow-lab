# 1-4. slash commands・ツール連携

## 調査目的

組み込みスラッシュコマンドの活用シーン、カスタム slash commands（Skills）の作成と運用、hooks の仕組みと活用パターン、MCP 連携、CLI オプションを調査し、効果的なツール活用法を明らかにする。

---

## 1. 組み込みスラッシュコマンド

Claude Code には50以上の組み込みコマンドがある。`/` を入力すると一覧が表示され、文字を続けるとフィルタされる。

> "Not all commands are visible to every user. Some depend on your platform, plan, or environment."
> — [Built-in commands](https://code.claude.com/docs/en/commands)

### 基本操作

| コマンド | 用途 |
|---------|------|
| `/help` | ヘルプ表示 |
| `/clear` (`/reset`, `/new`) | 会話履歴をクリアしてコンテキストを解放 |
| `/compact [instructions]` | 会話を要約して圧縮。保持する内容を指示可能 |
| `/exit` (`/quit`) | CLI を終了 |

### セッション管理

| コマンド | 用途 |
|---------|------|
| `/resume [session]` (`/continue`) | 過去のセッションをID/名前で再開 |
| `/rename [name]` | セッションに名前を付ける |
| `/branch [name]` (`/fork`) | 会話の分岐を作成 |
| `/rewind` (`/checkpoint`) | 会話やコードを過去の時点に巻き戻す |
| `/export [filename]` | 会話をテキストファイルとしてエクスポート |
| `/copy [N]` | 直近のアシスタント応答をクリップボードにコピー |

### モデル・設定

| コマンド | 用途 |
|---------|------|
| `/model [model]` | モデルを即座に切り替え（応答中でも可） |
| `/effort [low\|medium\|high\|max\|auto]` | エフォートレベルを設定 |
| `/fast [on\|off]` | Fast mode のトグル |
| `/config` (`/settings`) | テーマ、モデル、出力スタイルなどの設定画面 |
| `/permissions` (`/allowed-tools`) | ツール権限の allow/ask/deny ルール管理 |

### コスト・使用量

| コマンド | 用途 |
|---------|------|
| `/cost` | トークン使用量の統計表示 |
| `/usage` | プランの使用制限・レートリミット状況 |
| `/stats` | 日次使用量、セッション履歴、モデル傾向の可視化 |
| `/context` | コンテキスト使用量をカラーグリッドで可視化 |

### プロジェクト管理

| コマンド | 用途 |
|---------|------|
| `/init` | CLAUDE.md でプロジェクトを初期化 |
| `/memory` | CLAUDE.md ファイルの編集、オートメモリ管理 |
| `/add-dir <path>` | セッションに作業ディレクトリを追加 |

### 開発支援

| コマンド | 用途 |
|---------|------|
| `/diff` | 未コミットの変更とターンごとの diff ビューア |
| `/plan [description]` | プランモードに入る |
| `/ultraplan <prompt>` | ブラウザでレビュー可能な計画を立案 |
| `/security-review` | 変更にセキュリティ脆弱性がないか分析 |
| `/btw <question>` | 会話に追加せずにサイド質問（コンテキストを汚さない） |

### ツール連携

| コマンド | 用途 |
|---------|------|
| `/mcp` | MCP サーバー接続管理・OAuth 認証 |
| `/hooks` | Hook 設定の閲覧 |
| `/plugin` | プラグイン管理 |
| `/skills` | 利用可能なスキル一覧 |

### バンドルスキル（プロンプトベースの組み込み機能）

組み込みコマンドとは異なり、プロンプトベースで Claude がツールを駆使して作業する。

| スキル | 用途 |
|--------|------|
| `/batch <instruction>` | コードベース全体に並列で大規模変更を実行 |
| `/simplify [focus]` | 最近変更したファイルのコード品質をレビューし修正 |
| `/debug [description]` | デバッグログの有効化と問題のトラブルシュート |
| `/loop [interval] <prompt>` | プロンプトを定期的に繰り返し実行 |

> "Unlike built-in commands, which execute fixed logic directly, bundled skills are prompt-based and give Claude a detailed playbook to orchestrate work using its tools."
> — [Built-in commands](https://code.claude.com/docs/en/commands)

---

## 2. カスタム slash commands（Skills）の作成と運用

### 基本構造

v2.1.3 以降、「カスタムコマンド」と「スキル」は統合された。公式はスキル形式を推奨。

> "Custom commands have been merged into skills. A file at `.claude/commands/deploy.md` and a skill at `.claude/skills/<skill-name>/SKILL.md` both create `/deploy` and work the same way."
> — [Extend Claude with skills](https://code.claude.com/docs/en/skills)

### 配置場所と適用範囲

| レベル | パス | 適用範囲 |
|--------|------|---------|
| Enterprise | マネージド設定 | 組織全体 |
| Personal | `~/.claude/skills/<name>/SKILL.md` | 全プロジェクト |
| Project | `.claude/skills/<name>/SKILL.md` | 当該プロジェクトのみ |
| Plugin | `<plugin>/skills/<name>/SKILL.md` | プラグイン有効時 |

### SKILL.md のフロントマター

```yaml
---
name: fix-issue
description: Fix a GitHub issue
disable-model-invocation: true
allowed-tools: Bash Read Grep
context: fork
agent: Explore
model: fast_model
effort: high
---
スキルの指示内容...
```

| フィールド | 説明 |
|-----------|------|
| `name` | スキル名（= スラッシュコマンド名） |
| `description` | 用途の説明（Claude の自動起動判断に使われる、250文字で切り詰め） |
| `disable-model-invocation` | `true` で Claude 自動呼び出しを禁止（手動のみ） |
| `user-invocable` | `false` で `/` メニューから非表示（Claude 専用の背景知識） |
| `allowed-tools` | スキル実行時に許可するツール |
| `context: fork` | サブエージェントで隔離実行 |
| `agent` | サブエージェントの種類 |
| `paths` | 特定パスのファイル作業時のみ自動発動するグロブパターン |

### 引数テンプレート

```yaml
---
name: fix-issue
---
Fix GitHub issue $ARGUMENTS following our coding standards.
```

`/fix-issue 123` で `$ARGUMENTS` が `123` に置換される。位置引数は `$0`, `$1` 形式。

### 動的コンテキスト注入

`` !`command` `` 構文でシェルコマンドの出力をスキル内容に注入：

```yaml
---
name: pr-summary
context: fork
agent: Explore
---
## PR context
- PR diff: !`gh pr diff`
- Changed files: !`gh pr diff --name-only`
```

### 活用パターン

| パターン | 説明 | 例 |
|---------|------|-----|
| **リファレンス型** | 常時参照する知識 | API コンベンション、コーディング規約 |
| **タスク型** | 手順ベースの操作 | デプロイ、コミット、コード生成 |
| **自動起動型** | パスマッチで自動ロード | テストルール、API ルール |

> 「スキルは『必要に応じてClaude Codeが本文全体を読み込む』特性を活用し、コンテキスト効率的に提供できる」
> — [Zenn: notahotel](https://zenn.dev/notahotel/articles/a175aa95629d0b)

> 「副作用のある操作は `disable-model-invocation: true` で自動実行を防ぎ、ユーザー明示的な呼び出しに制限すべき」
> — [Zenn: wisteria30](https://zenn.dev/wisteria30/articles/f0c2def622412f)

---

## 3. Hooks の仕組みと活用パターン

### Hooks とは

Claude Code のライフサイクルの特定ポイントで自動実行される処理。CLAUDE.md の指示が「助言」であるのに対し、**Hooks は「決定論的」で確実に実行される**。

> "Use hooks for actions that must happen every time with zero exceptions. Unlike CLAUDE.md instructions which are advisory, hooks are deterministic and guarantee the action happens."
> — [Hooks reference](https://code.claude.com/docs/en/hooks)

### 設定場所

| 場所 | スコープ |
|------|---------|
| `~/.claude/settings.json` | 全プロジェクト（個人） |
| `.claude/settings.json` | プロジェクト（チーム共有） |
| `.claude/settings.local.json` | プロジェクト（個人、gitignore） |
| マネージドポリシー | 組織全体 |
| Skill/Agent フロントマター | コンポーネント実行中のみ |

### 主要フックイベント

| イベント | タイミング | ブロック可否 |
|---------|-----------|------------|
| `SessionStart` | セッション開始/再開/clear/compact | 不可 |
| `UserPromptSubmit` | プロンプト送信後、処理前 | 可 |
| `PreToolUse` | ツール実行前 | 可 |
| `PostToolUse` | ツール成功後 | 不可 |
| `Stop` | Claude 応答完了時 | 可 |
| `Notification` | 通知送信時 | 不可 |
| `PreCompact` / `PostCompact` | コンテキスト圧縮前後 | 不可 |
| `FileChanged` | 監視ファイルのディスク上の変更 | 不可 |
| `SessionEnd` | セッション終了 | 不可 |

### 4種類のフックタイプ

| タイプ | 説明 |
|--------|------|
| `command` | シェルコマンド実行（stdin にJSON、exit code で制御） |
| `http` | HTTP エンドポイントに POST |
| `prompt` | LLM モデルに yes/no 判定を委任 |
| `agent` | サブエージェントにツールベースの検証を委任 |

### 通信プロトコル（Command Hook）

- **入力**: stdin に JSON（session_id, cwd, tool_name, tool_input 等）
- **Exit 0**: 処理続行。stdout のテキストはコンテキストに追加
- **Exit 2**: ブロック。stderr のメッセージが Claude へフィードバック
- **その他**: 処理続行、stderr はログのみ

### 実践的な活用パターン

#### パターン1: ファイル編集後の自動フォーマット

```json
{
  "hooks": {
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

#### パターン2: 保護ファイルの編集ブロック

```json
{
  "hooks": {
    "PreToolUse": [{
      "matcher": "Edit|Write",
      "hooks": [{
        "type": "command",
        "command": "bash scripts/check-protected-files.sh"
      }]
    }]
  }
}
```

exit code 2 でブロック、stderr のメッセージが Claude にフィードバックされる。

#### パターン3: デスクトップ通知

```json
{
  "hooks": {
    "Notification": [{
      "matcher": "",
      "hooks": [{
        "type": "command",
        "command": "osascript -e 'display notification \"Claude Code needs your attention\" with title \"Claude Code\"'"
      }]
    }]
  }
}
```

#### パターン4: compact 後のコンテキスト再注入

```json
{
  "hooks": {
    "SessionStart": [{
      "matcher": "compact",
      "hooks": [{
        "type": "command",
        "command": "echo 'Reminder: use Bun, not npm. Run bun test before committing.'"
      }]
    }]
  }
}
```

#### パターン5: prompt 型（タスク完了チェック）

```json
{
  "hooks": {
    "Stop": [{
      "hooks": [{
        "type": "prompt",
        "prompt": "Check if all tasks are complete. If not, respond with {\"ok\": false, \"reason\": \"what remains\"}."
      }]
    }]
  }
}
```

> "PreToolUse hooks fire before any permission-mode check. A hook that returns `permissionDecision: \"deny\"` blocks the tool even in `bypassPermissions` mode."
> — [Hooks reference](https://code.claude.com/docs/en/hooks)

---

## 4. MCP (Model Context Protocol) サーバーとの連携

### 概要

MCP は AI ツール統合のオープンソース標準プロトコル。Claude Code を外部ツール・データソースに接続できる。

### 3つの接続方式

| 方式 | コマンド例 |
|------|-----------|
| **HTTP（推奨）** | `claude mcp add --transport http notion https://mcp.notion.com/mcp` |
| **SSE（非推奨）** | `claude mcp add --transport sse asana https://mcp.asana.com/sse` |
| **stdio（ローカル）** | `claude mcp add --transport stdio db -- npx -y @bytebase/dbhub --dsn "..."` |

### スコープ管理

| スコープ | 保存場所 | 適用範囲 |
|---------|---------|---------|
| `local`（デフォルト） | `~/.claude.json` | 自分のみ、現プロジェクト |
| `project` | `.mcp.json`（リポジトリ共有可能） | チーム全体 |
| `user` | `~/.claude.json` | 自分の全プロジェクト |

### 管理コマンド

```bash
claude mcp list          # 一覧表示
claude mcp get github    # 詳細表示
claude mcp remove github # 削除
/mcp                     # Claude Code 内でステータス確認・OAuth認証
```

### Tool Search によるコンテキスト効率化

> "Tool search keeps MCP context usage low by deferring tool definitions until Claude needs them. Only tool names load at session start, so adding more MCP servers has minimal impact on your context window."
> — [Connect Claude Code to tools via MCP](https://code.claude.com/docs/en/mcp)

### .mcp.json での環境変数展開

```json
{
  "mcpServers": {
    "api-server": {
      "type": "http",
      "url": "${API_BASE_URL:-https://api.example.com}/mcp",
      "headers": {
        "Authorization": "Bearer ${API_KEY}"
      }
    }
  }
}
```

`${VAR:-default}` 形式でデフォルト値も設定可能。

### 代表的な MCP サーバー

| サービス | 接続方法 |
|---------|---------|
| GitHub | `claude mcp add --transport http github https://api.githubcopilot.com/mcp/` |
| Sentry | `claude mcp add --transport http sentry https://mcp.sentry.dev/mcp` |
| PostgreSQL | `claude mcp add --transport stdio db -- npx -y @bytebase/dbhub --dsn "..."` |
| Notion | `claude mcp add --transport http notion https://mcp.notion.com/mcp` |

---

## 5. CLI オプションの活用

### セッション管理

| フラグ | 用途 |
|--------|------|
| `-c` | 直近の会話を継続 |
| `-r <session>` | セッションをID/名前で再開 |
| `-n "name"` | セッションに名前を付けて開始 |
| `-w <name>` (`--worktree`) | 隔離された git worktree で起動 |

### 非対話モード（自動化向け）

| フラグ | 用途 |
|--------|------|
| `-p "query"` | 非対話モード（結果を出力して終了） |
| `--output-format json\|stream-json\|text` | 出力フォーマット指定 |
| `--max-turns N` | エージェントターン数の上限 |
| `--max-budget-usd N` | API コスト上限 |

### モデル・パフォーマンス

| フラグ | 用途 |
|--------|------|
| `--model claude-sonnet-4-6` | モデル指定（`sonnet`, `opus` エイリアス可） |
| `--effort low\|medium\|high\|max` | エフォートレベル設定 |
| `--fallback-model sonnet` | オーバーロード時のフォールバック |

### システムプロンプト制御

| フラグ | 用途 |
|--------|------|
| `--system-prompt "text"` | デフォルトプロンプトを完全置換 |
| `--append-system-prompt "text"` | デフォルトプロンプトに追記 |

### ツール・権限制御

| フラグ | 用途 |
|--------|------|
| `--tools "Bash,Edit,Read"` | 使用可能なツールを制限 |
| `--allowedTools "Bash(git *)"` | 許可なしで実行できるツール |
| `--disallowedTools "Edit"` | 使用禁止ツール |
| `--permission-mode plan\|auto` | 権限モード指定 |

### その他の便利フラグ

| フラグ | 用途 |
|--------|------|
| `--bare` | 最小モード（hooks/skills/MCP/CLAUDE.md をスキップ、高速起動） |
| `--debug [categories]` | デバッグモード |
| `--json-schema '...'` | 構造化出力のスキーマ指定 |

> "`claude --help` does not list every flag, so a flag's absence from `--help` does not mean it is unavailable."
> — [CLI reference](https://code.claude.com/docs/en/cli-reference)

---

## 6. 各機能の使い分けガイド

| 状況 | 推奨機能 |
|------|---------|
| 特定イベントで確実に処理を実行したい | **Hooks** |
| 常に必要な情報を提供したい | **CLAUDE.md** |
| 独立したタスクで結果だけ必要 | **サブエージェント** |
| 手動で明示的に呼び出す繰り返し操作 | **スラッシュコマンド / スキル** |
| 条件付きで自動ロードする知識 | **スキル（自動起動）** |
| 外部ツール・API との連携 | **MCP** |

> 「CLAUDE.md は『人間だけが知っていること』を書き、settings.json は権限を最小権限の原則で管理し、Hooks で確実性が必要な処理を自動化する」
> — [Qiita: emi_ndk](https://qiita.com/emi_ndk/items/56b2fc8bf4e7ed5ba7f3)

> 「スラッシュコマンドは『詠唱破棄』（プロンプトのショートカット化）」
> — [Zenn: notahotel](https://zenn.dev/notahotel/articles/a175aa95629d0b)

---

## 総合的なベストプラクティス

### ツール活用の原則

1. **確実に実行すべき処理は Hooks**: CLAUDE.md の指示は助言的、Hooks は決定論的
2. **副作用のあるスキルは `disable-model-invocation: true`**: 自動実行を防ぐ
3. **スキルで CLAUDE.md を軽量化**: 毎回不要な情報はスキルに移してオンデマンド化
4. **MCP でツール統合**: 外部サービスとの連携は MCP が標準
5. **`/btw` でコンテキスト節約**: 本筋から外れた質問はサイド質問で
6. **`/compact` に保持指示を渡す**: 重要な文脈の喪失を防ぐ
7. **CLI フラグで自動化**: `-p` と `--output-format json` で CI/CD 統合

---

## 調査ソース

- [Built-in commands](https://code.claude.com/docs/en/commands) — 公式組み込みコマンドリファレンス
- [Extend Claude with skills](https://code.claude.com/docs/en/skills) — 公式スキルドキュメント
- [Hooks reference](https://code.claude.com/docs/en/hooks) — 公式フックリファレンス
- [Automate workflows with hooks](https://code.claude.com/docs/en/hooks-guide) — 公式フック実践ガイド
- [Connect Claude Code to tools via MCP](https://code.claude.com/docs/en/mcp) — 公式 MCP ドキュメント
- [CLI reference](https://code.claude.com/docs/en/cli-reference) — 公式 CLI リファレンス
- [Customize Claude Code with plugins](https://www.anthropic.com/news/claude-code-plugins) — Anthropic プラグイン紹介
- [Claude Code完全攻略ガイド：スラッシュコマンド術](https://zenn.dev/uguisu_blog/articles/003_claude-code-slash-commands) — Zenn
- [濫立するClaude Codeの機能の使い分け](https://zenn.dev/notahotel/articles/a175aa95629d0b) — Zenn（機能の使い分け判断フロー）
- [Claude Codeの拡張機能をおさらいする](https://zenn.dev/wisteria30/articles/f0c2def622412f) — Zenn
- [Claude Codeの新機能「Hooks」解説](https://zenn.dev/buddypia/articles/99abea47607225) — Zenn
- [Claude Codeの自動化レシピ集](https://qiita.com/th19930828/items/a979fe60c6c22bb82d02) — Qiita
- [Claude Code完全設定ガイド2026](https://qiita.com/emi_ndk/items/56b2fc8bf4e7ed5ba7f3) — Qiita
- [Claude Code Hooks 完全実践ガイド 2026年版](https://qiita.com/AI-SKILL-LAB/items/99ce8c1eea364ab79eef) — Qiita
