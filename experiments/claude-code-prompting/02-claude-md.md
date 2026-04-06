# 1-2. CLAUDE.md の活用法

## 調査目的

CLAUDE.md ファイルの配置場所、記載すべき内容、階層的な使い分け、記述スタイルの効果を調査し、最適な活用法を明らかにする。

---

## 1. CLAUDE.md に書くべき内容の分類

### CLAUDE.md の位置づけ

CLAUDE.md はセッション開始時にコンテキストウィンドウに読み込まれるマークダウンファイルで、Claude に永続的な指示を与える。システムプロンプトの一部ではなく**ユーザーメッセージとして注入**されるため、強制的な設定ではなく「ガイダンス」として機能する。

> "CLAUDE.md content is delivered as a user message after the system prompt, not as part of the system prompt itself."
> — [How Claude remembers your project](https://code.claude.com/docs/en/memory)

### WHAT / WHY / HOW フレームワーク

コミュニティで広く支持されているフレームワーク（[HumanLayer](https://www.humanlayer.dev/blog/writing-a-good-claude-md)、[izanami.dev](https://izanami.dev/post/47b08b5a-6e1c-4fb0-8342-06b8e627450a)）：

| 軸 | 内容 | 例 |
|----|------|-----|
| **WHAT** | テックスタック、プロジェクト構造、全体像 | 「Next.js 14 + TypeScript + Prisma」 |
| **WHY** | 設計方針、各要素の役割 | 「認証は NextAuth を使用（外部IDP連携のため）」 |
| **HOW** | 検証方法、ビルド・テストコマンド | 「`npm test` でユニットテスト実行」 |

### 書くべき内容

公式ドキュメント（[Best Practices](https://code.claude.com/docs/en/best-practices)）とコミュニティの知見を総合すると：

| カテゴリ | 具体例 |
|---------|--------|
| Claude が推測できないコマンド | `bun run dev`, `npm test -- --watch` |
| デフォルトと異なるコードスタイル | 「2スペースインデント」「ES modules のみ使用」 |
| テスト指示・テストランナー | 「Jest を使用、カバレッジは 80% 以上」 |
| リポジトリ作法（ブランチ命名、PR規約） | 「main ブランチで直接作業」 |
| プロジェクト固有のアーキテクチャ決定 | 「API ハンドラーは `src/api/handlers/` に配置」 |
| 開発環境の罠（必要な環境変数等） | 「`DATABASE_URL` が未設定だとテスト失敗」 |
| 非自明な動作・ゴッチャ | 「`UserService.create()` は内部で非同期キュー発行」 |

### 書くべきでない内容

| 除外すべき内容 | 理由 |
|---------------|------|
| Claude がコードを読めばわかること | コンテキストの無駄遣い |
| 標準的な言語規約（Claude は既知） | 自明な指示は無視されやすい |
| 詳細な API ドキュメント | リンクで十分、全文は不要 |
| 頻繁に変わる情報 | すぐ陳腐化する |
| 長い説明やチュートリアル | 200行制限を圧迫 |
| ファイルごとの説明 | Claude は自分でコードを読める |
| ESLint/Prettier で強制できるスタイル規約 | 「リンターの仕事を LLM にさせるな」([HumanLayer](https://www.humanlayer.dev/blog/writing-a-good-claude-md)) |
| `/init` の自動生成出力そのまま | 自明情報を含む、手動精査が必須 |

### 判断基準

> **「この行を削除したら、Claude が間違いを犯すか？」** — 答えが No なら削除候補。
> — [効果的なCLAUDE.mdの書き方](https://zenn.dev/farstep/articles/how-to-write-a-great-claude-md)

---

## 2. ディレクトリ別 CLAUDE.md による階層的な指示

### 配置場所とスコープ

公式ドキュメント（[Memory](https://code.claude.com/docs/en/memory)）による配置場所の一覧：

| スコープ | 配置場所 | 用途 | 共有範囲 |
|---------|---------|------|---------|
| **管理ポリシー** | OS レベルパス※ | 組織全体の指示 | 全ユーザー |
| **プロジェクト** | `./CLAUDE.md` or `./.claude/CLAUDE.md` | チーム共有指示 | チーム（VCS経由） |
| **ユーザー** | `~/.claude/CLAUDE.md` | 個人の全プロジェクト共通設定 | 自分のみ |
| **ローカル** | `./CLAUDE.local.md` | 個人のプロジェクト固有設定 | 自分のみ |

※ Linux: `/etc/claude-code/CLAUDE.md`, macOS: `/Library/Application Support/ClaudeCode/CLAUDE.md`

### 読み込みの仕組み

1. **起動時**: カレントディレクトリから**ディレクトリツリーを上方に走査**し、各ディレクトリの `CLAUDE.md` と `CLAUDE.local.md` を収集
2. **連結**: 発見された全ファイルは**連結**される（上書きではない）。各ディレクトリ内では `CLAUDE.local.md` が `CLAUDE.md` の後に追加される
3. **サブディレクトリ**: カレントディレクトリ配下の `CLAUDE.md` は**オンデマンド**で読み込み（Claude がそのディレクトリのファイルを読む時に初めて読み込まれる）
4. **HTML コメント**: `<!-- ... -->` はコンテキスト注入前にストリップされる（コードブロック内は保持）

### 推奨ディレクトリ構成

```
project/
├── CLAUDE.md                    # メイン（チーム共有、全セッション読み込み）
├── CLAUDE.local.md              # 個人設定（.gitignore 済み）
├── .claude/
│   ├── CLAUDE.md                # プロジェクト指示（./CLAUDE.md の代替配置）
│   └── rules/                   # トピック別のモジュラールール
│       ├── code-style.md        # コードスタイル
│       ├── testing.md           # テスト規約
│       ├── security.md          # セキュリティ要件
│       └── frontend/            # サブディレクトリで整理可
│           └── react.md
├── docs/                        # 詳細ドキュメント（@参照先）
│   ├── architecture.md
│   └── git-instructions.md
└── src/
    └── api/
        └── CLAUDE.md            # サブディレクトリ固有（オンデマンド読み込み）
```

### `.claude/rules/` によるルール分割

大規模プロジェクトでは `.claude/rules/` に分割してモジュール化する：

- 各ファイルは**1トピック1ファイル**
- `paths` フィールドのないルール → 起動時に無条件読み込み
- `paths` フィールドありのルール → 一致するファイル操作時にのみ読み込み

```markdown
---
paths:
  - "src/api/**/*.ts"
---

# API 開発ルール
- すべてのエンドポイントに入力検証を含める
- 標準エラー応答形式を使用する
```

グロブパターンの例：

| パターン | 一致対象 |
|---------|---------|
| `**/*.ts` | 全ディレクトリの TypeScript ファイル |
| `src/**/*` | src/ 以下の全ファイル |
| `src/components/*.tsx` | 特定ディレクトリの React コンポーネント |
| `**/*.{ts,tsx}` | ブレース展開で複数拡張子 |

### ファイル分割の3層モデル

コミュニティで提唱されている段階的な分割モデル（[zenn.dev/farstep](https://zenn.dev/farstep/articles/how-to-write-a-great-claude-md)）：

| 層 | 配置先 | 読み込み | 用途 |
|----|--------|---------|------|
| **Layer 1** | `CLAUDE.md` | 全セッション自動 | 普遍的なルール・概要 |
| **Layer 2** | `.claude/rules/` | 起動時 or パスマッチ時 | パス限定の規約、@インポート先 |
| **Layer 3** | `.claude/skills/`, `.claude/agents/` | オンデマンド | タスク固有の知識、調査用サブエージェント |

---

## 3. `~/.claude/CLAUDE.md`（グローバル設定）との使い分け

### 3層のスコープ

| 層 | ファイル | 書くべき内容 | 例 |
|----|---------|-------------|-----|
| **グローバル** | `~/.claude/CLAUDE.md` | 全プロジェクト共通の個人設定 | コードスタイルの好み、個人的なツールショートカット |
| **プロジェクト** | `./CLAUDE.md` | チーム共有のプロジェクト標準 | アーキテクチャ、コーディング規約、ワークフロー |
| **ローカル** | `./CLAUDE.local.md` | 個人のプロジェクト固有設定 | サンドボックスURL、テストデータ |

### 使い分けの指針

**グローバル (`~/.claude/CLAUDE.md`) に書くもの**:
- 全プロジェクトで適用したい個人の好み（例: 「コミットメッセージは日本語で書く」）
- 個人的なツール設定（例: 「エディタは VS Code を使用」）
- 自分の作業スタイル（例: 「テスト駆動開発を好む」）

**プロジェクト (`./CLAUDE.md`) に書くもの**:
- チーム全員に適用すべきルール
- ビルド・テスト・デプロイのコマンド
- プロジェクト固有のアーキテクチャ決定
- バージョン管理に含めてチームと共有

**ローカル (`./CLAUDE.local.md`) に書くもの**:
- `.gitignore` に追加して個人だけが使う
- ローカル環境のURL、テストデータ
- プロジェクト CLAUDE.md への個人的な補足

### ユーザーレベルのルール (`~/.claude/rules/`)

`~/.claude/rules/` に配置した `.md` ファイルはマシン上の全プロジェクトに適用される。プロジェクトルールの前に読み込まれるため、**プロジェクトルールの方が優先度が高い**。

```
~/.claude/rules/
├── preferences.md    # 個人的なコーディングの好み
└── workflows.md      # 好みのワークフロー
```

### `@` インポートによるファイル間連携

CLAUDE.md から他のファイルをインポートして情報を参照できる：

```markdown
See @README.md for project overview and @package.json for npm commands.

# 追加の指示
- git workflow: @docs/git-instructions.md
- 個人設定: @~/.claude/my-project-instructions.md
```

- 相対パス・絶対パスいずれも可
- 再帰インポートは最大 5 ホップ
- 初回は承認ダイアログが表示される

### AGENTS.md との共存

他のコーディングエージェントが `AGENTS.md` を使う場合、CLAUDE.md からインポートして共存できる：

```markdown
@AGENTS.md

## Claude Code 固有の指示
- `src/billing/` の変更にはプランモードを使用
```

---

## 4. 記述スタイルの効果比較

### 公式推奨: マークダウン構造化

> "Use markdown headers and bullets to group related instructions. Claude scans structure the same way readers do: organized sections are easier to follow than dense paragraphs."
> — [How Claude remembers your project](https://code.claude.com/docs/en/memory)

### 箇条書き vs 文章

| 形式 | 効果 | 向いている場面 |
|------|------|---------------|
| **箇条書き** | スキャンしやすく、遵守率が高い | コマンド、ルール、DO/DON'T |
| **文章** | 背景・理由を伝えやすい | 設計方針の説明 |
| **テーブル** | 対比・分類が明確 | 命名規則、正解/不正解の対比 |

コミュニティの知見（[izanami.dev](https://izanami.dev/post/47b08b5a-6e1c-4fb0-8342-06b8e627450a)）によると、**長い文章の塊は読み飛ばされやすい**ため、箇条書き形式が推奨される。

### 事実形式 vs 命令形式

| 形式 | 例 | 効果 |
|------|-----|------|
| **事実形式** | 「このプロジェクトでは Bun を使っている」 | 無視されにくい |
| **命令形式** | 「必ず Bun を使ってください」 | 強い指示だが無視されるリスクもある |

事実を述べる形式の方が、コンテキスト注入時に「関連性がない」と判断されにくい傾向がある（[izanami.dev](https://izanami.dev/post/47b08b5a-6e1c-4fb0-8342-06b8e627450a)）。

### 強調の効果

> "You can tune instructions by adding emphasis (e.g., 'IMPORTANT' or 'YOU MUST') to improve adherence."
> — [Best Practices](https://code.claude.com/docs/en/best-practices)

特に重要なルールには `IMPORTANT` や `YOU MUST` を付けると遵守率が上がる。ただし多用すると効果が薄れるため、本当に重要な項目に限定する。

### 具体性のレベル

| 悪い例 | 良い例 |
|--------|--------|
| 「コードを適切にフォーマットする」 | 「2スペースインデントを使用する」 |
| 「変更をテストする」 | 「コミット前に `npm test` を実行する」 |
| 「ファイルを整理しておく」 | 「API ハンドラーは `src/api/handlers/` に配置する」 |

**原則**: 検証可能な具体性を持たせる。

### DO/DON'T の書き方

否定のみの指示は避け、**代替手段を必ず併記**する（[zenn.dev/japan](https://zenn.dev/japan/articles/9e60a2058ff799)）：

```markdown
# 悪い例
- `any` 型を使わないこと

# 良い例
- `any` 型は使わない → `unknown` で受けて型ガードで絞り込む
```

### サイズの目安

| 出典 | 推奨行数 |
|------|---------|
| 公式ドキュメント | 200行以下/ファイル |
| HumanLayer 実例 | 60行未満 |
| コミュニティ合意 | 300行未満が上限 |

**指示数の上限**: フロンティア LLM で約 150-200 の指示を安定的に遵守可能。Claude Code のシステムプロンプトが約 50 の指示を使うため、CLAUDE.md に使える指示数は**残り 100-150 程度**（[HumanLayer](https://www.humanlayer.dev/blog/writing-a-good-claude-md)）。

### 推奨セクション構成

```markdown
# プロジェクト概要（1-2行）

## 技術スタック
- フレームワーク: Next.js 14
- 言語: TypeScript 5.3
- DB: PostgreSQL 16 + Prisma

## 開発コマンド
- `npm run dev` — 開発サーバー起動
- `npm test` — テスト実行
- `npm run build` — プロダクションビルド

## コードスタイル（デフォルトと異なるもののみ）
- ES modules (import/export) を使用、CommonJS (require) は不可
- インポートは destructure する

## アーキテクチャ
- API ハンドラー: `src/api/handlers/`
- ビジネスロジック: `src/services/`
- データ層: `src/repositories/`

## 注意事項
- `UserService.create()` は内部で非同期ジョブを発行する
- テスト時は `DATABASE_URL` が必要
```

### 段階的開示（Progressive Disclosure）

メインの CLAUDE.md はコンパクトに保ち、詳細は別ファイルに分離してポインタで参照する（[HumanLayer](https://www.humanlayer.dev/blog/writing-a-good-claude-md)）：

```markdown
# 詳細ドキュメント
- アーキテクチャ詳細: @docs/architecture.md
- テスト戦略: @docs/testing-strategy.md
- DB スキーマ: @docs/database-schema.md
```

「コピーよりポインタを優先する」— Claude は必要な時だけ参照先を読みに行くため、不要な情報でコンテキストを汚染しない。

### メンテナンスの重要性

> "Treat CLAUDE.md like code: review it when things go wrong, prune it regularly, and test changes by observing whether Claude's behavior actually shifts."
> — [Best Practices](https://code.claude.com/docs/en/best-practices)

- 数週間に一度、`/memory` で CLAUDE.md を見直す
- Claude が指示なしでも正しく行える項目は削除
- 矛盾する指示を探して解消
- 古くなった指示を除去

---

## 総合的なベストプラクティス

### CLAUDE.md 運用の原則

1. **簡潔さ最優先**: 200行以下、各行が必要不可欠であること
2. **具体的で検証可能**: 「きれいに書く」ではなく「2スペースインデント」
3. **事実形式で記述**: 命令形式より事実形式の方が無視されにくい
4. **段階的開示**: メインは概要、詳細は @参照で分離
5. **定期的な剪定**: コードと同様にレビュー・メンテナンスする
6. **リンターに任せる**: 自動ツールで強制できるルールは CLAUDE.md に書かない
7. **理由を添える**: DO/DON'T には「なぜか」と「代替手段」を併記

### コンテキスト注入に関する注意

CLAUDE.md はコンテキストに注入される際、「this context may or may not be relevant to your tasks」というシステム注釈が付加される。タスクに無関係な内容が多いと全体が「無関係」と判断されるリスクがあるため、**普遍的に適用できる内容のみ**を記載することが重要。

### /init の活用と限界

`/init` コマンドはコードベースを分析して CLAUDE.md を自動生成するが、出力をそのまま使うのは推奨されない。自動生成は出発点として使い、手動で精査・剪定してから運用する。

---

## 調査ソース

- [How Claude remembers your project](https://code.claude.com/docs/en/memory) — 公式 Memory ドキュメント
- [Claude があなたのプロジェクトを記憶する方法](https://code.claude.com/docs/ja/memory) — 公式 Memory ドキュメント（日本語版）
- [Best Practices for Claude Code](https://code.claude.com/docs/en/best-practices) — 公式ベストプラクティス
- [How to Write a Good CLAUDE.md File](https://www.builder.io/blog/claude-md-guide) — Builder.io のガイド
- [Writing a good CLAUDE.md](https://www.humanlayer.dev/blog/writing-a-good-claude-md) — HumanLayer のガイド（WHAT/WHY/HOW フレームワーク、指示数の上限）
- [CLAUDE.md や AGENTS.md のベストプラクティスな書き方](https://izanami.dev/post/47b08b5a-6e1c-4fb0-8342-06b8e627450a) — izanami.dev（記述スタイル比較、Progressive Disclosure）
- [Claude.md に本当に書くべきこと](https://zenn.dev/japan/articles/9e60a2058ff799) — zenn.dev（良い例・悪い例の徹底解説）
- [効果的なCLAUDE.mdの書き方](https://zenn.dev/farstep/articles/how-to-write-a-great-claude-md) — zenn.dev（3層モデル、判断基準）
