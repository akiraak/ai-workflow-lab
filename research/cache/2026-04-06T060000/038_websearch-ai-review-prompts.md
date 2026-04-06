---
url: https://graphite.com/guides/effective-prompt-engineering-ai-code-reviews
fetched_at: 2026-04-06T06:00:00+09:00
---

# Effective Prompt Engineering for AI Code Reviews

Source: Graphite (検索結果サマリーに基づく。WebFetch制限によりページ本文は取得不可)

## 要点

効果的なコードレビュープロンプトの構成要素:

1. **役割定義 (Role)**: "You are a senior engineer" などの役割設定
2. **コンテキスト (Context)**: 言語・フレームワーク・制約の明示
3. **具体的指示 (Instructions)**: 何を探すか（バグ、セキュリティ、パフォーマンス）
4. **出力フォーマット (Output format)**: 期待する出力形式の指定
5. **例示 (Examples)**: 良い/悪いパターンの例

## 主要原則

- 曖昧なプロンプトは曖昧なフィードバックにつながる
- レビュー対象を具体的に指定する（アーキテクチャ、ロジック、エラー、セキュリティ、パフォーマンス）
- レビューの深さと期待する出力形式を定義する
- AIがコードのシステム内での位置づけを推測しなくてよいよう、十分なコンテキストを提供する

## プロンプト構造の公式

```
役割 + 範囲 + 重点 + 形式 + 重大度 = 効果的なレビュープロンプト
```

---

## Additional Sources (検索結果サマリーからの統合情報)

### 5ly.co - AI Prompts for Code Review

URL: https://5ly.co/blog/ai-prompts-for-code-review/

レビュー用AIプロンプトのカテゴリ:
- バグ検出プロンプト
- 構造改善プロンプト
- セキュリティ監査プロンプト
- パフォーマンス最適化プロンプト

### Medium - 7 AI Prompts for Code Review and Security Audits

URL: https://medium.com/data-science-collective/youre-using-ai-to-write-code-you-re-not-using-it-to-review-code-728e5ec2576e

7つのプロンプトカテゴリ:
1. 一般的なコードレビュー
2. セキュリティ監査
3. パフォーマンスレビュー
4. テストカバレッジ分析
5. アーキテクチャレビュー
6. エラーハンドリング分析
7. ドキュメント品質

### baz-scm/awesome-reviewers

URL: https://github.com/baz-scm/awesome-reviewers

470以上の専門レビュープロンプトライブラリ。15以上の言語に対応。Next.js、LangChain、FastAPIなど1000以上のOSSプロジェクトの実際のレビューコメントから抽出。
