---
url: https://zenn.dev/farstep/articles/how-to-write-a-great-claude-md
fetched_at: 2026-04-06
---

# 効果的なCLAUDE.mdの書き方 (zenn.dev/farstep)

## 行数の目安
- 公式推奨: 200行以下/ファイル
- 超える場合は Skills や .claude/rules/ に分離

## 構造化の推奨セクション
1. プロジェクト概要（1-2行）
2. コードスタイル（デフォルトと異なるルールのみ）
3. コマンド（ビルド、テスト等）
4. アーキテクチャ（主要ディレクトリ説明）
5. 注意事項（プロジェクト固有のゴッチャ）

## 判断基準
「この行を削除したら、Claudeが間違いを犯すか？」→ No なら削除候補

## ファイル分割の3層構造
- Layer 1: CLAUDE.md（全セッション共通）
- Layer 2: .claude/rules/（パス指定でスコープ限定）、@インポート
- Layer 3: .claude/skills/（オンデマンド）、.claude/agents/（調査タスク）

## アンチパターン
1. 200行超過
2. リンター代替
3. /init出力をそのまま使用
4. 否定のみの指示（代替手段を併記せよ）
5. タスク固有指示をグローバル配置

## コンテキスト制約
- CLAUDE.md は全リクエストに含まれ、サブエージェントにも継承
- 「may or may not be relevant」注釈が付加される
