# 1-3. Plan mode の活用法

## 調査目的

Plan mode が有効なタスクの種類と規模感、やり取りのコツ、Plan mode → 実装の流れの最適パターンを調査し、効果的な活用法を明らかにする。

---

## 1. Plan mode の概要

### Plan mode とは

Plan mode は Claude Code の3つの動作モードの一つで、**ファイル編集やコマンド実行を禁止し、調査・分析・計画に専念させる**モード。「アーキテクトモード」として機能し、コードを読んで計画を立てることはできるが、実際の変更は行わない。

### 3つのモードの比較

| 観点 | Plan mode | 通常モード（Ask before edits） | Auto-Accept モード |
|------|-----------|-------------------------------|-------------------|
| **ファイル編集** | 不可（読み取り専用） | 確認後に可能 | 自動で可能 |
| **コマンド実行** | 不可 | 確認後に可能 | 自動で可能 |
| **ファイル閲覧・検索** | 可能 | 可能 | 可能 |
| **Web 検索** | 可能 | 可能 | 可能 |
| **主な用途** | 調査・計画・設計 | 通常の開発作業 | 定型的な作業の高速化 |
| **表示** | `⏸ plan mode on` | (デフォルト) | `⏵⏵ accept edits on` |

### 起動・操作方法

| 方法 | コマンド |
|------|---------|
| セッション中の切り替え | `Shift+Tab` を2回押す（通常 → Auto-Accept → Plan） |
| 新規セッションを Plan mode で開始 | `claude --permission-mode plan` |
| ヘッドレスモードで Plan mode | `claude --permission-mode plan -p "分析して"` |
| デフォルト設定 | `settings.json` で `"permissions": {"defaultMode": "plan"}` |
| 計画をエディタで編集 | `Ctrl+G` |

### Plan mode の速度特性

> "Plan mode works incredibly fast — since Claude isn't executing tools or writing files, responses are lightning quick and use fewer tokens."

ツール実行やファイル書き込みがないため、**レスポンスが速くトークン消費が少ない**。

---

## 2. Plan mode が有効なタスクの種類と規模感

### 有効なケース

| ケース | 理由 |
|--------|------|
| **複数ファイルにまたがる変更** | 影響範囲の見落としを防ぐ |
| **コードベースの探索** | 変更前に構造を徹底的に理解できる |
| **対話的な設計** | Claude と方針をすり合わせながら進められる |
| **複雑なリファクタリング** | OAuth2 移行のような大規模変更の事前計画 |
| **不慣れなコードベースでの作業** | アプローチに自信がない場合に安全 |

### Plan mode を使わなくてよいケース

> "If you could describe the diff in one sentence, skip the plan."
> — [Best Practices](https://code.claude.com/docs/en/best-practices)

**差分を一文で説明できるなら、計画はスキップせよ。**

### 規模感の目安

- **30分以内で完了する機能**を Plan mode で計画し、実装に移すのが「小さく回す」アプローチとして推奨
- **一つのセッションに収まらないリファクタリング**は、機能ごとに分割して別々の Plan を立てる

### Plan mode を使うべきかの判断フロー

```
差分を一文で説明できる？
  → Yes → Plan mode 不要、直接実装
  → No → 複数ファイルに影響する？ or アプローチに自信がない？
    → Yes → Plan mode を使う
    → No → 通常モードで十分
```

---

## 3. Plan mode でのやり取りのコツ

### 最初の計画を即承認しない

> "Don't accept the first plan, refine it, ask follow-up questions, and ensure it addresses edge cases."

> "Most multi-file refactors go through 2-3 plan revisions before they're done."

**2〜3回の改訂が普通**。最初の計画をそのまま受け入れず、以下の観点でレビューする。

### 計画のレビューで確認すべき5項目

1. **ゴール** — 何を達成したいかが明確か
2. **背景・制約** — なぜ必要かが反映されているか
3. **受け入れ基準** — どうなったら完了かが定義されているか
4. **禁止事項** — やってはいけないことが考慮されているか
5. **想定外の問題への対応** — エッジケースが検討されているか

### 具体的なフィードバックの与え方

| 確認観点 | 質問例 |
|---------|--------|
| 実装順序の妥当性 | 「共通ユーティリティを先に作る順序になっているか？」 |
| テストの有無 | 「テストステップが含まれているか？なければ追加して」 |
| 後方互換性 | 「What about backward compatibility?」 |
| データ移行 | 「How should we handle database migration?」 |
| エッジケース | 「認証トークン期限切れ時の挙動は？」 |

### Ctrl+G による計画の直接編集

`Ctrl+G` を押すと計画がデフォルトのテキストエディタで開き、**直接編集してから Claude に渡せる**。口頭で修正を指示するよりも効率的。

### インタビュー手法（大規模タスク向け）

大きな機能の場合、最初から詳細な指示を書くのではなく、**Claude に「インタビューさせる」**テクニックが公式ベストプラクティスで推奨されている：

```
I want to build [brief description]. Interview me in detail
using the AskUserQuestion tool. Ask about technical implementation,
UI/UX, edge cases, concerns, and tradeoffs. Don't ask obvious
questions, dig into the hard parts I might not have considered.
```

Claude が質問を通じて要件を掘り下げてくれるため、自分が見落としていた課題に気づける。

---

## 4. Plan mode → 実装の流れの最適パターン

### 公式推奨の4フェーズワークフロー

> "Explore first, then plan, then code"
> — [Best Practices](https://code.claude.com/docs/en/best-practices)

> "Separate research and planning from implementation to avoid solving the wrong problem."

#### Phase 1: Explore（探索）— Plan Mode

ファイルを読ませ、質問に答えさせる（変更はしない）。

```
read /src/auth and understand how we handle sessions and login.
also look at how we manage environment variables for secrets.
```

#### Phase 2: Plan（計画）— Plan Mode

詳細な実装計画を作成させる。

```
I want to add Google OAuth. What files need to change?
What's the session flow? Create a plan.
```

計画に不足があれば `Ctrl+G` で直接編集、または口頭でフィードバック。

#### Phase 3: Implement（実装）— Normal Mode に切り替え

`Shift+Tab` で通常モードに切り替え、計画に基づいてコーディング。

```
implement the OAuth flow from your plan. write tests for the
callback handler, run the test suite and fix any failures.
```

#### Phase 4: Commit（コミット）

```
commit with a descriptive message and open a PR
```

### 「小さく回す」パターン

```
Plan mode で30分以内の機能を計画
  → Normal mode で実装
    → 動作確認
      → Git コミット
        → 次の機能へ
```

### 大規模リファクタリングの分割パターン

一つのセッションに収まらない場合は、機能ごとに Plan を分割する：

1. セッション1: 認証機能の抽出を Plan → 実装 → コミット
2. セッション2: ルート分割の Plan → 実装 → コミット
3. セッション3: テスト追加の Plan → 実装 → コミット

各セッションの冒頭で前回のコミットを確認し、コンテキストを引き継ぐ。

---

## 5. Extended Thinking との併用

### Plan mode と Extended Thinking の違い

| 機能 | 目的 | 発動方法 |
|------|------|---------|
| **Plan mode** | ツール操作を制限し、調査・計画に専念 | `Shift+Tab` / `--permission-mode plan` |
| **Extended Thinking** | Claude に深く思考させる | 「think」「think hard」等のフレーズ |

両者は**補完的に機能**する。Plan mode で Extended Thinking を併用することで、より深い分析に基づいた計画が得られる。

### 活用例

```
(Plan mode で)
think hard about the authentication system architecture.
analyze potential race conditions and security implications.
```

---

## 6. 計画なしで実装するリスク

> 「計画なしで実装すると、前提認識のズレや影響範囲の見落としが発生しやすくなります」
> — [いきなりコードを書かせない。Claude Code「Planモード」のすすめ](https://zenn.dev/ischca/articles/cc-guide-plan-mode)

> "Letting Claude jump straight to coding can produce code that solves the wrong problem."
> — [Best Practices](https://code.claude.com/docs/en/best-practices)

Plan mode を使わずにいきなりコーディングを始めると：

- **間違った問題を解くコード**が生成される可能性がある
- 前提認識のズレが後工程で発覚し、手戻りが大きくなる
- 影響範囲の見落としにより、既存機能を壊すリスクが高まる

### 安全策としての Git

> 「どのモードを使っても、Gitで管理しておく…最大の安全策」
> — [Claude Codeの3つのモード完全ガイド](https://zenn.dev/yamato_snow/articles/ba861099a214b7)

Plan mode を使っていても、実装フェーズでは予期しない変更が生じる可能性がある。Git で頻繁にコミットし、必要に応じてロールバックできるようにしておくことが重要。

---

## 総合的なベストプラクティス

### Plan mode 運用の原則

1. **「一文で説明できるか」テスト**: 差分を一文で説明できるなら Plan mode は不要
2. **最初の計画を即承認しない**: 2〜3回の改訂を前提とする
3. **Explore → Plan → Implement → Commit** の4フェーズを意識する
4. **大きなタスクは分割**: 30分以内の単位に分けて「小さく回す」
5. **Ctrl+G を活用**: 計画をエディタで直接編集する方が効率的
6. **Extended Thinking と併用**: 深い分析が必要な場合は「think hard」を組み合わせる
7. **Git を安全網にする**: 実装フェーズでは頻繁にコミット

---

## 調査ソース

- [Best Practices for Claude Code](https://code.claude.com/docs/en/best-practices) — 公式ベストプラクティス（Explore first, then plan, then code セクション）
- [Common Workflows - Claude Code Docs](https://code.claude.com/docs/en/common-workflows) — 公式リファレンス（Use Plan Mode for safe code analysis セクション）
- [いきなりコードを書かせない。Claude Code「Planモード」のすすめ](https://zenn.dev/ischca/articles/cc-guide-plan-mode) — Plan mode の包括的な日本語解説
- [Claude Codeの3つのモード完全ガイド](https://zenn.dev/yamato_snow/articles/ba861099a214b7) — 3モードの比較と使い分け
- [Claude Code公式ベストプラクティス徹底解説](https://zenn.dev/tmasuyama1114/articles/claude_code_best_practice_202601) — 日本語による公式プラクティス解説
- [Anthropic社員のClaude Code活用術8選](https://zenn.dev/happy_elements/articles/046faa4f61d98f) — Anthropic 社員の活用テクニック
- [Claude Code の Plan Mode 完全ガイド](https://qiita.com/NaokiIshimura/items/5fcc70c0a133c1d29ca5) — Qiita による包括的ガイド
- [Claude CodeのPlanモードを駆使し、楽に品質を担保してみた](https://tech.willgate.co.jp/entry/2025/09/17/120000) — WILLGATE TECH BLOG の実践記事
- [Claude CodeのPLAN MODEは使ったほうがいい](https://syu-m-5151.hatenablog.com/entry/2026/02/13/122228) — はてなブログの実体験記事
- [50 Claude Code Tips and Best Practices](https://www.builder.io/blog/claude-code-tips-best-practices) — Builder.io の Tips 集
