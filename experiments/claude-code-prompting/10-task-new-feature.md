# 2-2. 新機能実装タスクにおける指示パターン

## 調査目的

Claude Code で新機能を実装する際の効果的な指示パターンを調査する。特に「仕様・制約の伝え方」と「Plan mode と直接指示の使い分け」に焦点を当てる。

---

## 1. 仕様・制約の伝え方

### 1.1 基本原則：具体的な指示が品質を決める

> "The more precise your instructions, the fewer corrections you'll need."
> （指示がより正確であるほど、必要な修正が少なくなる）
> — [Claude Code Best Practices](https://code.claude.com/docs/en/best-practices)

> "AI coding quality usually fails at the specification layer before it fails at the model layer."
> （AI コーディングの品質は、モデル層で失敗する前に仕様層で失敗する）
> — [Addy Osmani, "How to write a good spec for AI agents"](https://addyosmani.com/blog/good-spec/)

新機能実装における指示の質は、出力コードの品質に直結する。曖昧な要件で始めると、Claude は「もっともらしいが実際には機能しないもの」を生成するリスクがある。

### 1.2 効果的な仕様に含めるべき6要素

Addy Osmani の AI エージェント向け仕様フレームワーク（GitHub の 2,500 以上のエージェント設定分析と Stanford の研究に基づく）によると、効果的な仕様は以下の6領域をカバーする：

| 領域 | 内容 | 例 |
|------|------|-----|
| **コマンド** | ビルド・テスト・実行コマンド | `npm run build`, `pytest -v` |
| **テスト** | テストフレームワーク、カバレッジ期待 | Jest 使用、主要パスのカバレッジ必須 |
| **プロジェクト構造** | ディレクトリレイアウトと規約 | `src/components/` にコンポーネント配置 |
| **コードスタイル** | フォーマット、命名、パターン | ES Modules 使用、camelCase |
| **Git ワークフロー** | ブランチ命名、コミットメッセージ形式 | `feature/xxx` ブランチ |
| **境界（やってはいけないこと）** | エージェントが行ってはならないこと | 既存 API の破壊的変更禁止 |

> "Rules only work when they are small, narrow, and scoped. LLMs have a hard time following too many instructions at once—the fewer rules you load into context, the better the result."
> — [Addy Osmani](https://addyosmani.com/blog/good-spec/)

### 1.3 仕様の伝え方：4つのパターン

#### パターン1: プロンプト内での直接指定

最もシンプルな方法。小規模な機能で、1回のプロンプトに収まる場合に有効。

```
write a validateEmail function.
- Input: string
- Output: boolean
- Test cases: user@example.com → true, invalid → false, user@.com → false
- Use regex, no external libraries
- Run the tests after implementing
```

**公式推奨のプロンプト構造要素：**

| 要素 | 説明 | 例 |
|------|------|-----|
| 対象ファイル/スコープ | どこに実装するか | `src/utils/validation.ts に追加` |
| 制約条件 | 使うべき/避けるべきもの | `外部ライブラリ不使用` |
| 既存パターンの参照 | コードベース内の模範 | `HotDogWidget.php のパターンに従って` |
| 検証方法 | 成功条件 | `テストケースを実行して全パス` |
| 期待する振る舞い | 入出力の具体例 | `user@example.com → true` |

#### パターン2: インタビュー手法（大規模機能向け）

公式ベストプラクティスで推奨されている手法。Claude に要件を掘り下げさせることで、自分が見落としていた課題に気づける。

```
I want to build [brief description]. Interview me in detail
using the AskUserQuestion tool.

Ask about technical implementation, UI/UX, edge cases, concerns,
and tradeoffs. Don't ask obvious questions, dig into the hard
parts I might not have considered.

Keep interviewing until we've covered everything, then write
a complete spec to SPEC.md.
```

> "Claude asks about things you might not have considered yet, including technical implementation, UI/UX, edge cases, and tradeoffs."
> — [Claude Code Best Practices](https://code.claude.com/docs/en/best-practices)

**インタビュー手法のメリット：**
- 自分が気づいていない要件・エッジケースが表面化する
- 仕様の抜け漏れが実装前に発見される
- 生成された SPEC.md が以降の実装の「契約」として機能する

#### パターン3: Spec-Driven Development（仕様駆動開発）

2025-2026 年に急速に普及したワークフロー。仕様を一次成果物とし、コードをその派生物と位置づける。

**4フェーズのワークフロー：**

| フェーズ | 目的 | 成果物 |
|---------|------|--------|
| **Requirements** | 何を作るか定義 | `specs/requirements.md` |
| **Design** | どう作るか決定 | `specs/design.md` |
| **Tasks** | いつ・どの順序で作るか計画 | `specs/tasks/TASKS.md` |
| **Implementation** | 計画を実行 | 実装コード + テスト |

> "Instead of being interrupted dozens of times during implementation, you review three documents upfront (requirements, design, tasks) and then let the Implementation Agent work."
> — [claude-code-spec-workflow](https://github.com/Pimzino/claude-code-spec-workflow)

**SDD の利点：**
- 実装中の割り込みが大幅に減る（重要な判断は事前に済んでいるため）
- SPEC.md が「契約」として機能し、出力がスペックに合わなければバグ、スペックが間違っていれば仕様の問題と切り分けられる
- 各タスクが独立してテスト可能・コミット可能

#### パターン4: CLAUDE.md + Skills による永続的制約

プロジェクト全体に適用される制約は CLAUDE.md に、特定ドメインの知識は Skills に分離する。

```markdown
# CLAUDE.md（プロジェクト全体の制約）
- Use ES modules (import/export) syntax, not CommonJS
- All API endpoints must include pagination for list responses
- Run typecheck after code changes
```

```markdown
# .claude/skills/api-conventions/SKILL.md（ドメイン知識）
---
name: api-conventions
description: REST API design conventions for our services
---
- Use kebab-case for URL paths
- Use camelCase for JSON properties
- Version APIs in the URL path (/v1/, /v2/)
```

**使い分けの基準：**

| 配置場所 | 用途 | 読み込みタイミング |
|---------|------|------------------|
| CLAUDE.md | すべてのセッションに適用される制約 | 毎回自動読み込み |
| Skills | 特定のタスクで必要なドメイン知識 | 関連する場合にオンデマンド |
| プロンプト内 | 今回のタスク固有の要件 | 指示時のみ |

### 1.4 検証可能な仕様を書く

> "Include tests, screenshots, or expected outputs so Claude can check itself. This is the single highest-leverage thing you can do."
> — [Claude Code Best Practices](https://code.claude.com/docs/en/best-practices)

Claude に自己検証の手段を与えることが、最も効果の高い実践である。

**検証手段の例：**

| 検証方法 | 適用場面 | 具体例 |
|---------|---------|--------|
| テストケース | ロジック実装 | `user@example.com → true, invalid → false` |
| スクリーンショット比較 | UI 変更 | デザインカンプを貼り付けて比較を指示 |
| Bash コマンド | ビルド・リント | `npm run build && npm run lint` |
| 既存テストスイート | 回帰テスト | `run the test suite and fix any failures` |

### 1.5 仕様の粒度：タスク分割の目安

> "Keep each task under 200 lines of changes, write tests before implementation, and commit after each successful step."
> — [GSD Framework](https://www.mindstudio.ai/blog/gsd-framework-claude-code-clean-context-phases)

大きな機能を Claude に一度に実装させると品質が低下する。以下の目安でタスクを分割する：

| 基準 | 推奨値 |
|------|--------|
| 1タスクあたりの変更行数 | 200行以下 |
| 1タスクの所要時間目安 | 30分以内 |
| コンテキストウィンドウ使用率 | 50%以下（1タスクあたり） |

**分割の実践例：**

音声文字起こしシステムを実装する場合：
1. モデルダウンロードのみを行う実行ファイル
2. 音声録音のみを行う実行ファイル
3. 事前録音済み音声の文字起こしを行う実行ファイル
4. 上記を統合した完全版

段階的に動作確認しながら進めることで、問題の切り分けが容易になる。

---

## 2. Plan mode と直接指示の使い分け

### 2.1 効率性の比較データ

> Complex tasks see **37% higher first-try success rates** with plan mode vs direct prompting.
> — [Plan Mode in Claude Code: When to Use It](https://claude-ai.chat/blog/plan-mode-in-claude-code-when-to-use-it/)

| 指標 | Plan mode 使用時 | 直接指示時 |
|------|-----------------|-----------|
| 初回成功率 | 37%高い | ベースライン |
| トークン消費（複雑タスク） | 少ない（手戻りなし） | 多い（手戻りループ発生） |
| 実装時間（複雑タスク例） | 約12分 | 約35分以上（2回やり直し） |
| 単純タスクのオーバーヘッド | あり（不要） | なし |

### 2.2 判断フローチャート

```
新機能の実装指示を出す
  │
  ├─ 差分を一文で説明できる？
  │   └─ Yes → 直接指示（Plan mode 不要）
  │
  ├─ 変更が3ファイル以上にまたがる？
  │   └─ Yes → Plan mode を使う
  │
  ├─ アーキテクチャの判断が必要？
  │   └─ Yes → Plan mode を使う
  │
  ├─ コードベースに不慣れ？
  │   └─ Yes → Plan mode で探索から始める
  │
  └─ 上記いずれも No
      └─ 通常モードで直接指示
```

### 2.3 Plan mode を使うべき場面

| 場面 | 理由 |
|------|------|
| **複数ファイルにまたがる変更（3+）** | 影響範囲と依存関係の見落としを防ぐ |
| **アーキテクチャの意思決定** | 設計の方向性を実装前に合意 |
| **不慣れなコードベース** | 既存の構造を理解してから着手 |
| **大規模リファクタリング（5+ ファイル）** | 最も効果が高い |
| **依存関係チェーンが複雑** | 実行順序を事前に可視化 |

### 2.4 直接指示で十分な場面

| 場面 | 理由 |
|------|------|
| **タイプミス修正** | 変更が自明 |
| **ログ行の追加** | スコープが極めて小さい |
| **変数名のリネーム** | 一文で説明可能 |
| **ボイラープレート生成** | パターンが決まっている |
| **コードフォーマット** | 機械的な変換 |
| **要件が完全に明確な単一ファイル変更** | 計画のオーバーヘッドが無駄 |

### 2.5 公式推奨の4フェーズワークフロー

> "Explore first, then plan, then code"
> — [Claude Code Best Practices](https://code.claude.com/docs/en/best-practices)

#### Phase 1: Explore（探索）— Plan Mode

```
(Plan Mode で)
read /src/auth and understand how we handle sessions and login.
also look at how we manage environment variables for secrets.
```

ファイルを読ませ、質問に答えさせる。変更は行わない。

#### Phase 2: Plan（計画）— Plan Mode

```
(Plan Mode で)
I want to add Google OAuth. What files need to change?
What's the session flow? Create a plan.
```

詳細な実装計画を作成させる。`Ctrl+G` で計画をエディタで直接編集可能。

#### Phase 3: Implement（実装）— Normal Mode

```
(Normal Mode に切り替え)
implement the OAuth flow from your plan. write tests for the
callback handler, run the test suite and fix any failures.
```

計画に基づいてコーディング。テストで検証。

#### Phase 4: Commit

```
commit with a descriptive message and open a PR
```

### 2.6 Plan mode のコスト効果

Plan mode は一見オーバーヘッドに見えるが、複雑なタスクでは実際にトークンを節約する：

> "Plan mode actually costs fewer tokens on complex tasks because it avoids the expensive backtracking loops that direct prompting triggers."
> — [Plan Mode: When to Use It](https://claude-ai.chat/blog/plan-mode-in-claude-code-when-to-use-it/)

**理由：**
- 直接指示で始めると、間違った方向に進んだ場合に手戻りループが発生
- 手戻りループは大量のトークンを消費（失敗コード + エラーメッセージ + 修正試行）
- Plan mode の事前投資は、これらのコストを回避する

---

## 3. 新機能実装ワークフローの推奨パターン

### 3.1 パターン A: 小規模機能（1セッションで完了）

**適用条件：** 変更行数 200行以下、1〜2ファイル

```
1. 直接指示でプロンプトに要件を記述
   ├── 対象ファイル
   ├── 入出力の具体例
   ├── 制約条件
   └── テストケース
2. 実装
3. テスト実行・確認
4. コミット
```

**プロンプト例：**
```
Add a rate limiter middleware to our Express app.
- File: src/middleware/rateLimiter.ts
- Follow the pattern in src/middleware/auth.ts
- Limit: 100 requests per minute per IP
- Return 429 status with retry-after header when exceeded
- Write tests covering: normal use, limit exceeded, IP tracking
- Run tests after implementation
```

### 3.2 パターン B: 中規模機能（Plan mode 活用）

**適用条件：** 変更行数 200〜500行、3〜5ファイル

```
1. Plan mode で探索・計画
   ├── 既存コードの理解
   ├── 影響範囲の特定
   └── 実装計画の作成（Ctrl+G で編集）
2. Normal mode に切り替えて実装
3. テスト実行・確認
4. サブエージェントでレビュー
5. コミット・PR
```

### 3.3 パターン C: 大規模機能（Spec-Driven Development）

**適用条件：** 変更行数 500行以上、5ファイル以上、複数セッション

```
セッション0: 要件定義
  └── インタビュー手法で SPEC.md を生成

セッション1: 設計
  └── Plan mode で設計を策定 → specs/design.md

セッション2〜N: 実装（タスクごとに分割）
  ├── タスク1: 基盤コンポーネント → テスト → コミット
  ├── タスク2: ビジネスロジック → テスト → コミット
  ├── タスク3: UI/API 層 → テスト → コミット
  └── タスク4: 統合テスト → コミット

最終セッション: レビュー・統合
  └── サブエージェントで包括的レビュー → PR
```

### 3.4 パターン D: GSD フレームワーク（コンテキスト最適化）

**適用条件：** 複雑なタスクでコンテキスト汚染を防ぎたい場合

> "When you ask Claude to plan, implement, and review code inside a single conversation, you're stacking three cognitively distinct tasks on top of each other."
> — [GSD Framework](https://www.mindstudio.ai/blog/gsd-framework-claude-code-clean-context-phases)

**3フェーズ分離：**

| フェーズ | コンテキスト | 目的 |
|---------|------------|------|
| Plan | 新規セッション | スコープ定義、タスク分解、仕様作成 |
| Execute | 新規セッション（タスクごと） | 仕様に基づくコーディングのみ |
| Review | 新規セッション | 要件に対する評価、問題特定 |

各フェーズで新しいコンテキストを使うことで、コンテキストの劣化（context rot）を防ぐ。

### 3.5 パターン比較表

| パターン | 規模 | Plan mode | SPEC.md | セッション数 | 主なメリット |
|---------|------|-----------|---------|------------|------------|
| A: 小規模直接指示 | 〜200行 | 不使用 | 不要 | 1 | 速い、オーバーヘッドなし |
| B: Plan mode 活用 | 200〜500行 | 使用 | 任意 | 1〜2 | 影響範囲の見落とし防止 |
| C: Spec-Driven | 500行〜 | 使用 | 必須 | 3+ | 大規模変更の品質保証 |
| D: GSD | 複雑 | フェーズ分離 | 必須 | 3+（フェーズ別） | コンテキスト最適化 |

---

## 4. 実践的な Tips

### 4.1 新しいセッションの活用

> "Once the spec is complete, start a fresh session to execute it. The new session has clean context focused entirely on implementation."
> — [Claude Code Best Practices](https://code.claude.com/docs/en/best-practices)

- 仕様策定と実装は**別セッション**で行う
- 各セッション開始時のコンテキスト消費は約 20,000 トークン
- コンテキストが 20〜40% を超えると品質低下が始まる

### 4.2 Git ブランチの活用

> "Always start by having Claude create a new Git branch for every new feature or bug fix."
> — [The Claude Code Handbook](https://www.freecodecamp.org/news/claude-code-handbook/)

- 機能ごとにブランチを作成し、安全網とする
- 失敗した場合はブランチを削除して被害を防ぐ

### 4.3 Writer/Reviewer パターン

実装と品質レビューを別セッションで行うことで、Claude が自分の書いたコードに偏らない客観的なレビューが得られる。

| Session A（実装） | Session B（レビュー） |
|-----------------|-------------------|
| 機能を実装 | `Review the implementation in @src/... Look for edge cases, race conditions` |
| レビューフィードバックを反映 | — |

### 4.4 コンテキスト管理の実践

- タスク間で `/clear` を実行
- 2回以上修正が失敗したら `/clear` して、学んだことを含む改善プロンプトで再開
- 探索はサブエージェントに委譲してメインコンテキストを保護
- `/compact` で重要情報を保持しつつコンテキストを圧縮

---

## まとめ

### 新機能実装の指示パターン選択ガイド

| 判断基準 | 小規模（直接指示） | 中規模（Plan mode） | 大規模（SDD / GSD） |
|---------|-----------------|-------------------|-------------------|
| 変更行数 | 〜200行 | 200〜500行 | 500行〜 |
| ファイル数 | 1〜2 | 3〜5 | 5+ |
| 差分を一文で説明可能か | Yes | No | No |
| アーキテクチャ判断が必要か | No | Maybe | Yes |
| 推奨セッション数 | 1 | 1〜2 | 3+ |
| SPEC.md | 不要 | 任意 | 必須 |
| コスト効率 | 最良（オーバーヘッドなし） | 良好（手戻り防止） | 初期投資大だが大規模では最良 |

### 仕様の書き方の原則

1. **What と Why を先に、How は後から** — AI に具体的な「何を」「なぜ」を伝え、「どう」は任せる
2. **検証手段を必ず含める** — テストケース、スクリーンショット、期待出力のいずれか
3. **制約は少なく、明確に** — ルールが多すぎると無視される。必要最小限の制約を強調付きで
4. **既存パターンを参照する** — コードベース内の模範を具体的に指定
5. **大きな機能は分割する** — 1タスク 200行以下、30分以内を目安に

---

## 参考資料

- [Best Practices for Claude Code](https://code.claude.com/docs/en/best-practices) — 公式ベストプラクティス
- [Claude Code のベストプラクティス（日本語版）](https://code.claude.com/docs/ja/best-practices) — 公式ベストプラクティス日本語版
- [When to Use Plan Mode in Claude Code (And When to Skip It)](https://www.claudecodetutorials.com/learn/posts/when-to-use-plan-mode-in-claude-code-and-when-to-skip-it) — Plan mode の使い分けガイド
- [Plan Mode in Claude Code: When to Use It (and When Not To)](https://claude-ai.chat/blog/plan-mode-in-claude-code-when-to-use-it/) — Plan mode の効率性データ
- [いきなりコードを書かせない。Claude Code「Planモード」のすすめ](https://zenn.dev/ischca/articles/cc-guide-plan-mode) — Plan mode の日本語実践ガイド
- [How to write a good spec for AI agents — Addy Osmani](https://addyosmani.com/blog/good-spec/) — AI エージェント向け仕様書の書き方
- [How to Write a Good Spec for AI Agents — O'Reilly](https://www.oreilly.com/radar/how-to-write-a-good-spec-for-ai-agents/) — O'Reilly 版
- [claude-code-spec-workflow (GitHub)](https://github.com/Pimzino/claude-code-spec-workflow) — Spec-Driven Development ワークフローの実装
- [Spec-Driven Development with Claude Code in Action](https://alexop.dev/posts/spec-driven-development-claude-code-in-action/) — SDD の実践レポート
- [Spec-Driven Development with Claude Code: The 3-Step Framework](https://jingles.dev/articles/claude-spec-plan-loop) — SDD の3ステップフレームワーク
- [GSD Framework for Claude Code](https://www.mindstudio.ai/blog/gsd-framework-claude-code-clean-context-phases) — コンテキスト最適化フレームワーク
- [The Claude Code Handbook (freeCodeCamp)](https://www.freecodecamp.org/news/claude-code-handbook/) — 包括的な Claude Code ガイド
- [How to Stop Letting AI Agents Guess Your Requirements](https://www.freecodecamp.org/news/how-to-stop-letting-ai-agents-guess-your-requirements/) — AI エージェントへの要件伝達
- [Claude CodeのPLAN MODEは使ったほうがいい](https://syu-m-5151.hatenablog.com/entry/2026/02/13/122228) — 日本語の Plan mode 実体験記事
