# Sample Project

TypeScript のショッピングカートアプリケーション。

## 開発コマンド

- テスト: `npx vitest run`
- 型チェック: `npx tsc --noEmit`
- lint: `npx eslint src/ tests/`

## コードスタイル

- named export のみ使用する
- エラーは Result 型（`{ success: boolean; data?: T; error?: string }`）で返す
- テストは tests/ ディレクトリに配置する
- 関数名は camelCase で書く
- 関数の引数と戻り値に型を明示する
- 1 関数は 30 行以下に収める
- 公開関数に JSDoc コメントを付ける
- テストは describe/it で構造化する
- import は @/ エイリアスを使用する
- ログは logger ユーティリティで出力する（src/logger.ts の logger を使う）
