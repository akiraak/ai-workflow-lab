# 2-4. コードレビュー・説明タスクにおける指示パターン

## 調査目的

Claude Code でコードレビューや説明タスクを行う際の効果的な指示パターンを調査する。レビュー観点の指定方法、出力フォーマットの効果、および実践的なワークフローパターンを明らかにする。

---

## 1. レビュー観点の指定方法

### 1.1 公式 Code Review 機能のアーキテクチャ

Claude Code には PR ベースの自動コードレビュー機能が搭載されており、そのアーキテクチャ自体が「観点の分割」の模範例となっている。

> When a review runs, multiple agents analyze the diff and surrounding code in parallel on Anthropic infrastructure. Each agent looks for a different class of issue, then a verification step checks candidates against actual code behavior to filter out false positives.
> — [Code Review - Claude Code Docs](https://code.claude.com/docs/en/code-review)

公式 code-review プラグインでは、4つの並列エージェントが異なる観点を担当する:

| エージェント | 役割 | モデル |
|---|---|---|
| Agent 1 & 2 | CLAUDE.md コンプライアンス（ガイドライン準拠） | Sonnet |
| Agent 3 | バグ検出（diff のみに集中） | Opus |
| Agent 4 | セキュリティ・ロジック問題 | Opus |

出典: [code-review プラグインのコマンド定義](https://github.com/anthropics/claude-code/blob/main/plugins/code-review/commands/code-review.md)

この設計から得られる教訓は、**観点ごとに専用のエージェントを割り当てる**ことで精度が向上するということである。

### 1.2 HIGH SIGNAL フラグ基準

公式 code-review コマンドは、フラグを立てるべきものと立てないものを明確に分離している:

**フラグすべき問題:**
- コンパイル/パースに失敗するコード（構文エラー、型エラー、未解決参照）
- 入力に関わらず確実に誤った結果を出すコード（明確なロジックエラー）
- 明確かつ曖昧さのない CLAUDE.md 違反（具体的なルールを引用可能）

**フラグしない問題:**
- コードスタイルや品質に関する懸念
- 特定の入力や状態に依存する潜在的問題
- 主観的な提案や改善

> **Critical Rule:** If you are not certain an issue is real, do not flag it. False positives erode trust and waste reviewer time.
> — [code-review command](https://github.com/anthropics/claude-code/blob/main/plugins/code-review/commands/code-review.md)

この「偽陽性を最小化する」方針は、対話的なレビュー指示でも応用できる。

### 1.3 REVIEW.md によるカスタム観点の指定

Claude Code は `REVIEW.md` ファイルを自動検出し、レビュー固有のガイドラインとして使用する:

> Add a `REVIEW.md` file to your repository root for review-specific rules. Use it to encode:
> - Company or team style guidelines
> - Language- or framework-specific conventions not covered by linters
> - Things Claude should always flag
> - Things Claude should skip
> — [Code Review - Claude Code Docs](https://code.claude.com/docs/en/code-review)

実用的な `REVIEW.md` の例:

```markdown
# Code Review Guidelines

## Always check
- New API endpoints have corresponding integration tests
- Database migrations are backward-compatible
- Error messages don't leak internal details to users

## Style
- Prefer `match` statements over chained `isinstance` checks
- Use structured logging, not f-string interpolation in log calls

## Skip
- Generated files under `src/gen/`
- Formatting-only changes in `*.lock` files
```

**REVIEW.md と CLAUDE.md の使い分け:**

| ファイル | 用途 | 適用範囲 |
|---|---|---|
| `CLAUDE.md` | プロジェクト全般のガイドライン | 対話・レビュー・実装すべて |
| `REVIEW.md` | レビュー固有のルール | Code Review のみ |

CLAUDE.md の内容に基づく違反は nit レベルの指摘として扱われる。

### 1.4 観点分割戦略: 多エージェント合議制

OpenWork のテックブログでは、3層エージェントオーケストレーションによる高精度レビューを報告している:

**第1層（オーケストレーター）:** 技術ドメインを判定し、サブエージェントを起動
**第2層（レビュー実行）:** 各観点について4つのエージェントが**異なるLLMモデル**を使用してレビュー
**第3層（レビュー検査）:** 4つのエージェントの出力を比較し、**2つ以上が同じ箇所・同じ意図で指摘した項目のみ採用**

> AIエージェントはより小さく焦点を絞ったタスクで精度が向上する
> — [OpenWork Tech Blog](https://techblog.openwork.co.jp/entry/ai-code-review-3-layer-architecture)

この手法の核心は:

1. **タスク分割**: 単一エージェントに全観点を任せず、限定スコープに分割
2. **多モデル検証**: 異なるLLMで多様な視点を確保
3. **合議制フィルタリング**: 複数エージェントの合意で偽陽性を除去

### 1.5 対話的レビューにおける観点指定の実践パターン

レビュープロンプトの構成要素として、以下の5要素公式が知られている:

> 役割 + 範囲 + 重点 + 形式 + 重大度 = 効果的なレビュープロンプト
> — [Apiyi.com](https://help.apiyi.com/ja/claude-code-code-review-prompts-collection-guide-ja.html)

**観点別プロンプト例:**

| 観点 | プロンプト例 |
|------|-------------|
| セキュリティ | "Review this code for security vulnerabilities: SQL injection, XSS, authentication flaws, and credential leaks. Provide specific line references." |
| パフォーマンス | "Analyze performance: check for N+1 queries, unnecessary re-renders, memory leaks, and missing caching opportunities." |
| ロジック | "Find logic errors that would produce wrong results regardless of input. Focus only on the changed code." |
| 規約準拠 | "Check if these changes comply with our CLAUDE.md guidelines. Quote the exact rule for each violation." |
| エッジケース | "What edge cases does this code miss? Consider null values, empty collections, concurrent access, and timezone differences." |

### 1.6 Writer/Reviewer パターン

公式ベストプラクティスが推奨する、実装とレビューの分離パターン:

> A fresh context improves code review since Claude won't be biased toward code it just wrote.
> — [Best Practices - Claude Code Docs](https://code.claude.com/docs/en/best-practices)

| セッションA（Writer） | セッションB（Reviewer） |
|---|---|
| `Implement a rate limiter for our API endpoints` | |
| | `Review the rate limiter implementation in @src/middleware/rateLimiter.ts. Look for edge cases, race conditions, and consistency with our existing middleware patterns.` |
| `Here's the review feedback: [Session B output]. Address these issues.` | |

この分離の効果:
- **コンテキストバイアスの排除**: 自分が書いたコードへの偏りを避ける
- **新鮮なコンテキスト**: レビューセッションは実装の試行錯誤を含まない
- **専門化**: レビュー専用のサブエージェントを定義可能

**セキュリティレビュー専用サブエージェントの定義例:**

```markdown
# .claude/agents/security-reviewer.md
---
name: security-reviewer
description: Reviews code for security vulnerabilities
tools: Read, Grep, Glob, Bash
model: opus
---
You are a senior security engineer. Review code for:
- Injection vulnerabilities (SQL, XSS, command injection)
- Authentication and authorization flaws
- Secrets or credentials in code
- Insecure data handling

Provide specific line references and suggested fixes.
```

---

## 2. 出力フォーマット指定の効果

### 2.1 重大度タグによる構造化出力

公式 Code Review 機能は、指摘事項を3段階の重大度で分類する:

| マーカー | 重大度 | 意味 |
|---|---|---|
| 🔴 | Important | マージ前に修正すべきバグ |
| 🟡 | Nit | 修正推奨だがブロックしない |
| 🟣 | Pre-existing | PR で導入されたものではない既存バグ |

この構造化により、レビュー結果の**優先度判断**が容易になる。

### 2.2 信頼度スコアリング

code-review プラグインは各指摘に 0-100 の信頼度スコアを付与する:

| スコア | 意味 |
|---|---|
| 0 | 確信なし、偽陽性 |
| 25 | ある程度確信、本物かもしれない |
| 50 | 中程度の確信、本物だが軽微 |
| 75 | 高い確信、本物で重要 |
| 100 | 完全に確実、間違いなく本物 |

デフォルトの閾値は80で、これを下回る指摘はフィルタリングされる。

> Trust the 80+ confidence threshold — false positives are filtered.
> — [Code Review Plugin](https://github.com/anthropics/claude-code/blob/main/plugins/code-review/README.md)

対話的なレビューでも、この信頼度付与を指示に含めることで出力品質が向上する:

```
各指摘に信頼度（低/中/高）を付記してください。
「高」以外の指摘は理由を明記してください。
```

### 2.3 機械可読な出力フォーマット

Claude Code の `--output-format` フラグにより、プログラム処理可能な出力が得られる:

| フォーマット | 用途 |
|---|---|
| `text` | 人間向けプレーンテキスト（デフォルト） |
| `json` | メタデータ付き構造化データ |
| `stream-json` | リアルタイムストリーミングJSON |

CI/CD パイプラインでの使用例:

```bash
# レビュー結果をJSON形式で取得
claude -p "Review this PR for bugs" --output-format json

# 重大度情報をパース
gh api repos/OWNER/REPO/check-runs/CHECK_RUN_ID \
  --jq '.output.text | split("bughunter-severity: ")[1] | split(" -->")[0] | fromjson'
# => {"normal": 2, "nit": 1, "pre_existing": 0}
```

### 2.4 出力フォーマット指定のベストプラクティス

AI コードレビューにおける出力フォーマット指定は、結果の**実用性**に直結する。

**効果的なフォーマット指示のパターン:**

| パターン | 指示例 | 効果 |
|---|---|---|
| 重大度タグ | "Tag each finding as CRITICAL/WARNING/INFO" | 優先度判断が容易に |
| ファイル:行番号 | "Include file path and line number for each issue" | 問題箇所への直接アクセス |
| 修正提案付き | "For each issue, provide the current code and suggested fix" | 即座に修正可能 |
| テーブル形式 | "Summarize findings in a markdown table" | 一覧性・比較性の向上 |
| カテゴリ分類 | "Group findings by category: security, performance, logic" | 観点別の整理 |

**具体的なプロンプト例:**

```
以下のコードをレビューしてください。

出力形式:
- 各指摘は「[重大度] ファイル:行番号 — 指摘内容」の形式
- 重大度は CRITICAL / WARNING / INFO の3段階
- 各指摘に修正案のコードブロックを付記
- 最後に全体評価を1段落で記述
```

### 2.5 Output Style による説明モードのカスタマイズ

Claude Code の Output Style 機能を活用すると、レビュー結果に**教育的な洞察**を追加できる:

**Explanatory スタイル:**
> Provides educational "Insights" in between helping you complete software engineering tasks. Helps you understand implementation choices and codebase patterns.
> — [Output Styles - Claude Code Docs](https://code.claude.com/docs/en/output-styles)

Explanatory プラグインは以下のフォーマットで洞察を提供:

```
★ Insight ─────────────────────────────────────
[2-3 key educational points]
─────────────────────────────────────────────────
```

洞察の焦点:
- コードベース固有の実装選択
- パターンと規約
- トレードオフと設計判断

**カスタムOutput Styleの作成:**

```markdown
---
name: Review-Focused
description: Code review with educational context
keep-coding-instructions: true
---

When reviewing code, always provide:
1. A severity rating for each finding
2. The specific rule or principle being violated
3. A brief "why this matters" explanation
4. A suggested fix with code example
```

### 2.6 カスタムスラッシュコマンドによるフォーマット固定

`.claude/commands/review.md` を作成することで、レビュー用のフォーマットを固定できる:

```markdown
# .claude/commands/review.md

Review the code in $ARGUMENTS:

1. **High-level summary**: What does this code do? (2-3 sentences)
2. **Issues found**: List each issue with:
   - Severity: CRITICAL / WARNING / INFO
   - Location: file:line
   - Description: what's wrong and why
   - Fix: suggested code change
3. **Positive aspects**: What's done well (1-2 points)
4. **Overall assessment**: Ship / Fix then ship / Needs rework
```

使用: `/review src/auth/session.ts`

`$ARGUMENTS` により、コマンド名の後のテキストがプロンプトに代入される。

---

## 3. コードレビュー・説明ワークフローの推奨パターン

### 3.1 コード理解・説明のワークフロー

Claude Code はシニアエンジニアに質問するように使える:

> Ask Claude the same sorts of questions you would ask another engineer:
> - How does logging work?
> - How do I make a new API endpoint?
> - What edge cases does `CustomerOnboardingFlowImpl` handle?
> — [Best Practices - Claude Code Docs](https://code.claude.com/docs/en/best-practices)

**コードベース理解のためのプロンプトパターン:**

| 目的 | プロンプト例 |
|------|-------------|
| 全体像の把握 | "Explain what this project does at a high level" |
| 処理フローの理解 | "Trace the request flow from API entry to database" |
| 設計判断の理解 | "Why does this code call foo() instead of bar() on line 333?" |
| 歴史の理解 | "Look through ExecutionFactory's git history and summarize how its api came to be" |
| エッジケースの把握 | "What edge cases does CustomerOnboardingFlowImpl handle?" |

**Plan Mode を活用した安全な調査:**

```
# Plan Mode で安全にコードを探索
read /src/auth and understand how we handle sessions and login.
also look at how we manage environment variables for secrets.
```

Plan Mode ではファイルの読み取りと質問への回答のみが行われ、変更は加えられない。

### 3.2 段階的レビューワークフロー

以下の段階的アプローチが効果的:

```
Step 1: 変更の概要把握
  "Summarize the changes in this PR"

Step 2: 重大な問題の検出
  "Find any bugs that would break production"

Step 3: 観点別の深掘り
  "Now check for security issues in the auth-related changes"

Step 4: ガイドライン準拠の確認
  "Check compliance with our CLAUDE.md guidelines"
```

### 3.3 サブエージェント活用パターン

> Since context is your fundamental constraint, subagents are one of the most powerful tools available. Subagents run in separate context windows and report back summaries.
> — [Best Practices - Claude Code Docs](https://code.claude.com/docs/en/best-practices)

サブエージェントを使ったレビューの委任:

```
use a subagent to review this code for edge cases
```

```
You just wrote the code for the payment processor.
Now, use a sub-agent to perform a security review of that code.
```

メインの会話コンテキストを汚さずに、独立したレビューを実行できる。

### 3.4 awesome-reviewers: 再利用可能なレビュープロンプトライブラリ

[baz-scm/awesome-reviewers](https://github.com/baz-scm/awesome-reviewers) は、470以上の専門レビュープロンプトを収録したオープンソースライブラリ:

- 15以上の言語に対応
- Next.js、LangChain、FastAPI など1000以上のOSSプロジェクトの実際のレビューコメントから抽出
- チェックリスト形式で構造化された AI-ready なプロンプト
- Claude Code を含むカスタム指示をサポートするツールにコピー&ペースト可能

### 3.5 Hooks による自動レビュートリガー

> Hooks run scripts automatically at specific points in Claude's workflow. Unlike CLAUDE.md instructions which are advisory, hooks are deterministic and guarantee the action happens.
> — [Best Practices - Claude Code Docs](https://code.claude.com/docs/en/best-practices)

ファイル編集後に自動的にリントを実行する hook の例:

```
"Write a hook that runs eslint after every file edit"
```

レビュー品質の自動保証に活用できる。

---

## まとめ

### レビュー観点指定の要点

| 手法 | 適用場面 | 効果 |
|------|---------|------|
| `REVIEW.md` でルール定義 | PR ベースの自動レビュー | チーム共通の観点を標準化 |
| サブエージェントに委任 | 実装後のセルフレビュー | コンテキスト分離、バイアス排除 |
| 観点別にプロンプトを分割 | 対話的レビュー | 各観点の精度向上 |
| 多エージェント合議制 | 高精度が求められるレビュー | 偽陽性の大幅削減 |
| 5要素公式（役割+範囲+重点+形式+重大度） | 任意のレビュー | 構造化された包括的レビュー |

### 出力フォーマット指定の要点

| 手法 | 適用場面 | 効果 |
|------|---------|------|
| 重大度タグ付き | すべてのレビュー | 優先度判断の容易化 |
| 信頼度スコア | 自動レビュー | 偽陽性のフィルタリング |
| ファイル:行番号付き | コードベースへの指摘 | 問題箇所への直接アクセス |
| `--output-format json` | CI/CD パイプライン | プログラム処理可能な出力 |
| カスタムスラッシュコマンド | 繰り返しのレビュー | フォーマットの固定化・再利用 |
| Output Style | 教育的フィードバック | 理解を深める洞察の追加 |

### 実践的ガイドライン

1. **偽陽性を最小化する**: 確信が持てない問題はフラグしない。信頼の維持が最重要。
2. **観点を分割する**: 1つのエージェントに全観点を任せず、セキュリティ・ロジック・規約準拠を分離。
3. **Writer/Reviewer を分離する**: 実装セッションとは別のセッションでレビューを行う。
4. **出力フォーマットを明示する**: 重大度・ファイル位置・修正案を含む構造化出力を指定。
5. **REVIEW.md でチームの観点を標準化する**: レビュー固有のルールを CLAUDE.md とは分離して管理。
6. **サブエージェントでコンテキストを節約する**: レビューをサブエージェントに委任し、メインの会話を汚さない。

---

## 参考資料

- [Code Review - Claude Code Docs](https://code.claude.com/docs/en/code-review)
- [Code Review Plugin README](https://github.com/anthropics/claude-code/blob/main/plugins/code-review/README.md)
- [Code Review Command Definition](https://github.com/anthropics/claude-code/blob/main/plugins/code-review/commands/code-review.md)
- [Output Styles - Claude Code Docs](https://code.claude.com/docs/en/output-styles)
- [Best Practices - Claude Code Docs](https://code.claude.com/docs/en/best-practices)
- [Explanatory Output Style Plugin](https://github.com/anthropics/claude-code/tree/main/plugins/explanatory-output-style)
- [3層エージェントオーケストレーションで実現する高精度AIコードレビュー - OpenWork Tech Blog](https://techblog.openwork.co.jp/entry/ai-code-review-3-layer-architecture)
- [Effective Prompt Engineering for AI Code Reviews - Graphite](https://graphite.com/guides/effective-prompt-engineering-ai-code-reviews)
- [Claude Codeでコードレビューを行うための25の便利なプロンプト - Apiyi.com](https://help.apiyi.com/ja/claude-code-code-review-prompts-collection-guide-ja.html)
- [Claude Code Custom Slash Commands - DEV Community](https://dev.to/subprime2010/claude-code-custom-slash-commands-build-your-own-deploy-review-test-1ifc)
- [7 AI Prompts for Code Review and Security Audits - Medium](https://medium.com/data-science-collective/youre-using-ai-to-write-code-you-re-not-using-it-to-review-code-728e5ec2576e)
- [awesome-reviewers - GitHub](https://github.com/baz-scm/awesome-reviewers)
- [Claude Code Best Practices: Lessons From Real Projects](https://ranthebuilder.cloud/blog/claude-code-best-practices-lessons-from-real-projects/)
- [Claude Codeで品質の高いコードを書くために - ENECHANGE Developer Blog](https://tech.enechange.co.jp/entry/2025/07/14/144750)
- [Claude Code Actionでコードレビューを効率化する - REALITY株式会社](https://note.com/reality_eng/n/n873a4cab65ee)
