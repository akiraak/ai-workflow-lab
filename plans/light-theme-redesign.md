# Webデザイン: ダークテーマ → ライトテーマへの変更

## 現状

- VitePress v1.6.4 のデフォルトテーマを使用
- カスタムテーマディレクトリ（`.vitepress/theme/`）は未作成
- `appearance` オプション未指定（デフォルト: auto → OS設定に追従、ダーク/ライト切替可能）
- カスタム CSS は一切なし

## 目標

ダーク寄りのデザインから、明るく見やすいライトテーマベースのデザインに変更する。

## フェーズ

### Phase 1: デザイン候補の作成＆選定

カラーバリエーションを複数作成し、ユーザーが比較・選定する。

- `design-preview.html` をプロジェクトルートに作成（VitePress とは独立したスタンドアロン HTML）
- VitePress の実際のレイアウトをミニチュアで再現し、配色の違いを一覧比較できるようにする
- ユーザーがプレビューで比較し、採用テーマを絞る

### Phase 2: 選定テーマの実装

Phase 1 で選んだテーマを VitePress に反映する。

#### 2-1. カスタムテーマのセットアップ

`.vitepress/theme/index.ts` を作成し、デフォルトテーマを継承 + カスタム CSS を読み込む。

```ts
// .vitepress/theme/index.ts
import DefaultTheme from 'vitepress/theme'
import './custom.css'

export default DefaultTheme
```

#### 2-2. カスタム CSS の作成

`.vitepress/theme/custom.css` を作成し、選定テーマの CSS 変数をオーバーライドする。

主な変更ポイント:

| 項目 | 変更内容 |
|------|----------|
| ブランドカラー | 選定されたアクセント色 |
| 背景色 | 白ベースに微かな色味を足して柔らかく |
| テキスト色 | コントラストを保ちつつ真っ黒でない柔らかい色に |
| サイドバー | 背景色を少し変えて区別しやすく |
| コードブロック | 明るい背景に読みやすいシンタックスハイライト |
| リンク色 | ブランドカラーに合わせて統一 |

#### 2-3. ビルド・確認

```bash
npm run docs:build
```

## 変更対象ファイル

| フェーズ | ファイル | 操作 |
|----------|----------|------|
| Phase 1 | `design-preview.html` | 新規作成（確認後削除可） |
| Phase 2 | `.vitepress/theme/index.ts` | 新規作成 |
| Phase 2 | `.vitepress/theme/custom.css` | 新規作成 |
| Phase 2 | `.vitepress/config.ts` | 必要に応じて調整 |

## リスク・注意点

- `design-preview.html` は選定用の一時ファイル。確定後に削除してよい
- デフォルトテーマの CSS 変数をオーバーライドする形式なので、VitePress アップデート時にも比較的安全
- カスタム CSS は最小限に留め、メンテナンスコストを抑える
