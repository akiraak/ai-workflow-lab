---
url: https://www.devopsn.cloud/en/blogs/your-claude-md-is-probably-wrong-7-mistakes-boris-cherny-never-makes
fetched_at: 2026-04-06T12:00:00Z
---

# Your CLAUDE.md Is Probably Wrong: 7 Mistakes Boris Cherny Never Makes

Boris Cherny（Anthropic Staff Engineer、Claude Code 作者）の CLAUDE.md は 2.5k トークン。著者のオリジナルは 15k トークン。

## 7つのアンチパターン

### 1. The Context Stuffing Trap
すべてを CLAUDE.md に詰め込む。NoLiMa ベンチマーク: 32K トークンで 12モデル中11が正確さ50%以下に低下。
解決: 同じ情報を80%少ないトークンで書く。847行→127行に削減。

### 2. The Static Memory Problem
プロジェクトセットアップ時に作成して放置。
解決: PR レビューから学びを追加、月次監査で古い内容を削除。

### 3. The Solo Configuration
CLAUDE.md を個人ファイルとして .gitignore に入れる。
解決: git にコミットして共有。CLAUDE.local.md を個人用に。

### 4. The Plan Mode Skip
Plan Mode を飛ばして即座にコード生成。
解決: 複雑なタスクは Plan Mode をデフォルトに。

### 5. The Missing Verification Loop
コードを書かせて、ざっと確認して出荷。
解決: 検証要件を CLAUDE.md に記載（テスト実行、型チェック等）。

### 6. The Dangerous Permissions Shortcut
--dangerously-skip-permissions の使用。
解決: /permissions で安全なコマンドを事前許可。

### 7. The Format Drift
自動フォーマットなし、一貫性のないスタイル。
解決: PostToolUse フックで自動フォーマット。
