---
url: https://dev.to/subprime2010/claude-code-custom-slash-commands-build-your-own-deploy-review-test-1ifc
fetched_at: 2026-04-06T06:00:00+09:00
---

# Claude Code Custom Slash Commands: Build Your Own /deploy, /review, /test

Source: DEV Community (検索結果サマリーに基づく)

## カスタムスラッシュコマンドの概要

カスタムスラッシュコマンドは `.claude/commands/` ディレクトリに置くMarkdownファイル。
`/deploy` とタイプすると `.claude/commands/deploy.md` の内容がプロンプトとして実行される。

## /review コマンドの例

`.claude/commands/review.md` を作成:

```markdown
Explain this code to a developer:
- What does this code do at a high level?
- What are the key inputs and outputs?
- What are the non-obvious design decisions and why were they made?
- What could go wrong and how does the code handle it?
- What would a developer need to know before modifying this?
```

## $ARGUMENTS の活用

すべてのカスタムコマンドは `$ARGUMENTS` にアクセス可能。コマンド名の後のテキストが代入される。

使用例:
- `/review src/auth.js` → $ARGUMENTS = "src/auth.js"
- `/review src/api/routes.js` → $ARGUMENTS = "src/api/routes.js"

## スコープ

- プロジェクトスコープ: `.claude/commands/` — そのプロジェクトでのみ表示
- グローバルスコープ: `~/.claude/commands/` — すべてのプロジェクトで表示

## 現在のアプローチ: Skills

`.claude/commands/review.md` と `.claude/skills/review/SKILL.md` は同じ `/review` コマンドを作成し、同じように動作する。既存の `.claude/commands/` ファイルは引き続き動作する。

---

## Related: Claude-Command-Suite (GitHub)

URL: https://github.com/qdhenry/Claude-Command-Suite

構造化されたワークフローを提供するプロフェッショナルなスラッシュコマンド集:
- コードレビュー
- 機能作成
- セキュリティ監査
- アーキテクチャ分析

## Related: awesome-claude-code (GitHub)

URL: https://github.com/hesreallyhim/awesome-claude-code

Skills、hooks、slash commands、agent orchestrators、applications、plugins のキュレーションリスト。
