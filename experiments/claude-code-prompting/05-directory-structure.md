# 1-5. Claude Code に最適なディレクトリ構成

## 調査目的

Claude Code がプロジェクト構造をどのように認識・探索するか、CLAUDE.md の配置階層の効果、命名規則の影響、モノレポ vs 単一プロジェクトでの最適構成を調査し、効果的なディレクトリ設計指針を明らかにする。

---

## 1. Claude Code がプロジェクト構造を認識・探索する仕組み

### 主要な探索ツール

| ツール | 役割 | コンテキスト消費 |
|--------|------|----------------|
| **Glob** | パターンマッチングによるファイル検索（`**/*.ts` 等） | 軽い（パスのみ返す） |
| **Grep** | 正規表現によるコンテンツ検索（ripgrep ベース） | 軽い（マッチ行のみ） |
| **Read** | ファイル内容の読み取り | **重い**（全内容を読み込み） |
| **Bash** | シェルコマンド実行 | コマンドによる |
| **Explore (subagent)** | 別コンテキストでの読み取り専用探索 | メインに影響なし |

> "Glob and Grep are lightweight — they return file paths or matched lines without loading entire files. Read loads file contents, which is necessary for understanding code but consumes more context."

> "Start with the most specific search possible to avoid overwhelming results. Use file type filters (type: 'ts') to narrow scope. Leverage Glob's modification-time sorting to find recently changed files first."

### Glob の特性

- `**/*.ts`, `src/components/*.tsx` のようなパターンで検索
- 結果は**更新日時順**でソート — 最近変更されたファイルが優先的に発見される
- ファイル拡張子とディレクトリ構造が一貫しているほど探索精度が高い

### 起動時にアクセス可能なもの

- プロジェクトのファイルとサブディレクトリ
- ターミナル（ビルドツール、git、パッケージマネージャー等）
- Git の状態（ブランチ、未コミットの変更、最近のコミット履歴）
- CLAUDE.md ファイル
- Auto memory（MEMORY.md の先頭200行 or 25KB）

---

## 2. CLAUDE.md の配置階層による効果の違い

### 配置可能な場所と優先順位

| 優先度 | スコープ | 場所 | 共有範囲 |
|--------|---------|------|---------|
| 1（最高） | 管理ポリシー | `/etc/claude-code/CLAUDE.md` (Linux) | 全ユーザー |
| 2 | プロジェクト | `./CLAUDE.md` or `./.claude/CLAUDE.md` | Git 経由でチーム |
| 3 | ユーザー | `~/.claude/CLAUDE.md` | 自分のみ |
| 4 | ローカル | `./CLAUDE.local.md` | 自分のみ |

### 階層的読み込みメカニズム

**起動時（上方向への探索）:**

> "Claude Code reads CLAUDE.md files by walking up the directory tree from your current working directory, checking each directory along the way for CLAUDE.md and CLAUDE.local.md files."
> — [Memory](https://code.claude.com/docs/en/memory)

`foo/bar/` で起動すると: `foo/bar/CLAUDE.md` → `foo/CLAUDE.md` → ルートの `CLAUDE.md` の順でロード。

**サブディレクトリ（遅延読み込み / Lazy-Load）:**

> "Claude also discovers CLAUDE.md and CLAUDE.local.md files in subdirectories under your current working directory. Instead of loading them at launch, they are included when Claude reads files in those subdirectories."

例えば `src/feature/CLAUDE.md` は Claude が `src/feature/` 内のファイルを読んだ時に初めてロードされる。

**連結方式:**

> "All discovered files are concatenated into context rather than overriding each other. Within each directory, CLAUDE.local.md is appended after CLAUDE.md, so when instructions conflict, your personal notes are the last thing Claude reads at that level."

ファイルは上書きではなく**連結**される。競合する指示がある場合は、より具体的（下層）な指示が優先される。

### @import 構文

CLAUDE.md から別ファイルをインポート可能。最大5階層の再帰インポートに対応：

```markdown
See @README.md for project overview and @package.json for available npm commands.

# 追加の指示
- git workflow: @docs/git-instructions.md
```

> "CLAUDE.md files can import additional files using @path/to/import syntax. Imported files are expanded and loaded into context at launch alongside the CLAUDE.md that references them."

---

## 3. ファイル・ディレクトリの命名規則が探索精度に与える影響

### 直接的な影響

- **規則的で予測可能な命名**が探索効率に大きく影響
- Glob はパターンマッチング、Grep はファイルタイプフィルタ（`type: "ts"` 等）をサポート
- 標準的な拡張子を使うことで効率的にフィルタリングできる

### CLAUDE.md に記載すべき命名規則

> "Specificity: write instructions that are concrete enough to verify. For example: 'API handlers live in src/api/handlers/' instead of 'Keep files organized'"
> — [Best Practices](https://code.claude.com/docs/en/best-practices)

| 悪い例 | 良い例 |
|--------|--------|
| 「ファイルを整理しておく」 | 「API ハンドラーは `src/api/handlers/` に配置する」 |
| 「テストを書く」 | 「テストは `*.test.ts` サフィックスで `tests/` に配置」 |

> "ディレクトリ構成では、どのパスにどんな用途を持ったファイルを、どんな命名規則で作るのかをまとめ、用途の部分はある程度具体的に書く"
> — [Zenn: farstep](https://zenn.dev/farstep/articles/claude-code-best-practices)

### 実践的な推奨事項

- ディレクトリ名は用途を明確に（`src/auth/`, `src/payments/`, `tests/unit/`）
- テストファイルは一貫したサフィックス（`*.test.ts`, `*.spec.ts`）
- コンポーネントは `PascalCase.tsx`、ユーティリティは `camelCase.ts` 等、言語の慣例に従う
- Skills の `name` は lowercase + hyphens のみ（`fix-issue`, `deploy-staging`）

---

## 4. モノレポ vs 単一プロジェクトでの最適構成

### モノレポでの推奨構成

```
monorepo/
├── CLAUDE.md                  # 全体共通ルール（コーディング規約、Git運用）
├── .claude/
│   ├── settings.json          # チーム共有設定
│   └── rules/
│       ├── code-style.md      # 全体のコードスタイル
│       └── testing.md         # テスト方針
├── packages/
│   ├── frontend/
│   │   └── CLAUDE.md          # フロントエンド固有（Next.js, Tailwind等）
│   ├── backend/
│   │   └── CLAUDE.md          # バックエンド固有（Prisma, Express等）
│   └── shared/
│       └── CLAUDE.md          # 共有ライブラリのルール
```

### Lazy-Load による効率化

> "frontend の作業をしている間は backend の CLAUDE.md は読み込まれないので、不要な指示でコンテキストが圧迫されない"
> — [Zenn: caphtech](https://zenn.dev/caphtech/articles/claude-code-memory-guide)

### claudeMdExcludes 設定

大規模モノレポで他チームの CLAUDE.md を除外：

```json
{
  "claudeMdExcludes": [
    "**/other-team/CLAUDE.md",
    "/home/user/monorepo/other-team/.claude/rules/**"
  ]
}
```

> "In large monorepos, ancestor CLAUDE.md files may contain instructions that aren't relevant to your work. The claudeMdExcludes setting lets you skip specific files by path or glob pattern."
> — [Settings](https://code.claude.com/docs/en/settings)

### 単一プロジェクトの場合

ルートの CLAUDE.md と、必要に応じて `.claude/rules/` でモジュール化するだけで十分。複雑な階層は不要。

### 共通ルールの共有

`.claude/rules/` はシンボリックリンクをサポート：

```bash
ln -s ~/shared-claude-rules .claude/rules/shared
```

---

## 5. 設定ファイル・ドキュメント・テストの配置と認識しやすさ

### コンテキストウィンドウが最重要リソース

> "Most best practices are based on one constraint: Claude's context window fills up fast, and performance degrades as it fills."
> — [Best Practices](https://code.claude.com/docs/en/best-practices)

この制約がディレクトリ設計の根本原則。すべては「いかにコンテキストを効率的に使うか」に帰結する。

### 推奨されるプロジェクト構成

```
project/
├── CLAUDE.md                   # メインの指示（200行以内）
├── CLAUDE.local.md             # 個人設定（.gitignore 登録）
├── .claude/
│   ├── settings.json           # 権限・フック設定
│   ├── settings.local.json     # 個人権限設定
│   ├── rules/
│   │   ├── code-style.md       # パス固有ルール可能
│   │   ├── testing.md
│   │   └── security.md
│   ├── skills/
│   │   └── fix-issue/SKILL.md  # 再利用可能なワークフロー
│   └── agents/
│       └── security-reviewer.md
├── src/                        # ソースコード
├── tests/                      # テスト
├── docs/                       # ドキュメント（@import で参照）
└── scripts/                    # ビルドスクリプト
```

### 段階的情報開示の原則

> "CLAUDE.mdは概要のみ記載。詳細情報（DBスキーマ、API、ドメインルール）は別ファイル化。推奨パス: docs/schema.md, docs/api.md, docs/domain-rules.md"
> — [Zenn: imohuke](https://zenn.dev/imohuke/articles/claude-code-best-practices-2026)

### Skills vs CLAUDE.md の使い分け

> "CLAUDE.md is loaded every session, so only include things that apply broadly. For domain knowledge or workflows that are only relevant sometimes, use skills instead. Claude loads them on demand without bloating every conversation."
> — [Best Practices](https://code.claude.com/docs/en/best-practices)

### CLAUDE.md に含めるべきもの / 含めるべきでないもの

| 含めるべき | 含めるべきでない |
|-----------|----------------|
| Claude が推測できない Bash コマンド | ファイルごとのコードベース説明 |
| デフォルトと異なるコードスタイル | コードを読めばわかること |
| テスト指示・テストランナー | 標準的な言語規約 |
| プロジェクト固有のアーキテクチャ決定 | 長い説明やチュートリアル |

---

## 6. .claudeignore と permissions.deny

### .gitignore の影響

Claude Code は `.gitignore` に記載されたファイルを自動的に尊重し、探索から除外する。

### permissions.deny（推奨）

```json
{
  "permissions": {
    "deny": [
      "Read(./.env)",
      "Read(./.env.*)",
      "Read(./secrets/**)",
      "Read(./build)"
    ]
  }
}
```

> "This replaces the deprecated ignorePatterns configuration. Files matching these patterns are excluded from file discovery and search results."
> — [Settings](https://code.claude.com/docs/en/settings)

### 除外すべきファイル / ディレクトリ

| 対象 | 理由 |
|------|------|
| `node_modules/` | .gitignore で通常除外済み |
| `.next/`, `dist/`, `build/` | ビルド出力 |
| `.env`, `.env.*` | 機密情報（permissions.deny 推奨） |
| `secrets/`, `credentials.json` | 認証情報 |
| 大きなバイナリ、ログファイル | コンテキスト汚染 |

---

## 総合的なベストプラクティス

### ディレクトリ設計の原則

1. **CLAUDE.md は200行以内**: 長すぎると指示が無視される
2. **共通ルールは浅く、専門ルールは深く**: Lazy-Load を活用
3. **詳細は @import で外出し**: CLAUDE.md 自体はインデックスとして機能
4. **重要なルールは CLAUDE.md の冒頭に**: LLM は先頭と末尾を強く重み付け
5. **具体的に書く**: 「Keep files organized」→「API handlers live in src/api/handlers/」
6. **If X, then Y 形式**: 「schema.prisma 変更時は pnpm build:schema を実行」
7. **機密ファイルは permissions.deny で保護**
8. **モノレポでは claudeMdExcludes と Lazy-Load を活用**
9. **Skills でコンテキスト管理**: 毎回不要な情報は Skills に移す
10. **CLAUDE.md は生きたドキュメント**: 継続的にメンテナンスする

> "一番大切なのは「削ること」だ。最初は少なく書いて、必要に応じて追加するのが最もコスト効率の良い"
> — [Zenn: biki](https://zenn.dev/biki/articles/claude-code-claude-md-guide)

---

## 調査ソース

- [Best Practices for Claude Code](https://code.claude.com/docs/en/best-practices) — 公式ベストプラクティス
- [How Claude remembers your project](https://code.claude.com/docs/en/memory) — 公式 CLAUDE.md 配置・読み込み順序
- [Claude Code settings](https://code.claude.com/docs/en/settings) — 公式設定ドキュメント
- [How Claude Code works](https://code.claude.com/docs/en/how-claude-code-works) — 公式エージェントループ解説
- [Claude Code ベストプラクティス](https://zenn.dev/farstep/articles/claude-code-best-practices) — Zenn（ディレクトリ構成の記述）
- [Claude Code メモリ運用の教科書](https://zenn.dev/caphtech/articles/claude-code-memory-guide) — Zenn（Lazy-Load 解説）
- [Claude Code の CLAUDE.md は階層的に読み込まれる](https://zenn.dev/purpom/articles/claude-md-hierarchy) — Zenn（階層読み込みの詳細）
- [CLAUDE.mdを制する者がClaude Codeを制す](https://zenn.dev/biki/articles/claude-code-claude-md-guide) — Zenn（削ることの重要性）
- [結局CLAUDE.mdはどこに置けばいいの？](https://zenn.dev/76hata/articles/6744b16d2241ad) — Zenn（配置場所の図解）
- [CLAUDE.md運用のベストプラクティス：7つの原則](https://zenn.dev/imohuke/articles/claude-code-best-practices-2026) — Zenn
- [Claude Code in Monorepos](https://dev.to/myougatheaxo/claude-code-in-monorepos-hierarchical-claudemd-and-package-scoped-instructions-1il9) — DEV Community
- [Claude Code Tool Search Explained](https://www.aifreeapi.com/en/posts/claude-code-tool-search) — Glob/Grep/Read ツール解説
