# コードレビュープロンプトテンプレート

> Phase 2 の調査（12-task-code-review）に基づく推奨パターン。Phase 4B の実験で検証予定。

## 基本原則

- **実装と別セッションでレビューする**: 自分の出力を直後にレビューするとバイアスがかかる
- **高シグナルのみ**: 根拠を説明できない指摘は報告しない
- **重大度を明示する**: CRITICAL / WARNING / INFO の 3 段階

## 基本フォーマット

```
以下のコードをレビューしてください。

対象: {{ファイルパス、PR 番号、または diff}}
レビュー観点: {{セキュリティ / パフォーマンス / ロジック / 全般}}

出力形式:
- 重大度: CRITICAL / WARNING / INFO
- 場所: ファイル:行番号
- 指摘内容と理由
- 修正案（CRITICAL の場合は必須）
- 確信度: HIGH / MEDIUM / LOW
```

## パターン別テンプレート

### パターン 1: 全般レビュー（5 要素の公式）

```
以下の変更をレビューしてください。

**役割**: シニアエンジニアとしてレビュー
**対象**: `src/api/handlers/payment.ts` の変更（直近のコミット）
**観点**: セキュリティ、エラーハンドリング、エッジケース
**出力形式**:
  - CRITICAL / WARNING / INFO
  - ファイル:行番号
  - 指摘内容 + 根拠
  - 修正案
  - 確信度 (HIGH/MEDIUM/LOW)
**フィルター**: HIGH SIGNAL ONLY（スタイルやフォーマットの指摘は不要）
```

### パターン 2: 観点特化レビュー

#### セキュリティ

```
`src/api/` 以下の変更についてセキュリティレビューを行ってください。

チェック項目:
- SQL インジェクション・XSS・CSRF
- 認証・認可のバイパス
- 機密情報の露出（ログ出力、エラーレスポンス）
- 入力バリデーションの不備

CRITICAL と WARNING のみ報告。INFO レベルは不要。
```

#### パフォーマンス

```
`src/services/reportService.ts` のパフォーマンスをレビューしてください。

チェック項目:
- N+1 クエリ
- 不要なメモリ確保
- ブロッキング処理
- キャッシュ可能な計算の繰り返し

各指摘に推定インパクト（データ量との関係）を含めてください。
```

#### ロジック

```
`src/lib/pricing.ts` の料金計算ロジックをレビューしてください。

特に確認してほしいポイント:
- 割引の重複適用
- 0 円・マイナス金額のエッジケース
- 通貨の丸め処理
- 境界値（最大注文数、最大割引率）
```

### パターン 3: PR レビュー

```
PR #{{number}} の変更をレビューしてください。

レビュー手順:
1. まず変更の概要を 3 行以内でまとめる
2. CRITICAL な問題があれば最優先で報告
3. WARNING レベルの問題を報告
4. 全体的な設計判断についてコメント

出力は GitHub PR コメントとして貼れる Markdown 形式で。
```

## レビュー出力の例

```markdown
## レビュー結果

### CRITICAL

**[src/api/auth.ts:42]** SQL インジェクション (確信度: HIGH)
ユーザー入力が直接クエリ文字列に結合されている。
```ts
// 現在
const user = await db.query(`SELECT * FROM users WHERE email = '${email}'`);
// 修正案
const user = await db.query('SELECT * FROM users WHERE email = $1', [email]);
```

### WARNING

**[src/services/order.ts:128]** 未処理の Promise rejection (確信度: MEDIUM)
`sendNotification` の失敗が握りつぶされている。注文処理自体は成功するが、
通知の失敗がログに残らない。
```ts
// 修正案: エラーをログに記録
await sendNotification(order).catch(err => logger.error('Notification failed', err));
```

### INFO

なし（高シグナルの指摘のみ報告）
```

## REVIEW.md によるチーム規約の共有

チーム固有のレビュー基準がある場合、`REVIEW.md` を作成する:

```markdown
# REVIEW.md

## 必須チェック項目
- すべての API エンドポイントに認証ミドルウェアがあること
- DB クエリにはパラメータバインディングを使うこと
- エラーレスポンスに内部情報を含めないこと

## 無視してよい項目
- CSS の命名規則（Stylelint で検出）
- import の並び順（ESLint で検出）
```

## 避けるべきパターン

| やりがち | 改善 |
|----------|------|
| 「コードをレビューして」（観点なし） | 観点（セキュリティ、パフォーマンス等）を指定 |
| 実装直後に同じセッションでレビュー | `/clear` して新しいセッションでレビュー |
| スタイル指摘と重大バグを混在 | 重大度で分離、リンターで検出できるものは除外 |
| 確信度なしの指摘 | HIGH/MEDIUM/LOW を付与して優先度判断を支援 |
| 曖昧な指摘（「ここは改善の余地がある」） | 具体的な問題 + 修正案を示す |

## 根拠となる調査

- 5 要素の公式（役割 + 対象 + 観点 + 形式 + 重大度）: Phase 2: 12-task-code-review
- Writer/Reviewer 分離: Phase 2: 12-task-code-review, Phase 3: 13-best-practices
- HIGH SIGNAL ONLY ルール: Phase 2: 12-task-code-review
- 確信度スコアリング: Phase 2: 12-task-code-review
