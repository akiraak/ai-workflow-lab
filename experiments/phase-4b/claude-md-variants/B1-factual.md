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
- ログ出力には logger ユーティリティを使用している（console.log ではなく src/logger.ts の logger を使う）
