# B6: Hooks（lint 自動実行）の品質影響測定

## 仮説

PostToolUse Hooks で ESLint + Prettier を自動実行すると、Hooks なしと比べて最終コードの品質指標（lint エラー数、フォーマット不整合）が有意に改善する。

- 元調査: [04-slash-commands.md](04-slash-commands.md) — 「Hooks は決定論的（deterministic）、CLAUDE.md は助言的（advisory）」
- 検証対象: [A5 検証手段の設計ガイド](../../guides/verification.md) の Hooks 推奨

---

## 実験デザイン

### 独立変数（操作する変数）

PostToolUse Hooks の有無（2 条件）:

| 条件 | 設定 |
|------|------|
| A: Hooks なし | `.claude/settings.json` に hooks 設定なし |
| B: Hooks あり | Edit/Write 後に ESLint --fix + Prettier --write を自動実行 |

### Hooks 設定（条件 B）

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "file=$(echo $CLAUDE_TOOL_INPUT | jq -r '.file_path // .filePath // empty') && if [ -n \"$file\" ] && [[ \"$file\" == *.ts ]]; then npx eslint --fix \"$file\" 2>/dev/null; npx prettier --write \"$file\" 2>/dev/null; fi; exit 0"
          }
        ]
      }
    ]
  }
}
```

### 従属変数

| 指標 | 定義 | 測定方法 |
|------|------|---------|
| ESLint エラー数 | 最終コードの error 件数 | `eslint --format json` → errorCount |
| ESLint 警告数 | 最終コードの warning 件数 | `eslint --format json` → warningCount |
| Prettier 不整合 | フォーマット違反のファイル数 | `prettier --check` の出力 |
| テスト通過率 | 通過テスト / 全テスト | `vitest run --reporter=json` |
| 型エラー数 | TypeScript コンパイルエラー | `tsc --noEmit 2>&1 | grep error | wc -l` |

### 統制変数

| 項目 | 値 |
|------|-----|
| モデル | claude-sonnet-4-20250514 |
| CLAUDE.md | 共通（事実形式、30 行、lint/format コマンド記載） |
| タスクプロンプト | B1 と同一（validateEmail 追加） |
| 反復回数 | 各条件 7 回（合計 14 回） |

---

## CLAUDE.md（共通）

```markdown
# Sample Project

TypeScript のショッピングカートアプリケーション。

## 開発コマンド

- テスト: `npx vitest run`
- 型チェック: `npx tsc --noEmit`
- lint: `npx eslint src/ tests/`
- フォーマット: `npx prettier --check src/ tests/`

## コードスタイル

- named export を使用している
- エラー処理は例外ではなく Result 型で返している
- テストファイルは tests/ ディレクトリに配置している
- 関数名は camelCase を採用している
- 関数の引数と戻り値に明示的な型アノテーションを付けている
- 1 関数は 30 行以下で書いている
- 公開関数には JSDoc コメントを付けている
- テストは describe/it で構造化している
- import は相対パスではなく @/ エイリアスを使用している
- ログ出力には logger ユーティリティを使用している
```

---

## タスクプロンプト

B1 と同一:
```
src/validator.ts にメールアドレスバリデーション関数 validateEmail を追加してください。
RFC 5322 の簡易チェック（@ の前後に文字がある、ドメイン部分にドットがある）で十分です。
テストも追加してください。
```

---

## 実験手順

1. `sample-project-clean/` から復元
2. 共通 CLAUDE.md を配置
3. 条件 B の場合: `.claude/settings.json` に Hooks 設定を配置
4. `claude -p "プロンプト" --model claude-sonnet-4-20250514 --output-format json` を実行
5. 判定スクリプトで品質指標を測定
6. 結果を CSV に記録

---

## 判定スクリプト

```bash
#!/bin/bash
# judge-B6.sh
PROJECT=$1
CONDITION=$2
TRIAL=$3

cd "$PROJECT"

# ESLint (JSON output)
LINT_RESULT=$(npx eslint src/ tests/ --format json 2>/dev/null || echo "[]")
ERRORS=$(echo "$LINT_RESULT" | jq '[.[].errorCount] | add // 0')
WARNINGS=$(echo "$LINT_RESULT" | jq '[.[].warningCount] | add // 0')

# Prettier
PRETTIER_ISSUES=$(npx prettier --check src/ tests/ 2>&1 | grep -c "would reformat" || echo 0)

# Tests
TEST_RESULT=$(npx vitest run --reporter=json 2>/dev/null)
TESTS_PASSED=$(echo "$TEST_RESULT" | jq '.numPassedTests // 0')
TESTS_TOTAL=$(echo "$TEST_RESULT" | jq '.numTotalTests // 0')

# Type check
TYPE_ERRORS=$(npx tsc --noEmit 2>&1 | grep -c "error TS" || echo 0)

echo "${CONDITION},${TRIAL},${ERRORS},${WARNINGS},${PRETTIER_ISSUES},${TESTS_PASSED},${TESTS_TOTAL},${TYPE_ERRORS}"
```

---

## 予想される結果

- 仮説支持: Hooks ありの方が ESLint エラー・Prettier 不整合が有意に少ない（50% 以上の改善）
- Hooks は「決定論的」なので、lint/format に関しては 100% の遵守率を期待
- テスト通過率・型エラーは Hooks の影響を受けにくい（lint/format とは独立）

---

## 注意事項

- Hooks がヘッドレスモード（`claude -p`）で正しく動作するかパイロットテストで確認
- Hooks のエラー（ESLint 設定の不備等）がタスク実行を妨げないよう、`exit 0` で常に成功させる
- Hooks の実行時間がタスク全体の所要時間に影響する可能性（計測対象外）

---

## コスト見積もり

| 項目 | 値 |
|------|-----|
| 試行回数 | 14 回 |
| 推定コスト | $0.7-2（Sonnet） |
| 推定所要時間 | 20-40 分 |
