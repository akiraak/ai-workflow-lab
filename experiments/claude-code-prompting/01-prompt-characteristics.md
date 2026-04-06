# 1-1. 対話プロンプト（直接指示）の特性

## 調査目的

Claude Code に対話的に指示を出す際の特性を理解し、効果的なプロンプトの書き方を明らかにする。

---

## 1. 指示の粒度（曖昧 vs 具体的）による出力差

### 公式見解

> "The more precise your instructions, the fewer corrections you'll need."
> （指示がより正確であるほど、必要な修正が少なくなる）
> — [Claude Code Best Practices](https://code.claude.com/docs/en/best-practices)

Claude Code の公式ドキュメントは、具体的な指示を一貫して推奨している。ただし、曖昧なプロンプトにも価値がある場面を認めている。

### 具体的な指示が効果的な場面

公式が提示する Before/After の比較例：

| 戦略 | 曖昧（Before） | 具体的（After） |
|------|---------------|----------------|
| タスクのスコープ | "add tests for foo.py" | "write a test for foo.py covering the edge case where the user is logged out. avoid mocks." |
| ソースの指定 | "why does ExecutionFactory have such a weird api?" | "look through ExecutionFactory's git history and summarize how its api came to be" |
| パターンの参照 | "add a calendar widget" | "look at how existing widgets are implemented on the home page. HotDogWidget.php is a good example. follow the pattern..." |
| 症状の記述 | "fix the login bug" | "users report that login fails after session timeout. check the auth flow in src/auth/, especially token refresh. write a failing test that reproduces the issue, then fix it" |
| 検証基準 | "implement a function that validates email addresses" | "write a validateEmail function. example test cases: user@example.com is true, invalid is false, user@.com is false. run the tests after implementing" |
| UI変更 | "make the dashboard look better" | "[paste screenshot] implement this design. take a screenshot of the result and compare it to the original" |

### 具体的な指示に含めるべき要素

公式ドキュメントと実践ガイドの知見を総合すると、効果的な具体的指示には以下が含まれる：

1. **対象ファイル/スコープ** — どのファイル・ディレクトリを操作するか
2. **制約条件** — 使うべきライブラリ、避けるべきアプローチ
3. **既存パターンの参照** — コードベース内の模範となる実装を指定
4. **検証方法** — テストケース、期待される出力、スクリーンショット
5. **症状と期待結果** — 現状の問題と修正後のあるべき姿

### 曖昧なプロンプトが有効な場面

> "Vague prompts can be useful when you're exploring and can afford to course-correct."
> — [Claude Code Best Practices](https://code.claude.com/docs/en/best-practices)

以下の場面では、あえて曖昧な指示が効果的：

- **探索的な質問**: "what would you improve in this file?" のように、自分が気づかない問題を表面化させたい場合
- **コードベースの学習**: シニアエンジニアに質問するように「How does logging work?」と聞く場合
- **アプローチが不明な場合**: Claude がどう解釈するか見てから制約を加える場合

### 指示の粒度に関するまとめ

| 粒度 | 向いている場面 | リスク |
|------|---------------|--------|
| 具体的 | 修正内容が明確、複数ファイル変更、検証が必要 | 過剰指定で柔軟性を失う |
| 曖昧 | 探索・学習、アプローチ未定、問題の発見 | 意図と異なる方向に進む |

**実用的な指針**: 差分を1文で説明できるなら直接実行、できなければ計画モードで探索してから具体化する。

---

## 2. 1回の指示に含める情報量の適切な範囲

### コンテキストウィンドウが最重要制約

> "Most best practices are based on one constraint: Claude's context window fills up fast, and performance degrades as it fills."
> — [Claude Code Best Practices](https://code.claude.com/docs/en/best-practices)

Claude Code のパフォーマンスは**コンテキストウィンドウの使用量**に大きく依存する。窓が埋まるにつれて：
- 以前の指示を「忘れる」ことがある
- ミスが増える
- 応答品質が低下する

### 1回のプロンプトの適切な情報量

#### 含めるべき情報

1. **タスクの明確な定義** — 何をしてほしいか
2. **対象の特定** — ファイルパス、関数名、エラーメッセージ
3. **制約と検証方法** — テストケース、期待出力
4. **参照パターン** — 既存コードの模範例（`@` で参照が効率的）

#### 含めるべきでない情報

1. **関係ない文脈** — 別のタスクの情報
2. **Claude が推測できること** — コードを読めばわかる標準的な規約
3. **過剰な説明** — チュートリアルレベルの長い説明

### モードの分離（4つのモード理論）

コミュニティで提唱されている実践的なフレームワーク（[Stéphane Derosiaux](https://sderosiaux.medium.com/how-i-learned-to-prompt-ai-better-my-four-modes-177bddcfa6bd)）：

| モード | 目的 | 含める情報 |
|--------|------|-----------|
| ビルド | 「使えるものをくれ」 | 具体的で短い要件のみ |
| デバッグ | 「なぜこうなる？」 | ログ、バージョン、最小限の再現コード |
| リライト | 「これを改善して」 | 対象のコード＋改善の方向性 |
| ラーニング | 「教えて」 | 自分の知識レベルと学びたいこと |

**重要**: モードを混在させない。1つのプロンプトで「学習＋改善＋構築」を求めると出力が散漫になる。

### セッション管理の原則

| 状況 | 対処法 |
|------|--------|
| 別のタスクに移る | `/clear` でコンテキストをリセット |
| 2回修正してもうまくいかない | `/clear` して学んだことを込めた新しいプロンプトを書く |
| 大量のファイル探索が必要 | サブエージェントに委譲してメインコンテキストを保護 |
| コンテキストが膨らんだ | `/compact` で要約 |
| 一時的な質問 | `/btw` でコンテキストに残さない |

### 思考の深さの制御

Claude Code では思考キーワードで推論の深さを制御できる（[zenn.dev 実践ガイド](https://zenn.dev/hokuto_tech/articles/86d1edb33da61a)）：

| キーワード | 効果 |
|-----------|------|
| `think` | 基本的な思考 |
| `think hard` | より深い思考 |
| `ultrathink` | 最大限の思考時間 |

1-2回の実行でうまくいかない場合に `ultrathink` を付けると解決することが多いとされる。

### 情報量に関するまとめ

**原則**: 1つのプロンプトには「1つのタスク＋必要最小限のコンテキスト＋検証方法」を含める。それ以上は分割するか、サブエージェントに委譲する。

---

## 3. 日本語 vs 英語での指示精度の違い

### 公式ベンチマークデータ

Anthropic が公開している多言語パフォーマンスデータ（[Multilingual Support](https://platform.claude.com/docs/en/build-with-claude/multilingual-support)）によると、MMLU ベンチマークでの日本語の対英語相対スコアは：

| モデル | 日本語の対英語比 |
|--------|----------------|
| Claude Opus 4.1 | 96.9% |
| Claude Opus 4 | 96.2% |
| Claude Sonnet 4.5 | 96.8% |
| Claude Sonnet 4 | 95.6% |
| Claude Haiku 4.5 | 93.5% |

**日本語は英語比で約 96-97% の性能**を発揮する。これはスペイン語（98%）やフランス語（97.9%）に次ぐ高い水準で、実用上の差は小さい。

### 実践的な使い分けの指針

コミュニティの知見（[izanami.dev](https://izanami.dev/post/0197d01e-fb29-4e24-b97f-1d07a6478604)、[zenn.dev](https://zenn.dev/hokuto_tech/articles/86d1edb33da61a)）を総合すると：

| 観点 | 日本語が適する場面 | 英語が適する場面 |
|------|------------------|----------------|
| 要件の複雑さ | 複雑な要件を詳細に伝えたい時 | 簡潔な技術的指示 |
| 技術用語 | 日本語の技術概念を扱う時 | 英語の技術文書と一致する用語を使いたい時 |
| ドキュメント参照 | 日本語ドキュメントを参照する場合 | 海外の事例・ドキュメントに沿う場合 |
| 自然さ | 母語で考えたほうが正確に伝えられる場合 | 技術的な定型表現がある場合 |

### 重要な知見

1. **「Claudeは日本語でも高いパフォーマンスを発揮する」** — 英語に切り替える必要性は低い
2. **英語の文法の完璧さは不要** — Claude は文脈から意図を理解できる
3. **音声入力の活用** — 日本語音声入力で背景・理由・期待結果を自然に含めやすい（Superwhisper等）
4. **混合アプローチ** — 技術用語は英語、説明は日本語という混合が実用的
5. **公式ドキュメントの日本語対応** — Claude Code の公式ベストプラクティスは日本語翻訳版が提供されている

### 日本語利用における実用的なティップス

- **コードのコメント・変数名に合わせる**: コードベースが英語なら指示も英語、日本語コメント中心なら日本語
- **エラーメッセージはそのまま貼る**: 英語のエラーメッセージを翻訳せずそのまま含める方が正確
- **明示的な言語指定**: 出力言語を明示すると安定する（「日本語で説明して」「Reply in English」）

---

## 総合的なベストプラクティス

### 効果的なプロンプトの構成要素

```
[タスクの種類と目的]
[対象ファイル/スコープ] ← @ でファイル参照
[制約条件]
[既存パターンの参照]
[検証方法/成功基準]
```

### 公式推奨の4段階ワークフロー

1. **探索（Plan Mode）** — コードベースを読んで理解する
2. **計画（Plan Mode）** — 実装計画を立てる
3. **実装（Normal Mode）** — コーディングし、テストで検証する
4. **コミット** — 説明的なメッセージでコミット＋PR

### アンチパターン

| パターン | 問題 | 対処 |
|---------|------|------|
| キッチンシンク | 無関係なタスクが混在 | タスク間で `/clear` |
| 修正ループ | 失敗アプローチでコンテキスト汚染 | 2回失敗したら `/clear` して新プロンプト |
| 過剰指定 | CLAUDE.md や指示が長すぎて無視される | 必要最小限に剪定 |
| 検証なし | もっともらしいが動かないコード | テスト・スクリーンショット等の検証手段を必ず含める |
| 無限探索 | スコープなしの調査でコンテキスト枯渇 | スコープ限定 or サブエージェント |

---

## 調査ソース

- [Best Practices for Claude Code](https://code.claude.com/docs/en/best-practices) — 公式ベストプラクティス
- [Claude Code のベストプラクティス](https://code.claude.com/docs/ja/best-practices) — 公式ベストプラクティス（日本語版）
- [Claude Code overview](https://code.claude.com/docs/en/overview) — 公式概要
- [Prompting best practices (Claude API)](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/claude-prompting-best-practices) — API レベルのプロンプトガイド
- [Multilingual support](https://platform.claude.com/docs/en/build-with-claude/multilingual-support) — 多言語パフォーマンスデータ
- [Claude Code - 英語プロンプトで開発スキルを広げる](https://izanami.dev/post/0197d01e-fb29-4e24-b97f-1d07a6478604) — 日英使い分けの実践記事
- [Claude Code Prompting Guide 2025](https://smartscope.blog/en/generative-ai/claude/claude-code-prompting-official-guidelines-2025/) — 公式ガイドライン解説
- [How I Learned to Prompt Claude Code Better — Four Modes](https://sderosiaux.medium.com/how-i-learned-to-prompt-ai-better-my-four-modes-177bddcfa6bd) — 4モード理論
- [Claude Code を初めて使う人向けの実践ガイド](https://zenn.dev/hokuto_tech/articles/86d1edb33da61a) — 日本語実践ガイド
