---
url: https://github.com/shanraisshan/claude-code-best-practice
fetched_at: 2026-04-06T12:00:00Z
---

# Claude Code Best Practices Repository (shanraisshan)

## Core Concepts
- Subagents: 隔離コンテキストで動く自律的アクター
- Commands: ワークフローオーケストレーション用のナレッジテンプレート（.claude/commands/）
- Skills: 段階的開示による設定可能・発見可能な機能（.claude/skills/）
- Workflows: コマンド、エージェント、スキルを組み合わせた協調パターン
- Hooks: エージェントループ外で動くイベント駆動ハンドラ
- MCP Servers: 外部ツール・APIへのプロトコル接続
- Settings: .claude/settings.json の階層的設定システム
- Memory: CLAUDE.md ファイルとルールによる永続コンテキスト

## Hot Features
- Ultraplan: クラウドベース計画
- Auto Mode: バックグラウンド安全分類器
- Agent Teams: 複数エージェント協調
- Code Review: マルチエージェント PR 分析
- Scheduled Tasks: /loop, /schedule

## Development Workflows
10以上のコミュニティプロジェクトからのパターン:
Research → Plan → Execute → Review → Ship
