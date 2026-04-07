# Sample Project

TypeScript のショッピングカートアプリケーション。E コマース基盤のプロトタイプとして開発中。

## 開発コマンド

- テスト: `npx vitest run`
- 型チェック: `npx tsc --noEmit`
- lint: `npx eslint src/ tests/`
- フォーマット: `npx prettier --check src/ tests/`
- フォーマット修正: `npx prettier --write src/ tests/`
- ビルド: `npx tsc`（dist/ に出力される）

## コードスタイル

- named export を使用している
- エラー処理は例外ではなく Result 型（`{ success: boolean; data?: T; error?: string }`）で返している
- テストファイルは tests/ ディレクトリに配置している
- 関数名は camelCase を採用している
- 関数の引数と戻り値に明示的な型アノテーションを付けている
- 1 関数は 30 行以下で書いている
- 公開関数には JSDoc コメントを付けている
- テストは describe/it で構造化している
- import は相対パスではなく @/ エイリアスを使用している
- ログ出力には logger ユーティリティを使用している

## アーキテクチャ

```
src/
  cart.ts          - ショッピングカート機能
  discount.ts      - 割引・クーポン計算
  validator.ts     - 入力バリデーション
  user.ts          - ユーザー管理
  order.ts         - 注文管理
  notification.ts  - 通知機能
  index.ts         - 公開 API の re-export
tests/
  cart.test.ts     - カートのテスト
  discount.test.ts - 割引のテスト
  validator.test.ts - バリデーションのテスト
```

## ファイル詳細

### src/cart.ts

ショッピングカートの中核機能を提供する。

- `CartItem` インターフェース: カート内の商品を表す。`name`（商品名、string）、`price`（単価、number）、`quantity`（数量、number）のフィールドを持つ。
- `calculateTotal(items: CartItem[], taxRate?: number): number`: カート内の全商品の合計金額を計算する。taxRate のデフォルトは 0.1（10%）。空の配列に対しては 0 を返す。内部で `reduce` を使って小計を算出し、税率を掛けて `Math.round` で丸めている。
- `addItem(cart: CartItem[], newItem: CartItem): CartItem[]`: カートに商品を追加する。同名の商品が既にある場合は quantity を加算する。イミュータブルに新しい配列を返す。
- `removeItem(cart: CartItem[], name: string): CartItem[]`: 商品名で指定した商品をカートから削除する。`filter` でイミュータブルに処理。

### src/discount.ts

割引とクーポンの処理を担当する。

- `Coupon` インターフェース: クーポンを表す。`code`（クーポンコード、string）と `percentage`（割引率 0-100、number）を持つ。
- `applyDiscount(price: number, percentage: number): number`: 指定した割引率を価格に適用する。percentage が 0 未満または 100 超の場合は元の価格をそのまま返す。結果は `Math.max(0, ...)` で負の値にならないようにしている。
- `isValidCoupon(coupon: Coupon): boolean`: クーポンが有効かどうかを検証する。code が空でなく、percentage が 0-100 の範囲内であれば true。
- `calculateDiscountedPrice(price: number, coupon: Coupon): number`: クーポンが有効な場合に割引を適用した価格を返す。無効なクーポンの場合は元の価格。結果は小数点以下 2 桁に丸められる。

### src/validator.ts

汎用的な入力バリデーション関数を提供する。

- `isNonEmpty(value: string): boolean`: 文字列がトリム後に空でないかを確認。
- `isPositive(value: number): boolean`: 数値が正（> 0）であるかを確認。
- `isInRange(value: number, min: number, max: number): boolean`: 数値が指定範囲内（inclusive）にあるかを確認。

新しいバリデーション関数はここに追加する。

### src/user.ts

ユーザー管理機能を提供する。インメモリの `Map<string, User>` でデータを保持。

- `User` インターフェース: `id`、`name`、`email` の 3 フィールド。
- `createUser(id, name, email)`: 新規ユーザーを登録。
- `getUserById(id)`: ID でユーザーを検索。見つからなければ `undefined`。
- `getAllUsers()`: 全ユーザーを配列で返す。
- `clearUsers()`: テスト用。全ユーザーを削除。

### src/order.ts

注文管理機能。インメモリの `Map<string, Order>` でデータを保持。

- `OrderStatus` 型: `"pending" | "confirmed" | "shipped" | "delivered"` のユニオン型。
- `Order` インターフェース: `id`、`userId`、`items`（CartItem[]）、`total`、`status`、`createdAt`。
- `createOrder(id, userId, items, total)`: 新規注文を作成。status は `"pending"` で初期化。
- `updateOrderStatus(orderId, status)`: 注文ステータスを更新。存在しない orderId には `undefined` を返す。
- `getOrdersByUserId(userId)`: ユーザー ID で注文を検索。
- `clearOrders()`: テスト用。全注文を削除。

### src/notification.ts

通知機能のスタブ実装。実際のメール送信は行わず、インメモリの配列にログする。

- `Notification` インターフェース: `to`、`subject`、`body`、`sentAt`。
- `sendNotification(to, subject, body)`: 通知を送信（インメモリに記録）。`Notification` オブジェクトを返す。
- `getSentNotifications()`: 送信済み通知の一覧を返す（スプレッドでコピー）。
- `clearNotifications()`: テスト用。通知ログをクリア。

### src/index.ts

各モジュールの公開関数を re-export するバレルファイル。外部からは `import { xxx } from "./index.js"` でアクセスする。

## API エンドポイント（計画中）

将来的に REST API として公開する予定。現在は未実装だが、設計は以下の通り：

| メソッド | パス | 説明 |
|---------|------|------|
| GET | /api/cart | カート内容の取得 |
| POST | /api/cart/items | 商品の追加 |
| DELETE | /api/cart/items/:name | 商品の削除 |
| POST | /api/cart/checkout | チェックアウト（注文作成） |
| GET | /api/orders | 注文一覧 |
| GET | /api/orders/:id | 注文詳細 |
| POST | /api/users | ユーザー登録 |
| GET | /api/users/:id | ユーザー情報 |
| POST | /api/discount/apply | 割引適用 |
| POST | /api/discount/validate | クーポン検証 |

## Things That Will Bite You

- `calculateTotal` は税率のデフォルト値が 0.1（10%）なので、テスト時は明示的に指定する
- `applyDiscount` の percentage は 0-100 の範囲外だと元の価格を返す（エラーにはならない）
- すべてのストア（users, orders, notifications）はインメモリなので、テスト間で `clearXxx()` を呼ぶ必要がある
- `CartItem` の `price` は税抜き単価。税込み合計は `calculateTotal` で計算される
- `Order.total` は `calculateTotal` で計算済みの値が入る前提だが、バリデーションは行っていない

## Result 型の使い方

エラー処理には例外ではなく Result パターンを使用する。

```typescript
// Result 型の定義
type Result<T> = {
  success: boolean;
  data?: T;
  error?: string;
};

// 成功例
function doSomething(input: string): Result<string> {
  if (!input) {
    return { success: false, error: "Input is required" };
  }
  return { success: true, data: input.toUpperCase() };
}

// 呼び出し側
const result = doSomething("hello");
if (result.success) {
  console.log(result.data); // "HELLO"
} else {
  console.error(result.error);
}
```

`throw` は使わない。すべてのエラーは Result 型で表現する。呼び出し側は `success` フラグをチェックしてから `data` にアクセスする。

## テストの書き方

Vitest を使用。テストファイルは `tests/` ディレクトリに `{module}.test.ts` の形式で配置する。

```typescript
import { describe, it, expect } from "vitest";
import { functionName } from "../src/module.js";

describe("functionName", () => {
  it("describes what the function does in this case", () => {
    const result = functionName(input);
    expect(result).toBe(expected);
  });

  it("handles edge case", () => {
    const result = functionName(edgeInput);
    expect(result).toBe(edgeExpected);
  });
});
```

テストは必ず `describe` でグループ化し、`it` で個別のケースを記述する。`test` ではなく `it` を使う。

## スタイルガイド詳細

### TypeScript

- `strict: true` を使用（tsconfig.json で設定済み）
- `any` は禁止（ESLint の `@typescript-eslint/no-explicit-any: error` で強制）
- `as` によるタイプアサーションは原則禁止。型ガードを使う
- `enum` ではなくユニオン型を使う（例: `type Status = "a" | "b"`）
- Optional chaining (`?.`) と Nullish coalescing (`??`) を積極的に使う

### ESLint 設定

`eslint.config.js` で以下のルールを設定済み：
- `@typescript-eslint/no-explicit-any: error` — any 禁止
- `@typescript-eslint/explicit-function-return-type: warn` — 戻り値型の明示を推奨
- `no-console: warn` — console.log の使用に警告

### Prettier 設定

`.prettierrc` で以下を設定済み：
- `semi: true` — セミコロンあり
- `singleQuote: false` — ダブルクォート
- `tabWidth: 2` — インデント 2 スペース
- `trailingComma: "es5"` — ES5 準拠のトレーリングカンマ
- `printWidth: 100` — 1 行の最大幅 100 文字

### 命名規則

- 変数・関数: camelCase（例: `calculateTotal`, `isValidCoupon`）
- 型・インターフェース: PascalCase（例: `CartItem`, `OrderStatus`）
- 定数: camelCase（ALL_CAPS は使わない）
- ファイル名: kebab-case にしたいが、現状は camelCase のまま（統一予定）

## 歴史的経緯

このプロジェクトは元々 JavaScript で書かれていたが、2024 年に TypeScript に移行した。移行時に以下の変更を行った：

1. 全ファイルに型アノテーションを追加
2. `any` の使用を排除
3. ESLint の設定を `@typescript-eslint` に移行
4. テストフレームワークを Jest から Vitest に移行

Jest から Vitest への移行では、`jest.fn()` を `vi.fn()` に、`jest.mock()` を `vi.mock()` に置き換えた。ただし、現在のコードベースではモックを使用していないため、この影響はない。

## Git コミット規約

- 日本語でコミットメッセージを書く
- 変更の意図がわかるメッセージにする
- 例: 「メールバリデーション関数を追加」「割引計算のバグを修正」
- WIP コミットは避け、論理的な単位でコミットする

## デプロイ

現在はデプロイパイプラインなし。将来的には GitHub Actions で CI/CD を構築予定。

## 関連ドキュメント

- TypeScript ハンドブック: https://www.typescriptlang.org/docs/
- Vitest ドキュメント: https://vitest.dev/
- ESLint ドキュメント: https://eslint.org/docs/latest/
