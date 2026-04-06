# 調査結果を Web で閲覧できるようにする

## 目的

`experiments/` や `research/cache/` にある Markdown 形式の調査結果を、ブラウザで見やすく閲覧できるようにする。

## 背景

現在、調査結果は Markdown ファイルとしてリポジトリに蓄積されている。
GitHub 上でも閲覧可能だが、ナビゲーションや一覧性に欠ける。
ローカルまたは公開 Web サイトとして整形表示できると、振り返りや共有がしやすくなる。

---

## 採用: VitePress

- **概要**: Vue ベースの静的サイトジェネレータ
- **メリット**: 高速、モダンな UI、Markdown 拡張が豊富、ローカル検索内蔵
- **構成**: プロジェクトルートを VitePress のソースディレクトリとして使用

---

## 実装結果

### 構成

```
ai-workflow-lab/
├── .vitepress/
│   └── config.ts           # VitePress 設定
├── index.md                 # トップページ（Hero レイアウト）
├── package.json             # npm scripts (docs:dev, docs:build, docs:preview)
├── experiments/             # 調査結果（そのまま VitePress で表示）
│   └── claude-code-prompting/
│       ├── index.md         # セクショントップ
│       ├── 01-prompt-characteristics.md
│       └── 02-claude-md.md
└── research/
    ├── index.md             # Web キャッシュ一覧
    └── cache/
        ├── 2026-04-05T000000/
        │   └── index.md     # セッション概要（個別キャッシュは除外）
        └── 2026-04-06T000000/
            └── index.md
```

### コマンド

- `npm run docs:dev` — ローカル開発サーバー
- `npm run docs:build` — 静的ファイル生成
- `npm run docs:preview` — ビルド結果プレビュー

### 設計判断

- **プロジェクトルート = ソースディレクトリ**: `docs/` からのシンボリックリンクは VitePress のデッドリンクチェックと相性が悪いため、プロジェクトルートを直接使用
- **srcExclude**: README.md, TODO.md, DONE.md, CLAUDE.md, plans/, research/cache の個別ファイルを除外
- **research/cache の個別ファイル除外**: Web キャッシュには生 HTML が含まれ Vue パーサーでエラーになるため、インデックスのみ表示

### 今後のオプション

- [ ] GitHub Pages へのデプロイ設定
- [ ] GitHub Actions による自動デプロイ（push 時にビルド・デプロイ）
