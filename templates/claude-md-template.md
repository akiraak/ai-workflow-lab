# CLAUDE.md テンプレート

> Phase 1〜3 の調査に基づく推奨テンプレート。Phase 4B の実験で検証予定。

## 使い方

1. このテンプレートをプロジェクトルートに `CLAUDE.md` としてコピーする
2. `{{...}}` のプレースホルダーを自分のプロジェクトに合わせて書き換える
3. 不要なセクションは削除する（30〜100 行が目安）
4. チームで共有する場合は Git にコミットする

## 記述ルール

- **事実形式で書く**: "Bun を使う" > "Bun を使ってください"（事実形式のほうが遵守率が高い）
- **肯定形で書く**: "logger を使う" > "console.log を使わない"（否定形は違反率が上がる）
- **Claude が推測できない情報だけ書く**: コードから読み取れる内容は書かない
- **リンターが検出できるルールは委譲する**: Hooks や CI で強制するほうが確実
- **1 行 = 1 指示**: 判断に迷ったら「この行がなければ Claude は失敗するか？」で取捨選択

## テンプレート本体

以下をコピーして使用してください。

---

```markdown
# CLAUDE.md

{{プロジェクト名}}: {{1 行で概要を説明}}

## 開発コマンド

- ビルド: `{{build command}}`
- テスト: `{{test command}}`（全体）/ `{{single test command}}` {{file}}（単体）
- リント: `{{lint command}}`
- 開発サーバー: `{{dev command}}`

## アーキテクチャ

- API ハンドラー: `{{path}}`
- ビジネスロジック: `{{path}}`
- データアクセス: `{{path}}`
- テスト: `{{path}}`
- 設定: `{{path}}`

## コードスタイル

- 言語: {{language}} {{version}}
- {{フレームワーク固有の規約（例: named export を使う、Server Components がデフォルト）}}
- {{命名規則やフォーマットで非標準のもの}}
- エラー処理: {{プロジェクトのエラー処理方針}}

## Things That Will Bite You

- {{踏みやすい罠 1: 例「TypeScript strict モードで暗黙の any はビルドエラーになる」}}
- {{踏みやすい罠 2: 例「テスト DB は自動リセットされないので、テスト前に seed を実行する」}}
- {{踏みやすい罠 3}}

## 検証チェックリスト

変更後は以下を実行する:

1. `{{lint command}}` — リントが通る
2. `{{test command}}` — 全テストが通る
3. `{{type check command}}` — 型エラーがない

## Git 規約

- ブランチ: {{ブランチ戦略の概要}}
- コミットメッセージ: {{形式の説明（例: Conventional Commits）}}
```

---

## カスタマイズの指針

### 行数の目安

| 規模 | 推奨行数 | 説明 |
|------|----------|------|
| 個人プロジェクト | 30〜50 行 | コマンドとスタイルだけで十分 |
| チーム小規模 | 50〜100 行 | アーキテクチャと罠セクションを追加 |
| チーム大規模 | 100 行 + `.claude/rules/` | メインは 100 行以内、詳細はルールファイルに分離 |

> **上限の目安**: 200 行を超えると遵守率が低下する。150 行を超えたら `.claude/rules/` への分離を検討する。

### 段階的開示の構成

```
CLAUDE.md                    ← 全体方針（30〜100 行）
.claude/rules/
  testing.md                 ← テスト固有ルール（paths: "**/*.test.*"）
  api.md                     ← API 固有ルール（paths: "src/api/**"）
  frontend.md                ← フロントエンド固有ルール（paths: "src/components/**"）
```

各ルールファイルに `paths:` を指定すると、該当ファイル操作時のみ読み込まれる。

### 外部ドキュメント参照

詳細なドキュメントは `@` 参照で CLAUDE.md の肥大化を防ぐ:

```markdown
詳細は @docs/architecture.md を参照
```

## 根拠となる調査

| 知見 | 出典 |
|------|------|
| 事実形式 > 命令形式 | Phase 1: 02-claude-md |
| 肯定形 > 否定形（違反率 ≈50% 減） | Phase 3: 14-anti-patterns |
| 200 行超で遵守率低下 | Phase 1: 02-claude-md, Phase 3: 14-anti-patterns |
| WHAT/WHY/HOW フレームワーク | Phase 1: 02-claude-md |
| Things That Will Bite You パターン | Phase 3: 15-claude-md-examples |
| 段階的開示（.claude/rules/） | Phase 3: 15-claude-md-examples |
| 検証コマンドの明記が最高 ROI | Phase 3: 13-best-practices |
