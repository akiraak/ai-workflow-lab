# Hooks 実用レシピ集

Claude Code の **Hooks** は、ツール実行やセッションイベントに連動してシェルコマンドを自動実行する仕組みです。CLAUDE.md が「お願い」であるのに対し、Hooks は **確定的に実行される**ため、フォーマットやリントなど「絶対に守りたいルール」の強制に最適です。

> Hooks の基本概念については [1-4. slash commands・ツール連携](/experiments/claude-code-prompting/04-slash-commands) を参照してください。

## 基礎知識

### settings.json の配置場所

| スコープ | パス | 優先度 | 用途 |
|---------|------|--------|------|
| ユーザーグローバル | `~/.claude/settings.json` | 低 | 全プロジェクト共通 |
| プロジェクト共有 | `.claude/settings.json` | 中 | チームで共有（Git 管理） |
| プロジェクトローカル | `.claude/settings.local.json` | 高 | 個人用（自動 gitignore） |

配列（hooks を含む）はスコープ間で **マージ** されます。

### Command Hook の入出力プロトコル

```
stdin (JSON) → コマンド実行 → exit code + stdout/stderr
```

| 終了コード | 動作 | 出力先 |
|-----------|------|--------|
| `0` | 続行。stdout のテキストが Claude のコンテキストに追加される | stdout → Claude |
| `2` | **操作をブロック**。stderr のメッセージが Claude にフィードバックされる | stderr → Claude |
| その他 | 続行。stderr はログにのみ記録 | stderr → ログ |

stdin に渡される JSON の例（`PreToolUse` / `PostToolUse`）:

```json
{
  "session_id": "abc-123",
  "cwd": "/home/user/project",
  "tool_name": "Edit",
  "tool_input": {
    "file_path": "/home/user/project/src/index.ts",
    "old_string": "...",
    "new_string": "..."
  }
}
```

---

## レシピ一覧

### 1. ファイル保存時の自動フォーマット（Prettier / ESLint）

**ユースケース**: Claude がファイルを編集・作成するたびに、自動でフォーマッタとリンタを実行して品質を保つ。

#### JS/TS 向け（Prettier + ESLint）

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "file=$(cat | jq -r '.tool_input.file_path // empty') && if [ -n \"$file\" ] && [[ \"$file\" =~ \\.(js|ts|jsx|tsx)$ ]]; then npx eslint --fix \"$file\" 2>/dev/null; npx prettier --write \"$file\" 2>/dev/null; fi; exit 0"
          }
        ]
      }
    ]
  }
}
```

#### Python 向け（Ruff）

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "file=$(cat | jq -r '.tool_input.file_path // empty') && if [ -n \"$file\" ] && [[ \"$file\" == *.py ]]; then ruff check --fix \"$file\" 2>/dev/null; ruff format \"$file\" 2>/dev/null; fi; exit 0"
          }
        ]
      }
    ]
  }
}
```

**動作の仕組み**:
1. `PostToolUse` で `Write` または `Edit` の完了後にトリガー
2. stdin の JSON から `file_path` を取得
3. 拡張子が対象ファイルなら、フォーマッタ/リンタを `--fix` モードで実行
4. `exit 0` で常に続行（フォーマットの失敗でセッションを止めない）

**カスタマイズのヒント**:
- `2>/dev/null` を外すとエラー詳細がログに残る
- `npx` を `bunx` や `pnpx` に変えてパッケージマネージャに合わせる

> [B6 実験](/experiments/phase-4b/B6) で実証済み: Hooks 使用時は ESLint エラーが **0件**（7回中7回成功）。

---

### 2. 保護ファイルへの編集ブロック

**ユースケース**: マイグレーションファイルやロックファイルなど、Claude に触らせたくないファイルへの編集を阻止する。

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "file=$(cat | jq -r '.tool_input.file_path // empty') && for pattern in '*/migrations/*' 'package-lock.json' 'yarn.lock' 'pnpm-lock.yaml' '.env' '.env.*'; do case \"$file\" in $pattern) echo \"BLOCKED: $file is a protected file\" >&2; exit 2;; esac; done; exit 0"
          }
        ]
      }
    ]
  }
}
```

**動作の仕組み**:
1. `PreToolUse` でツール実行 **前** にトリガー
2. ファイルパスがパターンにマッチすれば `exit 2` でブロック
3. stderr のメッセージが Claude にフィードバックされ、Claude は別の方法を検討する

**カスタマイズのヒント**:
- `pattern` リストに自分のプロジェクトの保護対象を追加
- 特定ブランチだけ保護したい場合は `git branch --show-current` で分岐

---

### 3. 編集後の自動テスト実行

**ユースケース**: ソースファイル編集後に、対応するテストファイルを自動実行して即座にフィードバックする。

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "file=$(cat | jq -r '.tool_input.file_path // empty') && if [ -z \"$file\" ] || [[ \"$file\" == *.test.* ]] || [[ \"$file\" == *.spec.* ]]; then exit 0; fi && dir=$(dirname \"$file\") && base=$(basename \"$file\" | sed 's/\\.[^.]*$//') && test_file=$(find \"$dir\" -maxdepth 1 -name \"${base}.test.*\" -o -name \"${base}.spec.*\" 2>/dev/null | head -1) && if [ -n \"$test_file\" ]; then result=$(npx jest \"$test_file\" --no-coverage 2>&1) || echo \"TEST FAILED for $test_file: $result\"; fi; exit 0"
          }
        ]
      }
    ]
  }
}
```

**動作の仕組み**:
1. 編集されたファイルが `*.test.*` / `*.spec.*` 自体なら何もしない
2. 同じディレクトリに対応するテストファイルがあれば実行
3. テスト失敗時は stdout で Claude にフィードバック → Claude が自動修正を試みる

**カスタマイズのヒント**:
- `npx jest` を `npx vitest run` や `pytest` に変更してフレームワークに合わせる
- `find` の `-maxdepth` を広げて `__tests__/` ディレクトリも探索可能

---

### 4. セキュリティ: シークレット検出

**ユースケース**: ファイル書き込み前に API キーやパスワードのハードコードを検出してブロックする。

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "input=$(cat) && content=$(echo \"$input\" | jq -r '.tool_input.new_string // .tool_input.content // empty') && if [ -n \"$content\" ] && echo \"$content\" | grep -qiE '(AKIA[0-9A-Z]{16}|sk-[a-zA-Z0-9]{20,}|ghp_[a-zA-Z0-9]{36}|password\\s*=\\s*[\"'\\'']\\''.+[\"'\\'']\\'')'; then echo 'BLOCKED: Potential secret detected in file content. Use environment variables instead.' >&2; exit 2; fi; exit 0"
          }
        ]
      }
    ]
  }
}
```

検出パターン:
- `AKIA...` — AWS アクセスキー
- `sk-...` — OpenAI / Anthropic API キー
- `ghp_...` — GitHub Personal Access Token
- `password = "..."` — ハードコードパスワード

**動作の仕組み**:
1. `PreToolUse` で書き込み内容（`new_string` または `content`）を取得
2. 正規表現でシークレットパターンをスキャン
3. マッチすれば `exit 2` でブロックし、環境変数の使用を提案

**カスタマイズのヒント**:
- プロジェクト固有のシークレットパターンを追加
- `.env.example` など許可ファイルをホワイトリストに加える
- より堅牢な検出が必要なら [gitleaks](https://github.com/gitleaks/gitleaks) や [detect-secrets](https://github.com/Yelp/detect-secrets) をコマンドに組み込む

---

### 5. コミットメッセージ規約の強制

**ユースケース**: `git commit` 実行前に Conventional Commits 形式を検証する。

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "cmd=$(cat | jq -r '.tool_input.command // empty') && if ! echo \"$cmd\" | grep -q 'git commit'; then exit 0; fi && msg=$(echo \"$cmd\" | grep -oP '(?<=-m [\"'\\'''\\''])[^\"'\\'''\\'']+'') && if [ -z \"$msg\" ]; then exit 0; fi && if ! echo \"$msg\" | grep -qE '^(feat|fix|docs|style|refactor|test|chore|ci|perf|build|revert)(\\(.+\\))?!?:'; then echo \"BLOCKED: Commit message must follow Conventional Commits format (e.g., feat: add feature)\" >&2; exit 2; fi; exit 0"
          }
        ]
      }
    ]
  }
}
```

**動作の仕組み**:
1. `Bash` ツールの実行前にコマンド内容を取得
2. `git commit` を含むコマンドのみ対象
3. `-m` オプションからメッセージを抽出し、Conventional Commits 形式を検証
4. 不正な形式なら `exit 2` でブロック

**カスタマイズのヒント**:
- 許可するプレフィックスは `(feat|fix|docs|...)` を編集
- このリポジトリのように日本語コミットを使う場合は、形式チェックを日本語に対応させる
- HEREDOC を使ったコミットの場合はメッセージ抽出が難しいため、`commitlint` との併用を推奨

---

### 6. compact 後のコンテキスト再注入

**ユースケース**: コンテキスト圧縮（compact）後に、忘れてほしくないプロジェクトルールを自動で再注入する。

```json
{
  "hooks": {
    "PostCompact": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "echo '## Post-compact reminder\n- Use Bun, not npm\n- Run bun test before committing\n- All API calls must go through src/api/client.ts\n- Database migrations require review — do not auto-generate'"
          }
        ]
      }
    ]
  }
}
```

**動作の仕組み**:
1. `PostCompact` は compact 完了後にトリガー
2. stdout に出力されたテキストが Claude のコンテキストに追加される
3. Claude は再注入されたルールを認識して作業を続ける

**カスタマイズのヒント**:
- プロジェクトの CLAUDE.md から特に重要なルールだけを抜粋
- ファイルから読み込む形にすればメンテナンスしやすい: `cat .claude/post-compact-rules.txt`
- compact は長時間セッションで自動的に発生するため、見落としやすいルール違反を防げる

---

### 7. 操作ログの記録（監査証跡）

**ユースケース**: Claude が実行した全ツール操作をログファイルに記録し、後から監査できるようにする。

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "input=$(cat) && tool=$(echo \"$input\" | jq -r '.tool_name // \"unknown\"') && file=$(echo \"$input\" | jq -r '.tool_input.file_path // .tool_input.command // \"N/A\"' | head -c 200) && echo \"$(date -Iseconds) | $tool | $file\" >> .claude/audit.log; exit 0"
          }
        ]
      }
    ]
  }
}
```

出力例（`.claude/audit.log`）:

```
2026-04-11T10:23:45+09:00 | Edit | /home/user/project/src/index.ts
2026-04-11T10:23:48+09:00 | Bash | npm test
2026-04-11T10:24:01+09:00 | Write | /home/user/project/src/utils.ts
```

**動作の仕組み**:
1. 全ツール実行後にトリガー（matcher が空 = 全マッチ）
2. ツール名とファイルパス（またはコマンド）をタイムスタンプ付きで追記
3. `head -c 200` で長いコマンドを切り詰め

**カスタマイズのヒント**:
- `.gitignore` に `.claude/audit.log` を追加
- JSON Lines 形式で出力するとパース可能に: `echo "$input" | jq -c '{ts: now | todate, tool: .tool_name, target: (.tool_input.file_path // .tool_input.command // "N/A")}'`
- ログローテーションが必要なら `logrotate` やサイズチェックを追加

---

### 8. デスクトップ / ターミナル通知

**ユースケース**: Claude の作業完了時に OS 通知を送り、他の作業に集中しながら待てるようにする。

#### macOS

```json
{
  "hooks": {
    "Notification": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "msg=$(cat | jq -r '.message // \"Task completed\"') && osascript -e \"display notification \\\"$msg\\\" with title \\\"Claude Code\\\"\"; exit 0"
          }
        ]
      }
    ]
  }
}
```

#### Linux（notify-send）

```json
{
  "hooks": {
    "Notification": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "msg=$(cat | jq -r '.message // \"Task completed\"') && notify-send 'Claude Code' \"$msg\"; exit 0"
          }
        ]
      }
    ]
  }
}
```

#### WSL（Windows トースト通知）

```json
{
  "hooks": {
    "Notification": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "msg=$(cat | jq -r '.message // \"Task completed\"') && powershell.exe -Command \"[Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime] > $null; $xml = [Windows.UI.Notifications.ToastNotificationManager]::GetTemplateContent(0); $xml.GetElementsByTagName('text')[0].AppendChild($xml.CreateTextNode('$msg')) > $null; [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier('Claude Code').Show([Windows.UI.Notifications.ToastNotification]::new($xml))\"; exit 0"
          }
        ]
      }
    ]
  }
}
```

**動作の仕組み**:
1. `Notification` イベントで Claude が通知を送ろうとした時にトリガー
2. stdin からメッセージを取得して OS のネイティブ通知に変換

**カスタマイズのヒント**:
- サウンドを鳴らしたい場合は `paplay` や `afplay` を追加
- 通知サービス（Slack Webhook、PushBullet 等）に POST する拡張も可能

---

### 9. prompt 型: タスク完了チェック

**ユースケース**: Claude が作業完了と判断した時に、TODO チェックリストの残項目がないか LLM に確認させる。

```json
{
  "hooks": {
    "Stop": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "prompt",
            "prompt": "Check if there are any unchecked items (- [ ]) in TODO.md that were part of the current task. If all relevant items are checked or moved to DONE.md, respond YES. If there are remaining unchecked items that should have been completed, respond NO and explain what's missing."
          }
        ]
      }
    ]
  }
}
```

**動作の仕組み**:
1. `Stop` イベントは Claude がレスポンスを完了しようとする時にトリガー
2. `prompt` 型は LLM に YES/NO の判断を委任
3. NO の場合、Claude は作業を継続して残タスクに取り組む

**カスタマイズのヒント**:
- prompt のチェック内容をプロジェクトに合わせて変更（テストカバレッジ、ドキュメント更新等）
- `command` 型と組み合わせて、自動チェック → LLM 判断の 2段階にすることも可能
- `Stop` フックは頻繁にトリガーされるため、軽量なチェックに留めるのが望ましい

---

### 10. 複数フックの組み合わせ（実践例）

**ユースケース**: フォーマット + リント + テストのパイプラインを構成し、品質を多層で担保する。

以下は TypeScript プロジェクト向けの実践的な組み合わせ構成です。

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "file=$(cat | jq -r '.tool_input.file_path // empty') && for p in '*/migrations/*' 'package-lock.json' '.env' '.env.*'; do case \"$file\" in $p) echo \"BLOCKED: $file is protected\" >&2; exit 2;; esac; done; exit 0"
          }
        ]
      },
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "content=$(cat | jq -r '.tool_input.new_string // .tool_input.content // empty') && if [ -n \"$content\" ] && echo \"$content\" | grep -qiE '(AKIA[0-9A-Z]{16}|sk-[a-zA-Z0-9]{20,})'; then echo 'BLOCKED: Secret detected' >&2; exit 2; fi; exit 0"
          }
        ]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "file=$(cat | jq -r '.tool_input.file_path // empty') && if [ -n \"$file\" ] && [[ \"$file\" =~ \\.(ts|tsx)$ ]]; then npx eslint --fix \"$file\" 2>/dev/null; npx prettier --write \"$file\" 2>/dev/null; fi; exit 0"
          }
        ]
      },
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "file=$(cat | jq -r '.tool_input.file_path // empty') && if [ -z \"$file\" ] || [[ \"$file\" == *.test.* ]]; then exit 0; fi && dir=$(dirname \"$file\") && base=$(basename \"$file\" | sed 's/\\.[^.]*$//') && tf=$(find \"$dir\" -maxdepth 1 -name \"${base}.test.*\" 2>/dev/null | head -1) && if [ -n \"$tf\" ]; then result=$(npx jest \"$tf\" --no-coverage 2>&1) || echo \"TEST FAILED: $result\"; fi; exit 0"
          }
        ]
      }
    ],
    "PostCompact": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "echo '## Reminder\\n- Run tests before committing\\n- Use strict TypeScript (no any)'"
          }
        ]
      }
    ]
  }
}
```

**パイプライン実行順序**:

```
[PreToolUse]
  1. 保護ファイルチェック → ブロック or 続行
  2. シークレット検出 → ブロック or 続行

[ツール実行]

[PostToolUse]
  3. ESLint + Prettier 自動修正
  4. 対応テスト自動実行 → 失敗時フィードバック
```

> この構成は [B6 実験](/experiments/phase-4b/B6) の結果を基にしています。Hooks によるリント自動化は **100% のエラー排除率** を達成しました。

**カスタマイズのヒント**:
- Pre と Post のフックは配列内で上から順に実行される
- 各フックは独立しているため、不要なレシピを外しても他に影響しない
- チーム共有は `.claude/settings.json`、個人カスタマイズは `.claude/settings.local.json` で分離
