# B1: 事実形式 vs 命令形式の遵守率比較

## 仮説

CLAUDE.md を事実形式（「〜を使っている」）で記述すると、命令形式（「〜を使え」）よりルール遵守率が高い。

- 元調査: [02-claude-md.md](02-claude-md.md) — 「事実形式 > 命令形式」（コミュニティ報告、定量データなし）
- 検証対象: [A1 CLAUDE.md テンプレート](../../templates/claude-md-template.md) の記述スタイル推奨

---

## 実験デザイン

### 独立変数（操作する変数）

CLAUDE.md の記述スタイル（2 条件）:

| 条件 | スタイル | 例 |
|------|---------|-----|
| A: 事実形式 | 「〜している」「〜を使っている」 | 「named export を使っている」 |
| B: 命令形式 | 「〜しろ」「〜を使え」 | 「named export を使え」 |

両条件とも同一の 10 ルールを含む。スタイルだけが異なる。

### 従属変数（測定する指標）

- **遵守率**: 遵守ルール数 / 10（各試行ごと）
- **各ルールの遵守/違反**: バイナリ判定（0 or 1）

### 統制変数（固定する条件）

| 項目 | 値 |
|------|-----|
| モデル | claude-sonnet-4-20250514 |
| タスクプロンプト | 固定文言（下記） |
| サンプルプロジェクト | `experiments/phase-4b/sample-project/` |
| 反復回数 | 各条件 10 回（合計 20 回） |

---

## 10 ルールセット

| # | ルール内容 | 事実形式 (条件A) | 命令形式 (条件B) |
|---|-----------|----------------|----------------|
| 1 | named export | 「named export を使用している」 | 「named export を使え。default export は禁止」 |
| 2 | Result パターン | 「エラー処理は例外ではなく Result 型で返している」 | 「エラー処理に例外を投げるな。Result 型で返せ」 |
| 3 | テスト配置 | 「テストファイルは tests/ ディレクトリに配置している」 | 「テストファイルは tests/ ディレクトリに配置しろ」 |
| 4 | camelCase | 「関数名は camelCase を採用している」 | 「関数名は camelCase にしろ」 |
| 5 | 型アノテーション | 「関数の引数と戻り値に明示的な型アノテーションを付けている」 | 「関数の引数と戻り値に明示的な型アノテーションを付けろ」 |
| 6 | 関数サイズ | 「1 関数は 30 行以下で書いている」 | 「1 関数は 30 行以下にしろ」 |
| 7 | JSDoc | 「公開関数には JSDoc コメントを付けている」 | 「公開関数に JSDoc コメントを付けろ」 |
| 8 | テスト構造 | 「テストは describe/it で構造化している」 | 「テストは describe/it で構造化しろ」 |
| 9 | パスエイリアス | 「import は相対パスではなく @/ エイリアスを使用している」 | 「import は相対パスではなく @/ エイリアスを使え」 |
| 10 | ロガー | 「ログ出力には logger ユーティリティを使用している」 | 「ログ出力に console.log を使うな。logger を使え」 |

---

## CLAUDE.md テンプレート

### 条件 A: 事実形式

```markdown
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
```

### 条件 B: 命令形式

```markdown
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
```

---

## タスクプロンプト

```
src/validator.ts にメールアドレスバリデーション関数 validateEmail を追加してください。
RFC 5322 の簡易チェック（@ の前後に文字がある、ドメイン部分にドットがある）で十分です。
テストも追加してください。
```

---

## 実験手順

1. `sample-project-clean/` から `sample-project/` を復元
2. 条件に応じた CLAUDE.md を `sample-project/CLAUDE.md` に配置
3. `claude -p "プロンプト" --model claude-sonnet-4-20250514 --output-format json` を実行
4. 生成されたコードに対して判定スクリプトを実行
5. 結果を CSV に記録
6. 1-5 を各条件 10 回繰り返す

---

## 判定基準

各ルールの遵守/違反は以下のコマンドで自動判定:

| # | ルール | 遵守条件 | 判定コマンド |
|---|--------|---------|-------------|
| 1 | named export | `export default` が 0 件 | `grep -c "export default" src/validator.ts` → 0 |
| 2 | Result パターン | `throw` が 0 件かつ Result 型あり | `grep -c "throw " src/validator.ts` → 0 |
| 3 | テスト配置 | テストが tests/ にある | `ls tests/validator.test.ts` |
| 4 | camelCase | エクスポート関数名が camelCase | `grep -oP "export function \K\w+" src/validator.ts` を正規表現チェック |
| 5 | 型アノテーション | 追加関数に引数型+戻り値型あり | `grep "validateEmail.*:.*:.*"` パターン |
| 6 | 30 行以下 | 追加関数の行数 ≤ 30 | awk で関数行数カウント |
| 7 | JSDoc | `validateEmail` の前に `/**` あり | grep で `/**` + `validateEmail` の順序チェック |
| 8 | describe/it | テストに describe + it あり | `grep -c "describe\|it(" tests/validator.test.ts` |
| 9 | @/ エイリアス | 追加コードの import に `from './'` がない | `grep -c "from '\.\/"` → 0 |
| 10 | logger | `console.log` が 0 件 | `grep -c "console.log" src/validator.ts` → 0 |

---

## 予想される結果

- 仮説支持: 事実形式の遵守率が命令形式を 10% 以上上回る
- 仮説不支持: 差が 10% 未満、または命令形式の方が高い

---

## コスト見積もり

| 項目 | 値 |
|------|-----|
| 1 回あたり推定トークン | 入力 5K-10K + 出力 2K-5K |
| 試行回数 | 20 回 |
| 推定コスト | $1-3（Sonnet） |
| 推定所要時間 | 30-60 分 |
