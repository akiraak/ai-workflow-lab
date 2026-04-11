# Hooks 実用レシピ集の作成プラン

## Context

現在、hooks に関する情報はリポジトリ内に散在している:
- `experiments/claude-code-prompting/04-slash-commands.md` (lines 185-318): 理論 + 5つの基本パターン（簡潔な JSON のみ）
- `experiments/phase-4b/B6.md`: ESLint/Prettier の実証実験結果
- `guides/verification.md`: テストファイル保護の簡易例

**問題**: 既存の5パターンは骨格のみで、実際にコピペして使えるレベルの詳細さがない。また、カバーするユースケースも限定的。

**目的**: 実務でそのまま使える「Hooks クックブック」を作成し、VitePress サイトに掲載する。

---

## 作成物

### 1. `guides/hooks-cookbook.md` — Hooks 実用レシピ集（新規作成）

以下の構成で 8〜10 のレシピを掲載:

```
# Hooks 実用レシピ集

## はじめに
- Hooks の概要（04-slash-commands.md へのリンクで理論は委譲）
- settings.json の配置場所の早見表
- Command Hook の入出力プロトコル（stdin JSON / exit code）

## レシピ一覧

### 1. ファイル保存時の自動フォーマット（Prettier / ESLint）
- PostToolUse + Write|Edit matcher
- JS/TS 向け・Python(ruff) 向けのバリエーション

### 2. 保護ファイルへの編集ブロック
- PreToolUse でマイグレーション・設定ファイル等を保護
- exit 2 + stderr でブロック理由をフィードバック

### 3. 編集後の自動テスト実行
- PostToolUse で変更ファイルに対応するテストを自動実行
- テスト失敗時に stdout で Claude にフィードバック

### 4. セキュリティ: シークレット検出
- PreToolUse で Write 前にファイル内容をスキャン
- API キー・パスワード等のパターンマッチ

### 5. コミットメッセージ規約の強制
- PreToolUse + Bash matcher で git commit を監視
- Conventional Commits 形式の検証

### 6. compact 後のコンテキスト再注入
- SessionStart + compact matcher
- プロジェクト固有のルールを自動リマインド

### 7. 操作ログの記録（監査証跡）
- PostToolUse で全ツール実行をログファイルに記録
- タイムスタンプ・ツール名・対象ファイル

### 8. デスクトップ / ターミナル通知
- Notification イベントで OS 通知
- Linux (notify-send) / macOS (osascript) / WSL 対応

### 9. prompt 型: タスク完了チェック
- Stop イベントで LLM に完了判定を委任
- チェックリスト未消化時のブロック

### 10. 複数フックの組み合わせ（実践例）
- フォーマット + リント + テストのパイプライン構成
- B6 実験で実証済みの構成を紹介
```

各レシピの形式:
- **ユースケース**: どんな場面で使うか
- **設定 JSON**: コピペ可能な完全な設定
- **ヘルパースクリプト**: 必要な場合はシェルスクリプト付き
- **動作の仕組み**: stdin/stdout/exit code の流れ
- **カスタマイズのヒント**: matcher やコマンドの変更ポイント

### 2. `.vitepress/config.ts` — サイドバーに「実践ガイド」セクション追加

```ts
{
  text: '実践ガイド',
  items: [
    { text: 'Hooks レシピ集', link: '/guides/hooks-cookbook' },
  ],
},
```

Phase 4B セクションの後に配置。

### 3. `TODO.md` — タスク更新

完了後に DONE.md へ移動。

---

## 対象ファイル

| ファイル | 操作 |
|---------|------|
| `guides/hooks-cookbook.md` | 新規作成 |
| `.vitepress/config.ts` | サイドバー追加 |
| `TODO.md` → `DONE.md` | タスク移動 |

---

## 検証方法

1. `npm run docs:dev` で VitePress 開発サーバーを起動
2. サイドバーに「実践ガイド > Hooks レシピ集」が表示されることを確認
3. ページが正しくレンダリングされ、JSON コードブロックがシンタックスハイライトされることを確認
4. 各レシピの設定 JSON が valid であることを確認
