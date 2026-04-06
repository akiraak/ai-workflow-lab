---
url: https://smartscope.blog/en/generative-ai/claude/claude-code-prompting-official-guidelines-2025/
fetched_at: 2026-04-05
---

# Claude Code Prompting Guide 2025 - 10 Essential Practical Techniques

## 4段階ワークフロー
- Phase 1 (Explore): コードベース理解に集中
- Phase 2 (Plan): 実装方針を設計
- Phase 3 (Implement): 実際の変更を実行
- Phase 4 (Verify): テスト・レビュー・コミット

## 推奨パターン
- 制約を明確に列挙し、背景情報を先に提供
- CLIツール活用（gh issue listなど）

## 避けるべき5つの反パターン
1. 混合タスク回避 - 関連性のない複数タスクを1セッションに詰め込まない
2. コンテキスト汚染対策 - 2回の修正で解決しない場合は /clear
3. CLAUDE.md簡潔化 - 3〜5項目に限定
4. 検証統合 - テスト実行も同時に依頼
5. 探索範囲制限 - スコープを明確に定義
