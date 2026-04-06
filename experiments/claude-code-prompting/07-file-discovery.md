# 1-7. プロジェクト内のファイルを把握しやすくするための仕組み

## 調査目的

Claude Code がファイル一覧やプロジェクト構造を認識する仕組み、ノイズ除外の方法、プロジェクトマップの有効性を調査し、効率的なファイル把握のための設計指針を明らかにする。

---

## 1. Claude Code がファイルを認識する仕組み

### エージェントループの基本構造

Claude Code はエージェントループで動作する。ユーザーのプロンプトを受け取ると、3つのフェーズを繰り返す：

> "When you give Claude a task, it works through three phases: **gather context**, **take action**, and **verify results**. These phases blend together."
> — [How Claude Code works](https://code.claude.com/docs/en/how-claude-code-works)

### ファイル探索ツールの一覧

| ツール名 | 権限要否 | 役割 |
|----------|----------|------|
| **Glob** | 不要 | パターンマッチングによるファイル検索（`**/*.ts` 等） |
| **Grep** | 不要 | 正規表現によるファイル内容の検索 |
| **Read** | 不要 | ファイル内容の読み取り |
| **Bash** | 要許可 | シェルコマンドの実行（git, npm, find 等） |
| **Edit** | 要許可 | ファイルの部分編集 |
| **Write** | 要許可 | ファイルの新規作成・上書き |
| **LSP** | 不要 | 定義ジャンプ、参照検索、型エラー検出 |

重要な点として、**Glob / Grep / Read は権限不要**で、Claude は探索のために許可なく自由に呼び出せる。

> "Tools are what make Claude Code agentic. Without tools, Claude can only respond with text. With tools, Claude can act: read your code, edit files, run commands, search the web, and interact with external services."
> — [Tools reference](https://code.claude.com/docs/en/tools-reference)

### セッション開始時に自動ロードされるもの

[コンテキストウィンドウのドキュメント](https://code.claude.com/docs/en/context-window)によると、セッション開始時にロードされる情報とそのトークンコスト：

| 項目 | トークン数（目安） |
|------|-------------------|
| System prompt | ~4,200 |
| Auto memory (MEMORY.md) | ~680（先頭200行/25KBまで） |
| Environment info | ~280（作業ディレクトリ、OS、gitブランチ等） |
| MCP tools (deferred) | ~120（ツール名のみ） |
| Skill descriptions | ~450（1行の説明のみ） |
| `~/.claude/CLAUDE.md` | ~320 |
| Project CLAUDE.md | ~1,800 |
| **合計** | **~7,850** |

ユーザーのプロンプト前に約7,850トークンが消費される。

### ファイル読み込みのコスト例

| 操作 | トークン消費 |
|------|------------|
| `src/api/auth.ts` の読み込み | ~2,400 |
| `src/lib/tokens.ts` の読み込み | ~1,100 |
| `middleware.ts` の読み込み | ~1,800 |
| `auth.test.ts` の読み込み | ~1,600 |
| `grep "refreshToken"` の結果 | ~600 |

> "File reads dominate context usage. Be specific in prompts ('fix the bug in auth.ts') so Claude reads fewer files. For research-heavy tasks, use a subagent."
> — [Explore the context window](https://code.claude.com/docs/en/context-window)

---

## 2. README やディレクトリごとの説明ファイルの効果

### README.md の役割

README.md 自体は**自動ロードされない**が、CLAUDE.md から `@` インポートでコンテキストに含められる：

```markdown
See @README.md for project overview and @package.json for available npm commands.
```

### サブディレクトリの CLAUDE.md（遅延ロード）

> "Claude also discovers CLAUDE.md and CLAUDE.local.md files in subdirectories under your current working directory. Instead of loading them at launch, they are included when Claude reads files in those subdirectories."
> — [Memory](https://code.claude.com/docs/en/memory)

| 配置場所 | ロードタイミング | 用途 |
|---------|----------------|------|
| `./CLAUDE.md` | セッション開始時 | プロジェクト全体の指示 |
| `./src/api/CLAUDE.md` | そのディレクトリのファイルを読んだ時 | モジュール固有の指示 |
| `.claude/rules/*.md` | 起動時 or パスマッチ時 | トピック別ルール |

この仕組みにより、**ルートの CLAUDE.md を肥大化させずにモジュール固有のコンテキストを提供**できる。

### `.claude/rules/` によるパス指定ルール

YAML フロントマターで `paths:` を指定すると、特定のファイルパターンに一致するファイルを操作した時だけルールがロードされる：

```markdown
---
paths:
  - "src/api/**/*.ts"
---
# API 開発ルール
- すべてのエンドポイントに入力検証を含める
- 標準エラー応答形式を使用する
```

---

## 3. .gitignore と .claudeignore によるノイズ除外

### .gitignore の影響

Claude Code は `.gitignore` を**自動的に尊重**し、無視対象のファイルをコードベース探索時にスキップする。これにより `node_modules/`、ビルド成果物、ログファイルなどがコンテキストを汚さない。

### .claudeignore の現状と注意点

`.claudeignore` はコンテキスト自動ロードからの除外に効果があるが、**アクセス制御ではない**：

- Bash や Read ツールで明示的にアクセスすれば読める
- `.env` 等の秘密情報保護には `.claudeignore` だけでは不十分

> "Claude Codeの.env保護、.claudeignoreじゃないです"
> — [Qiita](https://qiita.com/riiiii/items/eb006d3dbab3d9d9034a)

### 秘密情報の保護方法

**推奨**: `.claude/settings.json` の `permissions.deny` で Read/Edit/Write 操作を明示的に拒否する。

```json
{
  "permissions": {
    "deny": [
      "Read:.env*",
      "Edit:.env*",
      "Write:.env*"
    ]
  }
}
```

### `claudeMdExcludes` 設定

大規模モノレポで他チームの CLAUDE.md が読み込まれるのを防ぐ設定：

```json
{
  "claudeMdExcludes": [
    "**/monorepo/CLAUDE.md",
    "/home/user/monorepo/other-team/.claude/rules/**"
  ]
}
```

---

## 4. ファイル数・階層の深さが探索精度に与える影響

### コンテキストウィンドウの制約

> "Most best practices are based on one constraint: Claude's context window fills up fast, and performance degrades as it fills."
> — [Best Practices](https://code.claude.com/docs/en/best-practices)

### 大規模コードベースでの課題

コミュニティの報告によると：

- 829ファイルのコードベースで、適切なコードを見つけるだけで**45Kトークンを消費**し、会話3ターン目でコンテキストが枯渇するケースがある
- モノレポでは起動時のベースラインが**15-25Kトークン**（利用可能コンテキストの10-15%）に達する

### ディレクトリ命名の効果

> "Claudeはファイルをすべて参照せず、フォルダ名を参照して指示に対して必要な情報かどうかを判断することができるようになります。限られたトークンで効率良く出力するにあたりディレクトリ構造が効いてくる"
> — [DevelopersIO](https://dev.classmethod.jp/articles/Claude_directory_for_bussiness/)

適切なディレクトリ命名により、Claude が不要なファイルの読み込みをスキップし、コンテキスト消費を抑えられる。

### 対策: サブエージェントによる探索の分離

> "When Claude researches a codebase it reads lots of files, all of which consume your context. Subagents run in separate context windows and report back summaries."
> — [Best Practices](https://code.claude.com/docs/en/best-practices)

サブエージェントが6,100トークン分のファイルを読み込んだのに対し、メインセッションに返されたのは**420トークンの要約のみ**。大幅なコンテキスト節約になる。

---

## 5. プロジェクトマップの有効性

### CLAUDE.md にディレクトリ構造を含める手法

複数のコミュニティ記事で推奨されている手法だが、公式ベストプラクティスでは**「ファイルごとの説明は含めるべきではない」**と明確に指摘：

| 含めるべき | 含めるべきでない |
|-----------|----------------|
| Claude が推測できないコマンド | ファイルごとのコードベース説明 |
| デフォルトと異なるコードスタイル | コードを読めばわかること |
| プロジェクト固有のアーキテクチャ決定 | 長い説明やチュートリアル |

### 段階的開示（Progressive Disclosure）パターン

[効果的なCLAUDE.mdの書き方](https://zenn.dev/farstep/articles/how-to-write-a-great-claude-md)で推奨される3層構造：

| 層 | 配置先 | 読み込みタイミング | 内容 |
|----|--------|-------------------|------|
| **Layer 1** | `CLAUDE.md` | 毎セッション自動 | 高シグナル情報のみ |
| **Layer 2** | `.claude/rules/`, `docs/` | タスク関連時 | パス指定ルール |
| **Layer 3** | `.claude/skills/`, `.claude/agents/` | 必要時に起動 | ワークフロー・専門知識 |

プロジェクトマップ的な情報は **Layer 1 に最小限**（主要ディレクトリの役割説明）、詳細は Layer 2/3 に分散させるのが最も効率的。

### @ インポートによるドキュメント参照

```markdown
See @README.md for project overview and @package.json for available npm commands.

# 追加の指示
- Git workflow: @docs/git-instructions.md
- アーキテクチャ: @docs/architecture.md
```

再帰的インポートは**最大5階層**まで対応。

### `/init` コマンドによる自動生成

`/init` コマンドでプロジェクト構造を自動分析し、初期 CLAUDE.md を生成できる。ただし自動生成の出力をそのまま使うのは推奨されない — 手動で精査・剪定してから運用する。

---

## 6. CLAUDE.md にプロジェクト構造を記述する効果

### 推奨される記述

```markdown
## アーキテクチャ
- API ハンドラー: `src/api/handlers/`
- ビジネスロジック: `src/services/`
- データ層: `src/repositories/`
- テスト: `tests/`（ソースと同じ構造でミラー）
```

主要ディレクトリの**役割を簡潔に**（数行で）記述するのが効果的。

### 記述の限界

> "CLAUDE.md content is delivered as a user message after the system prompt, not as part of the system prompt itself. Claude reads it and tries to follow it, but there's no guarantee of strict compliance, especially for vague or conflicting instructions."
> — [Memory](https://code.claude.com/docs/en/memory)

CLAUDE.md は「助言的（advisory）」であり、確実に実行したいルールは Hooks で実装すべき。

### サイズの制約

> "Keep it concise. For each line, ask: 'Would removing this cause Claude to make mistakes?' If not, cut it. Bloated CLAUDE.md files cause Claude to ignore your actual instructions!"
> — [Best Practices](https://code.claude.com/docs/en/best-practices)

200行以内を目標にし、CLAUDE.md の肥大化は命令遵守率の低下に直結する。

---

## 総合的なベストプラクティス

### ファイル把握を効率化する原則

1. **ディレクトリ名を意味のあるものにする**: Claude はフォルダ名を手がかりに探索対象を絞る
2. **CLAUDE.md に主要ディレクトリの役割を簡潔に記述**: ファイルごとの説明は不要
3. **サブディレクトリ CLAUDE.md で遅延ロード**: モジュール固有の指示はそのディレクトリに配置
4. **`.claude/rules/` でパス指定ルール**: 特定ファイルパターンに関連するルールを分離
5. **@ インポートで段階的開示**: 詳細はリンク先に、CLAUDE.md はコンパクトに
6. **プロンプトでファイルパスを明示**: 「auth.ts のバグを修正して」のように具体的に指示するとファイル読み込みが減る
7. **サブエージェントで探索を分離**: 大規模コードベースではコンテキスト節約に効果大
8. **`.gitignore` と `permissions.deny` でノイズ除外**: 秘密情報は permission で保護

---

## 調査ソース

- [How Claude Code works](https://code.claude.com/docs/en/how-claude-code-works) — 公式エージェントループ解説
- [Explore the context window](https://code.claude.com/docs/en/context-window) — 公式コンテキストウィンドウ解説
- [Tools reference](https://code.claude.com/docs/en/tools-reference) — 公式ツール一覧
- [Best Practices for Claude Code](https://code.claude.com/docs/en/best-practices) — 公式ベストプラクティス
- [How Claude remembers your project](https://code.claude.com/docs/en/memory) — 公式メモリドキュメント
- [Using CLAUDE.MD files](https://claude.com/blog/using-claude-md-files) — Anthropic 公式ブログ
- [Claude Code ベストプラクティス](https://zenn.dev/farstep/articles/claude-code-best-practices) — Zenn
- [効果的なCLAUDE.mdの書き方](https://zenn.dev/farstep/articles/how-to-write-a-great-claude-md) — Zenn（3層モデル）
- [ClaudeCodeを最大限に活用するための機能完全ガイド](https://zenn.dev/flinters_blog/articles/711ff6faeca62c) — Zenn
- [Claude Code入門 #2: CLAUDE.mdの書き方と育て方](https://qiita.com/dai_chi/items/8d9d3ac82cbd3c05c883) — Qiita
- [Claude Codeの.env保護、.claudeignoreじゃないです](https://qiita.com/riiiii/items/eb006d3dbab3d9d9034a) — Qiita
- [Claude Coworkを活用するためにディレクトリ構造を意識してみた](https://dev.classmethod.jp/articles/Claude_directory_for_bussiness/) — DevelopersIO
- [CLAUDE.mdとフォルダ構成でClaude Codeの自律性を高める](https://dev.classmethod.jp/articles/claude-code-directory-autonomy/) — DevelopersIO
