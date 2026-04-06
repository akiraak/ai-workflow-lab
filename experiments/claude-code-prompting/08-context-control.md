# 1-8. コンテキスト制御

## 調査目的

/clear や /compact のタイミングと効果、ファイルの明示的な読み込み指示の効果、コンテキスト長と品質の関係を調査し、効果的なコンテキスト管理手法を明らかにする。

---

## 1. コンテキストウィンドウの基本

### 最重要の制約

> "Most best practices are based on one constraint: Claude's context window fills up fast, and performance degrades as it fills."
> — [Best Practices](https://code.claude.com/docs/en/best-practices)

> "The context window is the most important resource to manage."

コンテキストウィンドウには会話全体（メッセージ、読み込んだファイル、コマンド出力）が格納される。容量が埋まるにつれてパフォーマンスが劣化する。

### コンテキスト使用量の確認方法

| 方法 | 説明 |
|------|------|
| `/context` コマンド | トークン消費のカテゴリ別内訳を表示 |
| ステータスライン | `/statusline` で常時表示をカスタマイズ可能 |

---

## 2. /clear コマンド — 完全リセット

### 機能

会話履歴をすべて消去し、コンテキストウィンドウを空にリセットする。エイリアスとして `/reset`、`/new` でも実行可能。

### 使うべきタイミング

| タイミング | 理由 |
|-----------|------|
| **異なるタスクに切り替えるとき** | 前のコンテキストが邪魔になる |
| **2回以上の修正を繰り返しても解決しないとき** | コンテキストが失敗したアプローチで汚染されている |
| **先行コンテキストの50%以上が無関係になったとき** | ノイズが有益な情報を圧迫 |
| **Claude が既に提供した情報を再度質問してくるとき** | コンテキスト検索の失敗サイン |

> "If you've corrected Claude more than twice on the same issue in one session, the context is cluttered with failed approaches. Run /clear and start fresh with a more specific prompt that incorporates what you learned."
> — [Best Practices](https://code.claude.com/docs/en/best-practices)

### 効果

- **完全にクリーンなコンテキスト**で再出発
- CLAUDE.md やシステムプロンプトは**再ロードされる**ため、永続的な指示は失われない
- オートメモリ（MEMORY.md）も再読み込みされる

> "A clean session with a better prompt almost always outperforms a long session with accumulated corrections."

---

## 3. /compact コマンド — コンテキスト圧縮

### 機能

会話全体を要約してコンテキスト使用量を削減する。`/clear` と異なり、**作業の文脈を保持したまま容量を確保**できる。

### 仕組み

1. Claude Code が会話全体を分析し、保持すべき重要情報を特定
2. これまでのやりとり・意思決定・コード変更の簡潔な要約を作成
3. 古いメッセージを要約で置換し、新しいチャットセッションとして継続

### 使い方のバリエーション

| コマンド | 効果 |
|---------|------|
| `/compact` | 汎用的な圧縮 |
| `/compact APIの変更点とテスト結果を重点的に残して` | 保持内容を自然言語で指示 |
| `Esc + Esc` → 「Summarize from here」 | 部分的な圧縮（特定メッセージ以降のみ） |

### 圧縮のタイミング — 60%ルール

> "Compact at 60% capacity, not 90%+"

| タイミング | 状態 |
|-----------|------|
| **60%（推奨）** | Claude はまだ全コンテキストに完全アクセス可能。要約品質が高い |
| **80-95%** | 既に部分的・圧縮されたコンテキストで動作。要約品質も劣化 |
| **95%+** | 自動圧縮が発動するが、品質は最も低い |

**時間ベースの目安**: 30-45分のアクティブな作業ごと、または主要なマイルストーン完了ごとに圧縮を検討。

### CLAUDE.md での圧縮カスタマイズ

```markdown
When compacting, always preserve:
- Current file paths being edited
- Test failure messages
- Architecture decisions made this session
```

---

## 4. 自動コンテキスト圧縮の仕組み

### トリガー条件

コンテキストウィンドウが**約95%容量**に達したとき自動発動。200K ウィンドウの場合、33K-45K トークンのバッファが予約されている。

### 動作プロセス

1. まず**古いツール出力をクリア**
2. それでも不足なら、**会話を要約**
3. ユーザーのリクエストと重要なコードスニペットは保持
4. 会話初期の詳細な指示は失われる可能性がある

### 保持されるもの vs 失われる可能性があるもの

| 保持される | 失われる可能性がある |
|-----------|-------------------|
| コードパターン、ファイル状態 | 会話初期の詳細な指示 |
| ユーザーのリクエスト | 冗長なツール出力 |
| 重要な意思決定 | スキル説明（`noSurviveCompact` フラグ付き） |
| CLAUDE.md の指示 | — |

### CLAUDE.md が唯一の永続指示

> "CLAUDE.md is the only reliable place for instructions that must survive the entire session."

CLAUDE.md の指示は毎セッション・毎コンパクションで保持される。永続的に必要な指示は必ず CLAUDE.md に記載すべき。

---

## 5. ファイルの明示的な読み込み指示の効果

### ファイル読み込みがコンテキストを支配する

> "File reads dominate context usage. Be specific in prompts ('fix the bug in auth.ts') so Claude reads fewer files. For research-heavy tasks, use a subagent."
> — [Explore the context window](https://code.claude.com/docs/en/context-window)

### 具体的な指示 vs 曖昧な指示

| 指示 | 結果 |
|------|------|
| 「認証のバグを直して」 | Claude が多数のファイルを読み込み、コンテキスト大量消費 |
| 「src/auth.ts のバグを直して」 | 対象ファイルを絞り込み、効率的 |

### @ 参照の活用

- `@filename` でファイル内容を即座にコンテキストに読み込む
- Claude が自分で探して読むより**高速かつ効率的**
- CLAUDE.md 内で `@path/to/import` 構文で追加ファイルをインポート可能

### 圧縮後の注意点

コンパクション後にファイル読み込みの指示が失われる場合がある。Claude がファイルを完全に読まずに grep や部分読み込みに退化するパターンが報告されている。

---

## 6. コンテキスト長と品質の関係

### 品質劣化のパターン

| コンテキスト使用率 | 状態 |
|-------------------|------|
| **0-20%** | 信頼性の高いパフォーマンス |
| **20%以降** | 漸進的な品質劣化が始まる |
| **40%** | 初期の指示を「忘れる」現象が顕著に |
| **48%** | Claude 自身が「効果的に動作できていない」と報告する事例あり |

### 「コンテキストロット（Context Rot）」

コンテキストウィンドウが古いコード、失敗した実験、デバッグループ、古い指示で埋まると、現在の問題に対する推論能力が劣化する。

> "A larger context window delays the hard token limit, but it doesn't prevent context rot."

大きなコンテキストウィンドウ（1M）はハードリミットを遅らせるが、**コンテキストロットを防がない**。問題は容量ではなくノイズの蓄積と注意力の分散。

### 推論のための空きスペース

> "When most context space is consumed by conversation history, file contents, and tool outputs, the model has minimal room for the computational processes that produce high-quality responses. That 'free' context space isn't wasted — it's where reasoning happens."

空きコンテキストは「無駄」ではなく、**推論が行われる場所**。

---

## 7. タスク間でのコンテキスト分離

### 方法1: /clear によるタスク間リセット

最もシンプルで効果的。

> "Use /clear frequently between tasks to reset the context window entirely"

### 方法2: サブエージェントによるコンテキスト分離

> "Subagents get their own fresh context, completely separate from your main conversation. Their work doesn't bloat your context."
> — [How Claude Code works](https://code.claude.com/docs/en/how-claude-code-works)

サブエージェントは独自のコンテキストウィンドウで動作し、最終メッセージのみが親に返される。

| サブエージェント | モデル | 用途 |
|---------------|--------|------|
| **Explore** | Haiku | 読み取り専用、コードベース探索 |
| **Plan** | — | プランモード時の調査 |
| **General-purpose** | — | 複雑なマルチステップタスク |
| **カスタム** | 設定可能 | `.claude/agents/` に定義 |

### 方法3: Git Worktrees による並列セッション

`git worktree` で別ディレクトリを作り、各ディレクトリで独立した Claude Code セッションを実行。

### 方法4: セッションの名前付きと再開

- `/rename` でセッションに説明的な名前を付ける（例: "oauth-migration"）
- `claude --continue` / `claude --resume` で再開
- セッションをブランチのように扱い、異なるワークストリームに別々の永続コンテキストを持たせる

### 方法5: Writer/Reviewer パターン

セッション A で実装、セッション B でレビュー。フレッシュなコンテキストはコードレビューの品質を向上させる。

---

## 8. /btw コマンド — コンテキストを汚さない質問

`/btw` で一時的な質問を行うと、回答がオーバーレイ表示され**会話履歴に入らない**。本筋から外れた質問でコンテキストを汚さずに済む。

---

## 総合的なベストプラクティス

### コンテキスト管理の原則

1. **60%で圧縮**: 95%の自動圧縮を待たず、60%の時点で `/compact` する
2. **タスク切り替え時に /clear**: 異なるタスクには新しいコンテキストで臨む
3. **2回修正して直らなければ /clear**: 失敗アプローチの蓄積を避ける
4. **ファイルパスを具体的に指示**: 「auth.ts を直して」で不要な読み込みを減らす
5. **サブエージェントで探索を分離**: 大規模調査はメインコンテキストの外で行う
6. **CLAUDE.md に永続指示を置く**: 圧縮を生き残る唯一の場所
7. **/compact に保持指示を渡す**: 重要な文脈を明示的に指定
8. **/btw で脱線質問**: 本筋のコンテキストを汚さない

### /clear vs /compact の使い分け

| 状況 | 推奨 |
|------|------|
| 完全に別のタスクに移る | `/clear` |
| 同じタスクの続きだがコンテキストが重い | `/compact` |
| 失敗アプローチが蓄積している | `/clear` + より良いプロンプトで再開 |
| 長時間作業の途中休憩 | `/compact` で要約してから中断 |

---

## 調査ソース

- [Explore the context window](https://code.claude.com/docs/en/context-window) — 公式コンテキストウィンドウ解説
- [Best Practices for Claude Code](https://code.claude.com/docs/en/best-practices) — 公式ベストプラクティス
- [How Claude Code works](https://code.claude.com/docs/en/how-claude-code-works) — 公式エージェントループ解説
- [Create custom subagents](https://code.claude.com/docs/en/sub-agents) — 公式サブエージェント解説
- [Manage costs effectively](https://code.claude.com/docs/en/costs) — 公式コスト管理
- [Compaction - Claude API Docs](https://platform.claude.com/docs/en/build-with-claude/compaction) — API レベルのコンパクション解説
- [Context Window Management: What 50 Sessions Taught Me](https://blakecrosley.com/blog/context-window-management) — 50セッションから学んだコンテキスト管理
- [Claude Code Context Window: Optimize Your Token Usage](https://claudefa.st/blog/guide/mechanics/context-management) — トークン最適化ガイド
- [What is Claude Code Auto-Compact](https://claudelog.com/faqs/what-is-claude-code-auto-compact/) — 自動圧縮の解説
- [What Is Context Rot in Claude Code?](https://www.mindstudio.ai/blog/what-is-context-rot-claude-code) — コンテキストロットの解説
- [Claude Codeのコンテキスト管理完全ガイド](https://zenn.dev/tmasuyama1114/books/claude_code_basic/viewer/context-management) — Zenn 日本語ガイド
- [Claude Codeのコンテキストを綺麗に保つ方法まとめ](https://qiita.com/nogataka/items/ce4921c7b8a74a408caa) — Qiita 日本語まとめ
- [モデルの性能を引き出すための Claude Code コンテキストマネジメント入門](https://caddi.tech/claude-code-context-management-202603) — CADDi Tech Blog
