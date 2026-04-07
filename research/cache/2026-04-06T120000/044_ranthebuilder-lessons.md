---
url: https://ranthebuilder.cloud/blog/claude-code-best-practices-lessons-from-real-projects
fetched_at: 2026-04-06T12:00:00Z
---

# Claude Code Best Practices: Lessons From Real Projects

Ran Isenberg（AWS Serverless Hero）が3つの実プロジェクトから得た実践的な知見。

## CLAUDE.md の構成
- プロジェクト概要とターゲットユーザー
- 技術スタック・フレームワークバージョン
- ビルド・テスト・デプロイコマンド
- プロジェクト構造ドキュメント
- コーディング規約
- 重要ルール（シークレット禁止、アクセシビリティ等）

ベストプラクティス: 200行以内に収める。必要なスキルは import リンクで参照。

## 核心的教訓
「ドメイン知識がボトルネックであり、ツールではない」

## 3つのプロジェクトからの学び
1. 初期ビルドは速いが、SEO・セキュリティ・パフォーマンスは自動では処理されない
2. BMAD（AI SDLC フレームワーク）での事前設計が後のデバッグを防ぐ
3. Plan mode は小規模プロジェクトに有効だが、難しい質問を投げる必要がある
