# 2-1. バグ修正タスクにおける指示パターン

## 調査目的

Claude Code でバグ修正タスクを行う際の効果的な指示パターンを調査する。具体的には (1) 症状・再現手順・期待結果など情報の構造化方法、(2) エラーログやスタックトレースの与え方、(3) バグ修正ワークフロー全体の推奨パターンを整理する。

---

## 1. 効果的な情報の提示方法

### 1.1 「症状の記述」が最重要

公式ドキュメントは、バグ修正の指示において **症状を具体的に記述する** ことを繰り返し強調している。

> "users report that login fails after session timeout. check the auth flow in src/auth/, especially token refresh. write a failing test that reproduces the issue, then fix it"
> — [Claude Code Best Practices](https://code.claude.com/docs/en/best-practices)

曖昧な "fix the login bug" と比較して、上記のプロンプトには以下の要素が含まれている：

| 要素 | 例 | 効果 |
|------|---|------|
| **誰が/いつ発生するか** | "users report that login fails after session timeout" | 再現条件の特定を助ける |
| **調査対象の範囲** | "check the auth flow in src/auth/, especially token refresh" | 無駄なファイル探索を防ぐ |
| **検証方法** | "write a failing test that reproduces the issue, then fix it" | 修正の正しさを自己検証できる |

### 1.2 バグ報告に含めるべき 3 要素

複数のソースを横断すると、効果的なバグ報告には次の 3 つが不可欠という共通見解がある：

> "Three things are needed for effective debugging: full error, where it happened, and what triggered it."
> — [Sider.ai: 50 Claude Code Prompts](https://sider.ai/blog/ai-tools/claude-code-prompts-that-actually-fix-bugs-refactor-messes-and-ship-prs)

1. **完全なエラーメッセージ** — エラーログ、スタックトレース、警告を省略せず渡す
2. **発生箇所** — ファイル名、関数名、行番号などの特定情報
3. **トリガー** — どの操作・条件で発生するか（再現手順）

### 1.3 構造化プロンプトのテンプレート

日本語コミュニティの知見として、以下の構造が推奨されている：

> Claudeにプロンプトを送るときは、まず必要な情報を先に伝え、そのあとで「何をしてほしいか」の指示を出すと、より的確な返答が得られやすい。
> — [start-link.jp: Claude Codeでバグ調査・修正を体系化する方法](https://start-link.jp/hubspot-ai/ai/claude-code-practice/claude-code-debugging-troubleshooting)

実践的なテンプレート：

```
<context>
[前提情報: 技術スタック、影響範囲、直近の変更]
</context>

<error>
[エラーメッセージ全文 / スタックトレース]
</error>

<reproduction>
[再現手順: 1. XXを実行 2. YYが発生]
</reproduction>

<instruction>
根本原因を特定し、最小限の変更で修正してください。
修正後、テストを実行して成功することを確認してください。
</instruction>
```

XMLタグで構造化することで、Claude が「指示」と「データ」を混同することを防ぎ、解析精度が向上する。

### 1.4 修正方針の明示

バグ修正を依頼する際は、修正の方針レベルも指定すると効果的：

| 修正方針 | いつ使うか | プロンプト例 |
|---------|----------|------------|
| **最小限の変更** | 本番障害の緊急対応 | "最小限の変更で修正してください。リファクタリングは不要です" |
| **リファクタリング含む** | 技術的負債の解消時 | "根本原因を修正し、同様のバグが発生しない設計に改善してください" |
| **暫定対応** | 影響範囲が不明な場合 | "まず暫定的な回避策を提案し、影響範囲を推定してください" |

### 1.5 分析を先に求める

> "Don't just fix symptoms—ask about data flow, performance implications, and backward compatibility. Ask for proposals and plans before making changes, as this often reveals better approaches."
> — [Medium: How I Use a Coding Agent to Fix Production Bugs](https://medium.com/madhukarkumar/how-i-use-a-coding-agent-to-fix-production-bugs-3af26ce0e777)

いきなり「修正して」ではなく、まずシステム理解を確認する質問が効果的：

- "Why do you think this error is occurring?"（なぜこのエラーが発生していると思うか？）
- "What is the data flow that leads to this state?"（この状態に至るデータフローは？）
- "What are the possible root causes?"（考えられる根本原因は？）

---

## 2. エラーログ・スタックトレースの与え方

### 2.1 全文を省略せずに渡す

> "Copy the full stack trace, any warnings that appeared before the error, and the command you ran. More context means better debugging."
> — [ClaudeLog: How to use Claude Code for debugging](https://claudelog.com/faqs/how-to-use-claude-code-for-debugging/)

エラーログやスタックトレースは **省略せずに全文を渡す** のが基本原則。Claude はスタックトレースの各行を読み、import を追い、型を検査し、何が問題かの全体像を構築する。

### 2.2 渡し方の選択肢

公式ドキュメントは複数の入力方法を提供している：

| 方法 | コマンド例 | 向いている場面 |
|------|-----------|--------------|
| **パイプ入力** | `cat error.log \| claude -p 'このビルドエラーの根本原因を説明して'` | ログファイルが手元にある場合 |
| **@参照** | `@src/auth/login.ts のエラーを調査して` | 特定ファイルのエラー |
| **直接貼り付け** | プロンプトにスタックトレースをペースト | 対話セッション中 |
| **画像貼り付け** | スクリーンショットをドラッグ&ドロップ | UI エラー、ブラウザコンソール |
| **Claude に取得させる** | "npm test を実行して、失敗したテストのエラーを確認して" | 再現可能なエラー |

### 2.3 スタックトレースの解析指示

スタックトレースをただ渡すだけでなく、解析の指示を添えると精度が上がる：

> "When presenting a stack trace, walk through what each line means, identify which line is the actual bug vs. a downstream symptom, then fix only the root cause."
> — [Sider.ai](https://sider.ai/blog/ai-tools/claude-code-prompts-that-actually-fix-bugs-refactor-messes-and-ship-prs)

効果的なプロンプト例：

```
以下のスタックトレースを解析してください。
- 各行が何を意味するか説明
- 実際のバグと下流の症状を区別
- 根本原因のみを修正

<stack_trace>
TypeError: Cannot read properties of undefined (reading 'userId')
    at AuthService.validateToken (src/auth/service.ts:47)
    at Router.handleRequest (src/router/index.ts:123)
    at Server.onRequest (src/server.ts:89)
</stack_trace>
```

### 2.4 エラーと一緒に渡すべき付加情報

> "Always include the stack trace, when it happens, what changed recently, and how often it occurs."
> — [ClaudeLog](https://claudelog.com/faqs/how-to-use-claude-code-for-debugging/)

| 付加情報 | 例 | なぜ重要か |
|---------|---|----------|
| **発生頻度** | "毎回/間欠的/特定条件で" | 再現性の判断に必要 |
| **直近の変更** | "昨日 auth モジュールをリファクタリングした" | 原因の推定を加速 |
| **環境情報** | "Node.js v20, production 環境" | 環境固有の問題を切り分け |
| **期待動作** | "ログイン後にダッシュボードが表示されるべき" | 修正のゴールを明確化 |

### 2.5 Plan Mode でのエラー調査

> "Paste error messages and stack traces in Plan Mode for thorough investigation. Claude presents a structured investigation plan before switching to execution mode for implementation."
> — [Sider.ai](https://sider.ai/blog/ai-tools/claude-code-prompts-that-actually-fix-bugs-refactor-messes-and-ship-prs)

複雑なバグの場合、以下のフローが推奨される：

1. **Plan Mode に切り替え** (`Shift+Tab`)
2. エラーログ・スタックトレースを貼り付け
3. Claude に調査計画を立てさせる
4. 計画をレビュー・修正
5. **Normal Mode に切り替え**て修正を実行

---

## 3. バグ修正ワークフローの推奨パターン

### 3.1 公式推奨ワークフロー

Claude Code の公式チュートリアルが示すバグ修正の 3 ステップ：

> 1. Share the error with Claude: "I'm seeing an error when I run npm test"
> 2. Ask for fix recommendations: "suggest a few ways to fix the @ts-ignore in user.ts"
> 3. Apply the fix: "update user.ts to add the null check you suggested"
> — [Claude Code Common Workflows](https://code.claude.com/docs/en/tutorials)

### 3.2 テスト駆動バグ修正パターン (TDD Bug Fix)

最も高評価を得ているパターンの一つ：

> "For bugs, first write a failing test that demonstrates the bug, then fix the implementation to make the test pass. This gives you a regression test automatically."
> — [DEV Community: Claude Code for testing](https://dev.to/subprime2010/claude-code-for-testing-write-run-and-fix-tests-without-leaving-your-terminal-2gkh)

**手順:**

1. バグを再現する失敗テストを書かせる
2. テストを実行して失敗を確認
3. テストを通すための最小限の修正を実装
4. テストを再実行して成功を確認
5. リグレッションテストが自動的に残る

**プロンプト例:**

```
ユーザーがセッションタイムアウト後にログインに失敗するバグがあります。

1. まず、このバグを再現する失敗テストを書いてください
2. テストを実行して失敗することを確認してください
3. テストを通すための修正を実装してください
4. 全テストが通ることを確認してください

重要: 既存のテストを修正してはいけません。実装を修正してください。
```

### 3.3 Debugger サブエージェントの活用

公式ドキュメントでは、専用のデバッグサブエージェントの作成を推奨している：

```markdown
---
name: debugger
description: Debugging specialist for errors, test failures, 
  and unexpected behavior. Use proactively when encountering any issues.
tools: Read, Edit, Bash, Grep, Glob
---

You are an expert debugger specializing in root cause analysis.

When invoked:
1. Capture error message and stack trace
2. Identify reproduction steps
3. Isolate the failure location
4. Implement minimal fix
5. Verify solution works
```

> — [Claude Code Sub-agents Documentation](https://code.claude.com/docs/en/sub-agents)

サブエージェントの利点：

- メインの会話コンテキストを消費しない
- デバッグに特化したプロンプトが毎回適用される
- ツールアクセスを制限できる（例: Edit を含めてバグ修正可能にする）

### 3.4 fix-issue スキルの活用

GitHub Issue からバグ修正を一気通貫で行うスキル：

```yaml
---
name: fix-issue
description: Fix a GitHub issue
disable-model-invocation: true
---

Fix GitHub issue $ARGUMENTS following our coding standards.

1. Read the issue description
2. Understand the requirements
3. Implement the fix
4. Write tests
5. Create a commit
```

> — [Claude Code Skills Documentation](https://code.claude.com/docs/en/skills)

`/fix-issue 1234` で呼び出すと、Issue の読み取りからコミットまでを自動化できる。

### 3.5 検証基準の提供（最重要プラクティス）

> "Include tests, screenshots, or expected outputs so Claude can check itself. This is the single highest-leverage thing you can do."
> — [Claude Code Best Practices](https://code.claude.com/docs/en/best-practices)

| 検証方法 | Before (悪い例) | After (良い例) |
|---------|----------------|----------------|
| エラー修正 | "the build is failing" | "the build fails with this error: [paste error]. fix it and verify the build succeeds. address the root cause, don't suppress the error" |
| テスト修正 | "fix the failing tests" | "npm test が 3 件失敗しています。失敗テストを確認し、実装を修正して全テストを通してください" |
| UI修正 | "the button is broken" | "[screenshot] このボタンをクリックするとエラーが出ます。修正後スクリーンショットを撮って比較してください" |

### 3.6 Anthropic 社内の実践

> "During incidents, the Security Engineering team feeds Claude Code stack traces and documentation to trace control flow through the codebase. Problems that typically take 10-15 minutes of manual scanning now resolve 3x as quickly."
> — [Anthropic: How Anthropic teams use Claude Code](https://anthropic.com/news/how-anthropic-teams-use-claude-code)

Anthropic 社内では以下の原則でバグ修正を行っている：

- 変更はできるだけシンプルに、最小限のコードで
- コードを追加するより削除する方向で
- 一時的な修正ではなく根本原因を見つける
- 必要な箇所だけを変更し、新しい副作用を導入しない

### 3.7 セッション管理の注意点

バグ修正セッションで陥りやすいアンチパターンと対策：

| アンチパターン | 症状 | 対策 |
|-------------|------|------|
| **修正の繰り返し** | 2回以上同じ指摘を修正できない | `/clear` してより具体的なプロンプトで再開 |
| **コンテキスト汚染** | バグ調査で大量のファイルを読みすぎ | サブエージェントに調査を委譲 |
| **混合セッション** | バグ修正中に無関係な作業を開始 | タスク間で `/clear` する |
| **検証なし出荷** | 見た目は正しいが実は壊れている | 必ずテスト/スクリーンショットで検証 |

> "If you've corrected Claude more than twice on the same issue in one session, the context is cluttered with failed approaches. Run /clear and start fresh with a more specific prompt."
> — [Claude Code Best Practices](https://code.claude.com/docs/en/best-practices)

---

## まとめ

### バグ修正指示のチェックリスト

| # | チェック項目 | 重要度 |
|---|-----------|-------|
| 1 | 検証基準を提示した（テスト、期待出力、スクリーンショット） | **必須** |
| 2 | エラーメッセージ/スタックトレースを全文貼り付けた | **必須** |
| 3 | 再現手順を記述した | **必須** |
| 4 | 調査範囲を指定した（ファイル/ディレクトリ） | 推奨 |
| 5 | 修正方針を明示した（最小変更/リファクタ含む/暫定） | 推奨 |
| 6 | 「分析してから修正」の順序を指示した | 推奨 |
| 7 | 環境情報・直近の変更を共有した | 推奨 |
| 8 | 複雑なバグは Plan Mode で調査計画を立てた | 状況に応じて |
| 9 | 大規模調査はサブエージェントに委譲した | 状況に応じて |

### 推奨ワークフロー図

```
バグ報告受領
    |
    v
[情報収集] エラーログ全文 + 再現手順 + 環境情報
    |
    v
[判断] 修正が1文で説明できるか?
    |           |
   Yes          No
    |           |
    v           v
直接修正    Plan Mode で調査
    |           |
    v           v
テスト駆動修正:
  1. 失敗テスト作成
  2. 最小限の修正実装
  3. テスト成功確認
  4. 全テストスイート実行
    |
    v
検証 → コミット
```

---

## 参考資料

- [Best Practices for Claude Code - Claude Code Docs](https://code.claude.com/docs/en/best-practices)
- [Common workflows - Claude Code Docs](https://code.claude.com/docs/en/tutorials)
- [Create custom subagents - Claude Code Docs](https://code.claude.com/docs/en/sub-agents)
- [Extend Claude with skills - Claude Code Docs](https://code.claude.com/docs/en/skills)
- [How Anthropic teams use Claude Code](https://anthropic.com/news/how-anthropic-teams-use-claude-code)
- [Claude Codeでバグ調査・修正を体系化する方法](https://start-link.jp/hubspot-ai/ai/claude-code-practice/claude-code-debugging-troubleshooting)
- [How I Use a Coding Agent to Fix Production Bugs - Medium](https://medium.com/madhukarkumar/how-i-use-a-coding-agent-to-fix-production-bugs-3af26ce0e777)
- [50 Claude Code Prompts That Actually Fix Bugs - Sider.ai](https://sider.ai/blog/ai-tools/claude-code-prompts-that-actually-fix-bugs-refactor-messes-and-ship-prs)
- [Claude Code for testing - DEV Community](https://dev.to/subprime2010/claude-code-for-testing-write-run-and-fix-tests-without-leaving-your-terminal-2gkh)
- [The Prompt Engineering Playbook for Programmers - Substack](https://addyo.substack.com/p/the-prompt-engineering-playbook-for)
- [How to use Claude Code for debugging - ClaudeLog](https://claudelog.com/faqs/how-to-use-claude-code-for-debugging/)
- [Fix software bugs faster with Claude - Claude Blog](https://claude.com/blog/fix-software-bugs-faster-with-claude)
