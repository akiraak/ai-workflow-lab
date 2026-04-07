# Sample Project

TypeScript のショッピングカートアプリケーション。

## 開発コマンド

- テスト: `npx vitest run`
- 型チェック: `npx tsc --noEmit`
- lint: `npx eslint src/ tests/`

## コードスタイル

- named export を使え。default export は禁止
- エラー処理に例外を投げるな。Result 型（`{ success: boolean; data?: T; error?: string }`）で返せ
- テストファイルは tests/ ディレクトリに配置しろ
- 関数名は camelCase にしろ
- 関数の引数と戻り値に明示的な型アノテーションを付けろ
- 1 関数は 30 行以下にしろ
- 公開関数に JSDoc コメントを付けろ
- テストは describe/it で構造化しろ
- import は相対パスではなく @/ エイリアスを使え
- ログ出力に console.log を使うな。logger を使え（src/logger.ts の logger を使う）
