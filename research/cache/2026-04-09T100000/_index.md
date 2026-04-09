---
session: 2026-04-09T100000
topic: "C1: CI/CD 統合パターン / C2: チームワークフロー / C3: コスト最適化 — Claude Code 調査"
---

# Web 調査キャッシュ インデックス

| # | ファイル名 | URL | 概要 |
|---|-----------|-----|------|
| 001 | 001_code-claude-com-github-actions.md | https://code.claude.com/docs/en/github-actions | Claude Code GitHub Actions 公式ドキュメント（セットアップ、設定、ユースケース） |
| 002 | 002_code-claude-com-headless.md | https://code.claude.com/docs/en/headless | ヘッドレスモード（-p フラグ）公式ドキュメント（CLI利用、bare mode、出力形式） |
| 003 | 003_github-claude-code-action-readme.md | https://github.com/anthropics/claude-code-action | claude-code-action リポジトリ README（機能一覧、クイックスタート、ドキュメント構成） |
| 004 | 004_github-claude-code-action-configuration.md | https://github.com/anthropics/claude-code-action/blob/main/docs/configuration.md | 高度な設定（MCP、追加権限、環境変数、カスタムツール、設定ファイル） |
| 005 | 005_github-claude-code-action-solutions.md | https://github.com/anthropics/claude-code-action/blob/main/docs/solutions.md | ソリューション集（PR レビュー、Issue トリアージ、ドキュメント同期、セキュリティレビュー等） |
| 006 | 006_github-claude-code-action-security.md | https://github.com/anthropics/claude-code-action/blob/main/docs/security.md | セキュリティドキュメント（アクセス制御、コミット署名、プロンプトインジェクション対策） |
| 007 | 007_github-claude-code-action-usage.md | https://github.com/anthropics/claude-code-action/blob/main/docs/usage.md | 利用ガイド（入力パラメータ一覧、Structured Outputs、トリガー方法） |
| 008 | 008_code-claude-com-gitlab-cicd.md | https://code.claude.com/docs/en/gitlab-ci-cd | GitLab CI/CD 統合ドキュメント（セットアップ、AWS Bedrock/Vertex AI、設定例） |
| 009 | 009_code-claude-com-security.md | https://code.claude.com/docs/en/security | Claude Code セキュリティ公式ドキュメント（権限体系、プロンプトインジェクション対策） |
| 010 | 010_backslash-security-best-practices.md | https://www.backslash.security/blog/claude-code-security-best-practices | セキュリティベストプラクティス（managed-settings、MCP、権限設定、外部防御） |
| 011 | 011_systemprompt-io-workflow-recipes.md | https://systemprompt.io/guides/claude-code-github-actions | GitHub Actions ワークフローレシピ5選（PR レビュー、Issue→PR、ドキュメント更新等） |
| 040 | 040_code-claude-com-agent-teams.md | https://code.claude.com/docs/en/agent-teams | Agent Teams 公式ドキュメント（マルチセッション連携、タスク管理、ベストプラクティス） |
| 041 | 041_portkey-ai-enterprise-best-practices.md | https://portkey.ai/blog/claude-code-best-practices-for-enterprise-teams/ | エンタープライズチーム向けベストプラクティス（認証管理、予算制御、ガードレール） |
| 042 | 042_hashbuilds-team-collaboration.md | https://www.hashbuilds.com/articles/claude-code-team-collaboration-multi-developer-workflow-setup | チームコラボレーション（プロンプト標準化、コードレビュー、バージョン管理戦略） |
| 043 | 043_claudefast-worktree-guide.md | https://claudefa.st/blog/guide/development/worktree-guide | Git Worktree ガイド（並列セッションの競合回避、CLI 使い方、クリーンアップ） |
| 044 | 044_mindwiredai-creator-workflow.md | https://mindwiredai.com/2026/03/25/claude-code-creator-workflow-claudemd/ | Claude Code 創作者 Boris Cherny のワークフロー（100行 CLAUDE.md、10-15並列セッション） |
| 045 | 045_code-claude-com-code-review.md | https://code.claude.com/docs/en/code-review | Code Review 公式ドキュメント（PR自動レビュー、REVIEW.md、重要度分類） |
| 046 | 046_truefoundry-governance.md | https://www.truefoundry.com/blog/claude-code-governance-building-an-enterprise-usage-policy-from-scratch | ガバナンスポリシー構築ガイド（managed-settings、MCP制限、監査、段階的展開） |
| 047 | 047_substack-30-tips-agent-teams.md | https://getpushtoprod.substack.com/p/30-tips-for-claude-code-agent-teams | Agent Teams 30 Tips（チーム構成、タスク管理、品質ゲート、ベストプラクティス） |
| 048 | 048_smartscope-team-best-practices.md | https://smartscope.blog/en/generative-ai/claude/claude-code-creator-team-workflow-best-practices/ | チーム標準化（CLAUDE.md 階層、品質ゲート3層、チーム規模別最適化） |
| 049 | 049_turing-enterprise-roadmap.md | https://www.turing.com/resources/scaling-ai-powered-development-an-enterprise-roadmap-for-claude-code | エンタープライズロードマップ（SDLC統合、3レーン戦略、トレーサビリティ、成果指標） |
| 050 | 050_news-aakashg-team-os.md | https://www.news.aakashg.com/p/claude-code-team-os | DoorDash PM による Team OS 構築（共有リポ、コンテキスト管理、アナリティクス自律化） |
| 051 | 051_developertoolkit-team-collaboration.md | https://developertoolkit.ai/en/claude-code/tips-tricks/team-collaboration/ | チームコラボレーション Tips 86-95（共有設定、権限ポリシー、オンボーディング、文化構築） |
| 052 | 052_code-claude-com-best-practices.md | https://code.claude.com/docs/en/best-practices | 公式ベストプラクティス（環境設定、CLAUDE.md 書き方、セッション管理、並列化） |
| 053 | 053_ranthebuilder-lessons.md | https://ranthebuilder.cloud/blog/claude-code-best-practices-lessons-from-real-projects/ | 実プロジェクト3件の教訓（BMAD手法、Plan mode使い分け、CLAUDE.md構造） |
| 080 | 080_code-claude-com-costs.md | https://code.claude.com/docs/en/costs | コスト管理公式ドキュメント（トークン追跡、チーム管理、削減戦略） |
| 081 | 081_code-claude-com-model-config.md | https://code.claude.com/docs/en/model-config | モデル設定公式ドキュメント（エイリアス、opusplan、effort レベル） |
| 082 | 082_code-claude-com-fast-mode.md | https://code.claude.com/docs/en/fast-mode | Fast mode 公式ドキュメント（仕組み、料金、使いどころ） |
| 083 | 083_platform-claude-com-pricing.md | https://platform.claude.com/docs/en/about-claude/pricing | API 料金体系公式ドキュメント（全モデル価格、キャッシュ、バッチ割引） |
| 084 | 084_platform-claude-com-choosing-model.md | https://platform.claude.com/docs/en/about-claude/models/choosing-a-model | モデル選択ガイド公式ドキュメント（Opus/Sonnet/Haiku 使い分け基準） |
| 085 | 085_ssdnodes-com-pricing-plans.md | https://www.ssdnodes.com/blog/claude-code-pricing-in-2026-every-plan-explained-pro-max-api-teams/ | 2026年全プラン解説（Pro/Max/Team/Enterprise/API 比較） |
| 086 | 086_ksred-com-pricing-guide.md | https://www.ksred.com/claude-code-pricing-guide-which-plan-actually-saves-you-money/ | 8ヶ月10B トークンの実使用分析（API vs Max プラン 93%節約） |
| 087 | 087_dev-to-token-monitoring.md | https://dev.to/kuldeep_paul/best-ways-to-monitor-claude-code-token-usage-and-costs-in-2026-5j3 | トークンモニタリング手法比較（Bifrost/LiteLLM/Cloudflare/Console） |
| 088 | 088_claudefast-usage-optimization.md | https://claudefa.st/blog/guide/development/usage-optimization | 使用量最適化ガイド（ccusage、opusplan 戦略、コスト削減パターン） |
| 089 | 089_verdent-ai-pricing-2026.md | https://www.verdent.ai/guides/claude-code-pricing-2026 | 2026年料金と実使用量試算（ユーザータイプ別推奨プラン） |
| 090 | 090_mindstudio-token-hacks.md | https://www.mindstudio.ai/blog/claude-code-token-management-hacks-3 | 18のトークン管理テクニック（セッション管理、.claudeignore、プロンプト効率化） |
| 091 | 091_ccusage-com.md | https://ccusage.com/ | ccusage ツール紹介（CLI 使用量分析、日次/週次/月次レポート） |
