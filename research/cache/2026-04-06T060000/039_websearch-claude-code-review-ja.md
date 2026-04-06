---
url: https://help.apiyi.com/ja/claude-code-code-review-prompts-collection-guide-ja.html
fetched_at: 2026-04-06T06:00:00+09:00
---

# Claude Codeでコードレビューを行うための25の便利なプロンプト

Source: Apiyi.com Blog (検索結果サマリーに基づく。WebFetch制限によりページ本文は取得不可)

## プロンプトの5要素公式

> 役割 + 範囲 + 重点 + 形式 + 重大度 = 効果的なレビュープロンプト

## プロンプトカテゴリ

### セキュリティレビュー
- SQL インジェクション検出
- XSS 脆弱性チェック
- 認証・認可フロー検証
- 機密情報漏洩チェック

### アーキテクチャレビュー
- 設計パターン準拠
- 依存関係分析
- モジュール結合度チェック
- スケーラビリティ評価

### パフォーマンスレビュー
- N+1 クエリ検出
- メモリリーク検出
- 不要な再レンダリング検出
- キャッシュ戦略評価

### コード品質レビュー
- 命名規則チェック
- 重複コード検出
- エラーハンドリング評価
- テストカバレッジ分析

---

## Additional Japanese Sources

### ENECHANGE Developer Blog

URL: https://tech.enechange.co.jp/entry/2025/07/14/144750

Claude Codeで品質の高いコードを書くためのコツ:
- 指示がより正確であるほど、必要な修正が少なくなる
- 探索→計画→実装として調査と実装を分離する
- 環境設定としてCLAUDE.md、権限、MCPを活用する
- 複数セッション（サブエージェント）で調査を委任しコンテキストを節約する

### Qiita - Claude Codeベストプラクティス 7つの鉄則

URL: https://qiita.com/nogataka/items/392934f79e943e8b9228

### Speaker Deck - Claude Codeベストプラクティスまとめ

URL: https://speakerdeck.com/minorun365/claude-codebesutopurakuteisumatome

### note.com - Claude Code Actionでコードレビューを効率化する (REALITY株式会社)

URL: https://note.com/reality_eng/n/n873a4cab65ee
