# Sample Project

TypeScript のショッピングカートアプリケーション。

## 開発コマンド

- テスト: `npx vitest run`
- 型チェック: `npx tsc --noEmit`
- lint: `npx eslint src/ tests/`

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
  cart.ts          - ショッピングカート（CartItem, calculateTotal, addItem, removeItem）
  discount.ts      - 割引計算（Coupon, applyDiscount, isValidCoupon, calculateDiscountedPrice）
  validator.ts     - 入力バリデーション（isNonEmpty, isPositive, isInRange）
  user.ts          - ユーザー管理（User, createUser, getUserById, getAllUsers）
  order.ts         - 注文管理（Order, createOrder, updateOrderStatus, getOrdersByUserId）
  notification.ts  - 通知（sendNotification, getSentNotifications）
  index.ts         - 公開 API の re-export
tests/
  cart.test.ts     - カートのテスト
  discount.test.ts - 割引のテスト
  validator.test.ts - バリデーションのテスト
```

## Things That Will Bite You

- `calculateTotal` は税率のデフォルト値が 0.1（10%）なので、テスト時は明示的に指定する
- `applyDiscount` の percentage は 0-100 の範囲外だと元の価格を返す
- すべてのストア（users, orders, notifications）はインメモリなので、テスト間で `clearXxx()` を呼ぶ必要がある

## Result 型の使い方

```typescript
type Result<T> = {
  success: boolean;
  data?: T;
  error?: string;
};

// Good
export function doSomething(input: string): Result<string> {
  if (!input) {
    return { success: false, error: "Input is required" };
  }
  return { success: true, data: input.toUpperCase() };
}
```

## テストの書き方

```typescript
import { describe, it, expect } from "vitest";

describe("functionName", () => {
  it("describes what the function does in this case", () => {
    const result = functionName(input);
    expect(result).toBe(expected);
  });
});
```

## Git コミット規約

- 日本語でコミットメッセージを書く
- 変更の意図がわかるメッセージにする
- 例: 「メールバリデーション関数を追加」

## 技術スタック

- TypeScript 5.7（strict モード）
- Vitest 3.1（テストフレームワーク）
- ESLint 9 + typescript-eslint（リンター）
- Prettier 3.4（フォーマッタ）

## 命名規則

- 変数・関数: camelCase（例: `calculateTotal`）
- 型・インターフェース: PascalCase（例: `CartItem`）
- ファイル名: 対応するモジュール名と一致させる
