# B5: TDD Bug Fix パターンの効果測定

## 仮説

TDD Bug Fix パターン（失敗テスト先行→修正→テスト通過確認）は、直接修正パターンと比べて修正成功率が高く、回帰バグの発生率が低い。

- 元調査: [09-task-bug-fix.md](09-task-bug-fix.md) — TDD Bug Fix パターンが推奨されるが定量データなし
- 検証対象: [A2 バグ修正テンプレート](../../templates/task-prompts/bug-fix.md) の TDD パターン推奨

---

## 実験デザイン

### 独立変数（操作する変数）

修正アプローチ（2 条件）:

| 条件 | アプローチ | 特徴 |
|------|-----------|------|
| A: TDD パターン | 失敗テスト作成 → 失敗確認 → 修正 → テスト通過確認 | 検証を先に定義 |
| B: 直接修正 | バグを修正 → テストで確認 | 従来の修正フロー |

### バグの準備

ベースプロジェクト（テスト全通過）に対し、実験時にバグをパッチで埋め込む。

#### バグ 1: discount.ts — 割引上限の欠落

**症状**: `applyDiscount(1000, 110)` が `-100` を返す（負の価格）
**原因**: percentage > 100 のバリデーションを削除
**パッチ内容**: `if (percentage < 0 || percentage > 100)` ガードと `Math.max(0, ...)` を削除

#### バグ 2: cart.ts — 空配列の未処理

**症状**: `calculateTotal([])` が TypeError を投げる
**原因**: 空配列チェックと reduce の初期値を削除
**パッチ内容**: `if (items.length === 0) return 0;` と reduce の初期値 `, 0` を削除

### 従属変数

| 指標 | 定義 | 測定方法 |
|------|------|---------|
| 修正成功率 | バグが修正され全テストが通るか | `vitest run` の結果 |
| 所要ターン数 | ツール呼び出し回数 | JSON 出力からカウント |
| 回帰バグの有無 | 既存テストが壊れていないか | 既存テストの通過数 |
| テスト追加数 | 新たに追加されたテストの数 | テストファイルの diff |

### 統制変数

| 項目 | 値 |
|------|-----|
| モデル | claude-sonnet-4-20250514 |
| CLAUDE.md | 共通（事実形式、30 行） |
| 反復回数 | 各条件 × 各バグ 5 回（合計 20 回） |

---

## バグパッチ

### bug1-discount.patch

```diff
--- a/src/discount.ts
+++ b/src/discount.ts
@@ -11,10 +11,8 @@
  * Returns the discounted price.
  */
 export function applyDiscount(price: number, percentage: number): number {
-  if (percentage < 0 || percentage > 100) {
-    return price;
-  }
   const factor = 1 - percentage / 100;
-  return Math.max(0, price * factor);
+  return price * factor;
 }
```

### bug2-cart.patch

```diff
--- a/src/cart.ts
+++ b/src/cart.ts
@@ -11,8 +11,7 @@
  * Applies tax rate to the subtotal.
  */
 export function calculateTotal(items: CartItem[], taxRate: number = 0.1): number {
-  if (items.length === 0) return 0;
-  const subtotal = items.reduce((sum, item) => sum + item.price * item.quantity, 0);
+  const subtotal = items.reduce((sum, item) => sum + item.price * item.quantity);
   return Math.round(subtotal * (1 + taxRate) * 100) / 100;
 }
```

---

## タスクプロンプト

### 条件 A: TDD パターン

#### バグ 1 用:
```
applyDiscount(1000, 110) を実行すると -100 が返ります。割引率が 100% を超えた場合、
負の価格になってしまうバグがあります。

以下の手順で修正してください:
1. まず、このバグを再現する失敗テストを書いてください
2. テストが失敗することを確認してください（npx vitest run）
3. バグを修正してください
4. テストが通ることを確認してください（npx vitest run）
5. 全テストを実行して回帰がないことを確認してください
```

#### バグ 2 用:
```
calculateTotal([]) を実行すると TypeError が発生します。
空のカートで合計金額を計算しようとするとクラッシュするバグがあります。

以下の手順で修正してください:
1. まず、このバグを再現する失敗テストを書いてください
2. テストが失敗することを確認してください（npx vitest run）
3. バグを修正してください
4. テストが通ることを確認してください（npx vitest run）
5. 全テストを実行して回帰がないことを確認してください
```

### 条件 B: 直接修正

#### バグ 1 用:
```
applyDiscount(1000, 110) を実行すると -100 が返ります。割引率が 100% を超えた場合、
負の価格になってしまうバグがあります。

このバグを修正してください。修正後にテストを実行して確認してください（npx vitest run）。
```

#### バグ 2 用:
```
calculateTotal([]) を実行すると TypeError が発生します。
空のカートで合計金額を計算しようとするとクラッシュするバグがあります。

このバグを修正してください。修正後にテストを実行して確認してください（npx vitest run）。
```

---

## 実験手順

1. `sample-project-clean/` から復元
2. バグパッチを適用（`bug1-discount.patch` or `bug2-cart.patch`）
3. 共通 CLAUDE.md を配置
4. 条件に応じたプロンプトで `claude -p` を実行
5. 判定スクリプトで結果を評価
6. JSON 出力からターン数を抽出

---

## 判定基準

| 指標 | 成功条件 |
|------|---------|
| 修正成功 | `vitest run` で全テスト通過 |
| 回帰なし | 既存テスト（バグ埋め込み前のテスト）が全通過 |
| バグ修正の正確性 | バグ 1: `applyDiscount(1000, 110)` が 1000 以下の正の数を返す |
| | バグ 2: `calculateTotal([])` が 0 を返す（エラーにならない） |

---

## 予想される結果

- 仮説支持: TDD パターンの修正成功率が直接修正を 15% 以上上回る
- TDD パターンはテスト追加数が多い（再現テストが明示的に作成される）
- 直接修正は回帰バグの発生率が高い可能性

---

## コスト見積もり

| 項目 | 値 |
|------|-----|
| 試行回数 | 20 回 |
| 推定コスト | $1-3（Sonnet） |
| 推定所要時間 | 30-60 分 |
