#!/bin/bash
# judge-b6.sh — B6: Hooks（lint 自動実行）の品質影響判定
#
# Usage: ./judge-b6.sh <project_dir> <condition> <trial>
# Output: CSV 行 (condition,trial,eslint_errors,eslint_warnings,
#                  prettier_issues,tests_passed,tests_total,type_errors)

set -euo pipefail

PROJECT="${1:?Usage: $0 <project_dir> <condition> <trial>}"
CONDITION="${2:?}"
TRIAL="${3:?}"

cd "$PROJECT"

# --- ESLint (JSON output) ---
LINT_RESULT=$(npx eslint src/ tests/ --format json 2>/dev/null || echo "[]")
ERRORS=$(echo "$LINT_RESULT" | jq '[.[].errorCount] | add // 0' 2>/dev/null || echo "-1")
WARNINGS=$(echo "$LINT_RESULT" | jq '[.[].warningCount] | add // 0' 2>/dev/null || echo "-1")

# --- Prettier ---
PRETTIER_OUTPUT=$(npx prettier --check "src/**/*.ts" "tests/**/*.ts" 2>&1 || true)
PRETTIER_ISSUES=$(echo "$PRETTIER_OUTPUT" | grep -c "would reformat" 2>/dev/null || echo 0)

# --- Tests ---
TEST_OUTPUT=$(npx vitest run --reporter=json 2>/dev/null || echo "{}")
TESTS_PASSED=$(echo "$TEST_OUTPUT" | jq '.numPassedTests // 0' 2>/dev/null || echo "-1")
TESTS_TOTAL=$(echo "$TEST_OUTPUT" | jq '.numTotalTests // 0' 2>/dev/null || echo "-1")

# --- Type check ---
TYPE_ERRORS=$(npx tsc --noEmit 2>&1 | grep -c "error TS" || echo 0)

echo "${CONDITION},${TRIAL},${ERRORS},${WARNINGS},${PRETTIER_ISSUES},${TESTS_PASSED},${TESTS_TOTAL},${TYPE_ERRORS}"
