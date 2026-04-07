# Sample Project

TypeScript のショッピングカートアプリケーション。

## 開発コマンド

- テスト: `npx vitest run`
- 型チェック: `npx tsc --noEmit`
- lint: `npx eslint src/ tests/`

## コードスタイル

- default export を使わない
- 例外を throw しない。Result 型（`{ success: boolean; data?: T; error?: string }`）で返す
- テストを src/ 内に置かない。tests/ ディレクトリに配置する
- 関数名に snake_case や PascalCase を使わない
- 型アノテーションを省略しない
- 1 関数が 30 行を超えないようにする
- 公開関数の JSDoc コメントを省略しない
- describe/it を使わずにテストを書かない
- import に相対パス（./）を使わない
- console.log を使わない。logger を使う（src/logger.ts の logger を使う）
