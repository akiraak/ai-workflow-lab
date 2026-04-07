---
url: https://www.eesel.ai/blog/claude-code-best-practices
fetched_at: 2026-04-06T12:00:00Z
---

# 7 Claude Code Best Practices from Real Projects (2026)

## The Seven Best Practices

### 1. Master the CLAUDE.md File
- プロジェクトの永続的なコンテキストとして機能
- コマンド、コードスタイル、主要ファイル、テスト手順を記載
- プロジェクトルートとサブフォルダに複数配置可能

### 2. Plan Then Execute Workflow
1. 詳細な実装計画を要求
2. コード生成前に明示的に停止
3. 計画を協調的にレビュー・改善
4. コード実行を許可

### 3. Custom Tools and Commands
- `.claude/commands/` にカスタムスラッシュコマンドを作成
- MCP で外部ツール（Puppeteer, Sentry 等）を接続

### 4. Git Workflows for Safety
- 機能/バグ修正ごとに新しいブランチを作成
- 並列開発には Git worktree を活用

### 5. Specific Prompting with Context
- ファイルパスを直接指定
- ドキュメントや issue の URL を提供
- UI 作業にはスクリーンショットを添付
- タスクを明示的に指定

### 6. Context Management via Sub-agents and Resets
- タスク間で /clear を使用
- 複雑なワークフローにはサブエージェントを活用

### 7. Headless Mode and Automation Hooks
- `-p` フラグでヘッドレスモード実行（CI/CD 向け）
- リンターやタイプチェッカーを自動実行するフック設定
