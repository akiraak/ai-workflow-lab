# 2-3. リファクタリングタスクにおける指示パターン

## 調査目的

Claude Code でリファクタリングを行う際の効果的な指示パターンを調査する。特に「対象範囲の指定方法」と「指示の具体度」がリファクタリング品質にどう影響するかを明らかにする。

---

## 1. 対象範囲の指定方法

### 明示的なファイル指定 vs 自動探索の比較

リファクタリングの対象範囲を Claude Code に伝える方法は大きく2つに分かれる。

| 方法 | 概要 | 向いている場面 |
|------|------|---------------|
| **明示的ファイル指定** | `@src/auth/login.ts` のように対象ファイルを直接参照 | 変更範囲が明確、小〜中規模のリファクタリング |
| **自動探索に委ねる** | 「認証モジュールのリファクタリング」のように目的だけ伝える | コードベースの全体把握が目的、影響範囲が不明確 |

#### 明示的ファイル指定の利点

公式ドキュメントは「`@` でファイルを参照する」方法を推奨している。

> "Reference files with `@` instead of describing where code lives. Claude reads the file before responding."
> — [Claude Code Best Practices](https://code.claude.com/docs/en/best-practices)

実務上の利点：

1. **コンテキスト消費の予測可能性** — 読み込むファイルが明確なため、コンテキストウィンドウの使用量を管理しやすい
2. **探索フェーズのスキップ** — Claude がファイルを検索する必要がなく、直接リファクタリングに着手できる
3. **意図しないファイル変更の防止** — スコープが明確なため、関係ないファイルを変更するリスクが低い

プロンプト例：

```
@src/utils/auth.js をリファクタリングしてください。
- async/await に統一（コールバック廃止）
- エラーハンドリングを try-catch に変更
- 既存のテストが通ることを確認
```

#### 自動探索の利点と注意点

対象範囲が不明確な場合は、Claude に探索させるアプローチが有効だが、大きなリスクを伴う。

> "The infinite exploration. You ask Claude to 'investigate' something without scoping it. Claude reads hundreds of files, filling the context."
> — [Claude Code Best Practices](https://code.claude.com/docs/en/best-practices)

**自動探索を安全に使うための対策**:

| 対策 | 方法 |
|------|------|
| サブエージェントに委譲 | `"use subagents to investigate how our authentication system handles token refresh"` |
| Plan Mode で探索 | Shift+Tab でプランモードに切り替え、読み取り専用で調査 |
| スコープの制限 | `"src/auth/ ディレクトリ内のみを対象に"` のように範囲を限定 |

### コンテキストウィンドウと対象ファイル数の関係

リファクタリング品質はコンテキストウィンドウの使用量に直接影響される。

> "Plans that touch seven or more files start to lose quality because the context window fills up during execution."
> — [DataCamp: Claude Code Plan Mode](https://www.datacamp.com/tutorial/claude-code-plan-mode)

> "Claude's output degrades at 20-40% of the context window well before any limit."
> — [F22 Labs: Claude Code Tips](https://www.f22labs.com/blogs/10-claude-code-productivity-tips-for-every-developer/)

推奨されるコンテキスト管理ルール：

| ルール | 詳細 |
|--------|------|
| **60%で圧縮** | コンテキストの60%到達時に `/compact` を実行（90%まで待たない） |
| **7ファイル上限** | 1回のセッションで変更するファイル数は7未満に抑える |
| **120kトークン制限** | セッションあたりの入力トークンを120k以下に制限 |
| **最後の20%は避ける** | コンテキストの最後の20%で複雑なマルチファイルタスクを行わない |

### ファイル数別の推奨アプローチ

| 変更ファイル数 | 推奨アプローチ | Plan Mode |
|---------------|---------------|-----------|
| 1-2ファイル | 直接指示で実行 | 不要 |
| 3-6ファイル | Plan Mode で計画→実行 | 推奨 |
| 7ファイル以上 | タスク分割→バッチ実行 | 必須（分割単位ごと） |
| 大規模移行 | `claude -p` でファイルごとに並列実行 | 不要（スクリプト化） |

公式ドキュメントの大規模移行パターン：

> 1. Generate a task list: "list all 2,000 Python files that need migrating"
> 2. Write a script to loop through the list
> 3. Test on a few files, then run at scale
> — [Claude Code Best Practices](https://code.claude.com/docs/en/best-practices)

---

## 2. リファクタリング手法の具体度と出力品質

### 抽象的指示 vs 具体的指示の比較

リファクタリング指示の具体度は出力品質に決定的な影響を与える。

> "The more precise your instructions, the fewer corrections you'll need."
> — [Claude Code Best Practices](https://code.claude.com/docs/en/best-practices)

以下の比較表は、実践者の報告とコミュニティの知見を総合したものである。

| 具体度 | 指示例 | 品質 | リスク |
|--------|--------|------|--------|
| **低**（抽象的） | "このコードをリファクタリングして" | 低〜中 | 意図しない変更、振る舞い変更 |
| **中**（方向性あり） | "関数を分割して可読性を上げて" | 中 | 分割粒度がずれる可能性 |
| **高**（手法指定） | "メソッド抽出のみ行い、ロジックは変更しない。関数は50行以内に" | 高 | 過剰指定で柔軟性を失う |
| **最高**（測定基準付き） | "async/await に統一、エラーを try-catch に変更、テスト実行で確認" | 最高 | 指示作成のコスト |

#### 抽象的指示の失敗パターン

日本語コミュニティでの報告：

> 「いい感じにして」「もっときれいに書いて」など、抽象的な指示では期待通りの結果が得られません。
> — [ENECHANGE Developer Blog](https://tech.enechange.co.jp/entry/2025/07/14/144750)

> Claude Code はリファクタリング操作中に、明示的に機能を保持するよう指示されていても、コードの振る舞いを変更してしまうことがある。
> — [Qiita: Claude Code はなぜリファクタリングが苦手なのか？](https://qiita.com/Shoyu_N/items/2532f6871b5fba97c549)

英語コミュニティでも同様の報告がある。10,000行の Java コードをリファクタリングした事例では、テストは通ったが本番で127のバグが発生した：

> "AI doesn't understand why code is ugly — in legacy systems, ugly code is often correct code."
> — [Dev Genius: I Let AI Refactor Our Legacy Codebase](https://blog.devgenius.io/i-let-ai-refactor-our-legacy-codebase-it-created-127-new-bugs-344b56bc0a62)

#### 具体的指示の効果的なパターン

コミュニティで高い評価を得ている指示パターン：

**パターン1: リファクタリング手法の明示**

```
@src/utils.js をリファクタリングしてください。
- メソッド抽出のみ行う（ロジックの変更は禁止）
- 1関数は50行以内
- 各関数に JSDoc コメントを追加
- 変更後、既存テストを実行して合格を確認
```

**パターン2: Before/After の具体例を提示**

```
この関数のネストされたコールバックを async/await に変換してください。
振る舞いは完全に同一に保ってください。

変換前パターン: fs.readFile(path, (err, data) => { ... })
変換後パターン: const data = await fs.readFile(path)
```

**パターン3: コードベース内パターンの参照**

> "look at how existing widgets are implemented on the home page. HotDogWidget.php is a good example. follow the pattern..."
> — [Claude Code Best Practices](https://code.claude.com/docs/en/best-practices)

```
@src/components/HotDogWidget.tsx のパターンに従って、
@src/components/CalendarWidget.tsx をリファクタリングしてください。
特に状態管理とエラーハンドリングのパターンを統一してください。
```

### 計画先行アプローチの効果

リファクタリングの前に計画を立てさせることで品質が大幅に向上する。

> 「まずはリファクタリングの計画を立ててください。例えば、1．コメントアウトされたコードの削除、2．マジックナンバーの定義化など、順を追ってください。まだコードは変更しないでください。」
> 最初に「ソースコードをリファクタリングしてください。」とだけ指示した場合と比べて、より成功しやすい。
> — [ENECHANGE Developer Blog](https://tech.enechange.co.jp/entry/2025/07/14/144750)

計画先行アプローチの具体的な手順：

1. **Plan Mode に切り替え**（Shift+Tab を2回）
2. **分析を依頼**: 「このモジュールの現状を分析して、リファクタリング計画を作成してください」
3. **計画をレビュー**: Ctrl+G で計画をエディタで開き直接編集
4. **計画を plan.md に書き出し**: 後で参照できるようにする
5. **Normal Mode で段階的に実行**: 計画の各ステップを順に実行

> "A stronger plan uses test-driven development (TDD) and interleaves testing with implementation: write tests for auth/ before extracting the auth functions, confirm they pass, then write tests for posts/ before pulling out routes."
> — [DataCamp: Claude Code Plan Mode](https://www.datacamp.com/tutorial/claude-code-plan-mode)

### 検証方法の指定が品質を決定する

> "Give Claude a feedback loop so it catches its own mistakes by including test commands, linter checks, or expected outputs in your prompt. Feedback loops alone give a 2-3x quality improvement."
> — [F22 Labs: Claude Code Tips](https://www.f22labs.com/blogs/10-claude-code-productivity-tips-for-every-developer/)

リファクタリングにおける検証指示のテンプレート：

```
リファクタリング後、以下を確認してください：
1. `npm test` で全テストが通ること
2. `npm run lint` でエラーがないこと
3. 変更前後で外部インターフェースが変わっていないこと
4. 型チェック（`npx tsc --noEmit`）が通ること
```

---

## 3. リファクタリングワークフローの推奨パターン

### 基本ワークフロー（小〜中規模）

公式ドキュメントが推奨する4フェーズ：

```
[Explore] → [Plan] → [Implement] → [Verify & Commit]
```

> "Separate research and planning from implementation to avoid solving the wrong problem."
> — [Claude Code Best Practices](https://code.claude.com/docs/en/best-practices)

### TDD インターリービング（中規模）

テスト駆動のリファクタリングパターン：

```
1. テストを書く（振る舞いを固定）
   → "write characterization tests for @src/auth/login.ts"

2. テスト通過を確認
   → "run the tests"

3. リファクタリング実行
   → "refactor login.ts: extract token refresh into a separate function"

4. テスト再実行で振る舞い保持を確認
   → "run the tests again to verify behavior is preserved"

5. コミット
   → "commit with a descriptive message"
```

> "Understand the code by asking Claude to explain legacy functions, map dependencies, and surface hidden logic, then generate characterization tests to lock in current behavior before touching anything."
> — [F22 Labs: Claude Code Tips](https://www.f22labs.com/blogs/10-claude-code-productivity-tips-for-every-developer/)

### Strangler Fig パターン（大規模レガシー移行）

レガシーコードの段階的な移行には Strangler Fig パターンが有効。Zenn の事例では以下の成果が報告されている：

| 指標 | 改善率 |
|------|--------|
| コード行数 | 36%削減 |
| バンドルサイズ | 51%削減 |
| テストカバレッジ | 0% → 82% |
| 新機能追加速度 | 3日 → 1日 |

> — [Zenn: 既存プロジェクトをClaude Codeでリファクタリング](https://zenn.dev/sexygo/articles/claude-code-refactoring-guide)

フェーズ構成：

1. **環境構築**: 現状分析、共存設定
2. **状態管理の移行**: 互換性レイヤーを維持しながら段階移行
3. **UIコンポーネント化**: 個別機能を新技術で再実装
4. **段階的置き換え**: 既存コードとの共存を保ちながら順次切り替え

### 大規模バッチ移行（ファイル単位の並列処理）

数百〜数千ファイルの一括リファクタリングにはスクリプト化が推奨される：

```bash
for file in $(cat files.txt); do
  claude -p "Migrate $file from React to Vue. Return OK or FAIL." \
    --allowedTools "Edit,Bash(git commit *)"
done
```

> "Refine your prompt based on what goes wrong with the first 2-3 files, then run on the full set."
> — [Claude Code Best Practices](https://code.claude.com/docs/en/best-practices)

### Writer/Reviewer パターン

リファクタリングの品質を高めるために、2つのセッションを使い分ける：

| セッションA（Writer） | セッションB（Reviewer） |
|-----------------------|------------------------|
| リファクタリングを実行 | 変更内容をレビュー |
| `"refactor utils.js to use ES2024 features"` | `"Review the refactored @src/utils.js. Check for edge cases, behavior changes, and consistency."` |
| レビューのフィードバックを反映 | — |

> "A fresh context improves code review since Claude won't be biased toward code it just wrote."
> — [Claude Code Best Practices](https://code.claude.com/docs/en/best-practices)

### CLAUDE.md によるリファクタリング品質の底上げ

CLAUDE.md にリファクタリング時の規約を記載することで、セッション横断的な品質を維持できる：

```markdown
# Refactoring rules
- Never change external behavior during refactoring
- Use the simplest possible approach
- Run tests after every file change
- Keep functions under 50 lines
- Prefer extracting functions over inlining
```

> "Claude writes extra abstractions, unsolicited helper functions, and premature refactoring unless you tell it not to — adding 'use the simplest possible approach' to your CLAUDE.md helps."
> — [F22 Labs: Claude Code Tips](https://www.f22labs.com/blogs/10-claude-code-productivity-tips-for-every-developer/)

### Skill によるリファクタリングワークフローの定型化

再利用可能なリファクタリングワークフローを `.claude/skills/` に定義できる：

```markdown
# .claude/skills/refactor/SKILL.md
---
name: refactor
description: Safe refactoring workflow
---
Refactor the specified code: $ARGUMENTS

1. Read the target files and understand current behavior
2. Write characterization tests if none exist
3. Run tests to confirm they pass
4. Apply the requested refactoring
5. Run tests to confirm behavior is preserved
6. Run linter and type checker
7. Create a descriptive commit
```

---

## 4. リファクタリング時の典型的な失敗パターンと対策

### 失敗パターン一覧

| 失敗パターン | 原因 | 対策 |
|-------------|------|------|
| **振る舞いの意図しない変更** | 抽象的指示、テスト不足 | テスト先行、「ロジック変更禁止」を明示 |
| **マルチファイルでの一貫性喪失** | コンテキスト超過 | 7ファイル以下に制限、タスク分割 |
| **セッション劣化** | 長時間セッション | 3時間以上は `/clear` で新規セッション |
| **暗黙知の見落とし** | レガシーコードの文脈理解不足 | 計画先行、サブエージェントで調査 |
| **過剰な抽象化** | Claude の傾向として不要な抽象を作りがち | CLAUDE.md に「最もシンプルなアプローチ」を指定 |

> "When refactoring entire modules, Claude changes one file and loses context of what changed in others, requiring an hour to untangle inconsistencies — the fix is to refactor one file at a time."
> — [Dev Genius](https://blog.devgenius.io/i-let-ai-refactor-our-legacy-codebase-it-created-127-new-bugs-344b56bc0a62)

> "By hour 3 of a long session, Claude Code starts making decisions based on what it already wrote, not what's best — fresh sessions provide fresh perspective."
> — [Dev Genius](https://blog.devgenius.io/i-let-ai-refactor-our-legacy-codebase-it-created-127-new-bugs-344b56bc0a62)

---

## まとめ

### リファクタリング指示の実践ガイドライン

| 観点 | 推奨 | 避けるべき |
|------|------|-----------|
| **範囲指定** | `@` でファイルを明示、ディレクトリ単位で制限 | 「全体をきれいにして」のような無制限指示 |
| **指示の具体度** | リファクタリング手法を名指し（メソッド抽出、async化等） | 「いい感じにリファクタリング」 |
| **計画** | Plan Mode で先に計画、plan.md に書き出し | いきなりリファクタリング実行 |
| **検証** | テストコマンド、リンター、型チェックを指示に含める | 目視のみの確認 |
| **セッション管理** | 1タスク1セッション、7ファイル以下 | 長時間セッションで複数タスク |
| **振る舞い保持** | 「ロジック変更禁止」「外部インターフェース維持」を明示 | 暗黙の期待 |

### リファクタリング品質を高める3つの鉄則

1. **テストを先に書く** — 振る舞いを固定してからリファクタリングする。テストがない場合はまず characterization test を生成する
2. **小さく刻む** — 1回の変更は7ファイル以下。大規模移行はスクリプト化して並列処理する
3. **検証ループを組み込む** — テスト実行、リンター、型チェックを指示に必ず含める。これだけで品質が2-3倍向上する

---

## 参考資料

- [Best Practices for Claude Code](https://code.claude.com/docs/en/best-practices) — 公式ベストプラクティス
- [Common workflows - Claude Code Docs](https://code.claude.com/docs/en/common-workflows) — 公式ワークフローガイド
- [既存プロジェクトをClaude Codeでリファクタリング（Zenn）](https://zenn.dev/sexygo/articles/claude-code-refactoring-guide) — Strangler Fig パターンの実践例
- [50 Claude Code Tips and Best Practices（Builder.io）](https://www.builder.io/blog/claude-code-tips-best-practices) — 50の実践 Tips
- [I Let AI Refactor Our Legacy Codebase（Dev Genius）](https://blog.devgenius.io/i-let-ai-refactor-our-legacy-codebase-it-created-127-new-bugs-344b56bc0a62) — 127バグの教訓
- [Claude Code Plan Mode: Design Review-First Refactoring Loops（DataCamp）](https://www.datacamp.com/tutorial/claude-code-plan-mode) — Plan Mode 活用法
- [How to effectively utilise AI to enhance large-scale refactoring（Atlassian）](https://www.atlassian.com/blog/developer/how-to-effectively-utilise-ai-to-enhance-large-scale-refactoring) — 大規模リファクタリング戦略
- [Claude Code Tips: 10 Real Productivity Workflows（F22 Labs）](https://www.f22labs.com/blogs/10-claude-code-productivity-tips-for-every-developer/) — 生産性ワークフロー
- [Claude Code はなぜリファクタリングが苦手なのか？（Qiita）](https://qiita.com/Shoyu_N/items/2532f6871b5fba97c549) — 苦手分析
- [Claude Codeで品質の高いコードを書くコツ（ENECHANGE）](https://tech.enechange.co.jp/entry/2025/07/14/144750) — 品質向上の実践
