---
url: https://dev.to/_vjk/i-made-claude-code-think-before-it-codes-heres-the-prompt-bf
fetched_at: 2026-04-06T12:00:00Z
---

# I Made Claude Code Think Before It Codes. Here's the Prompt.

## 概要
/wizard という Claude Code スキルで、規律あるソフトウェアエンジニアリングを強制する方法論。

## 問題
Claude Code は速く実行するがバグを生む: レースコンディション、ハードコードされた文字列、assert(true) のようなテスト。問題は知性ではなくプロセスにあった。

## 8フェーズ方法論

1. **Plan Before Touching Code**: CLAUDE.md と GitHub issue を読み、構造化 TODO を作成
2. **Explore Before Assuming**: grep でモデル・メソッド・定数の存在を確認
3. **Write Tests First (TDD)**: 実装前にフェイリングテスト作成、mutation testing マインドセット
4. **Implement Minimum**: テストを通すのに必要最小限のコードだけ書く
5. **Verify No Regressions**: 新テスト以外のフルテストスイート実行
6. **Document While Fresh**: インラインコメントとchangelogエントリ
7. **Adversarial Review**: 自身のコードを攻撃者視点でレビュー
8. **Quality Gate Cycle**: 自動レビューボットの指摘に対応

## 実例: ACAT Transfer Status Tracking
- 49テスト、108アサーション
- 出荷前に4つのバグを捕捉
- レースコンディション、NPEクラッシュ、enum違反、トーン不一致を防止

## インストール
```bash
curl -sL https://raw.githubusercontent.com/vlad-ko/claude-wizard/main/install.sh | bash
```

.claude/skills/wizard/ に SKILL.md, CHECKLISTS.md, PATTERNS.md を作成

## 核心的洞察
「知性は有用だが、プロセスこそが知性を安全にする」
