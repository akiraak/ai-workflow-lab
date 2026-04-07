#!/bin/bash
# judge-b4.sh — B4: Plan mode の初回成功率判定
#
# Usage: ./judge-b4.sh <project_dir> <condition> <model> <trial>
# Output: CSV 行 (condition,model,trial,tests_pass,typecheck_pass,lint_pass,
#                  calls_createOrder_sendNotification,uses_user_email,
#                  subject_has_orderId,test_verifies_notification,
#                  first_success,tool_calls)

set -euo pipefail

PROJECT="${1:?Usage: $0 <project_dir> <condition> <model> <trial>}"
CONDITION="${2:?}"
MODEL="${3:?}"
TRIAL="${4:?}"

cd "$PROJECT"

# --- Automated checks ---

# Test pass
if npx vitest run 2>&1 | grep -q "Tests.*passed"; then
  TESTS_PASS=1
else
  TESTS_PASS=0
fi

# Type check pass
if npx tsc --noEmit 2>&1 | grep -qE "error TS"; then
  TYPECHECK_PASS=0
else
  TYPECHECK_PASS=1
fi

# Lint pass
LINT_ERRORS=$(npx eslint src/ tests/ --format json 2>/dev/null | jq '[.[].errorCount] | add // 0' 2>/dev/null || echo "999")
if [ "$LINT_ERRORS" -eq 0 ]; then
  LINT_PASS=1
else
  LINT_PASS=0
fi

# --- Functional requirement checks ---

# 1. createOrder calls sendNotification
if grep -rq 'sendNotification' src/order.ts 2>/dev/null; then
  CALLS_NOTIFY=1
else
  CALLS_NOTIFY=0
fi

# 2. Uses user email (getUserById)
if grep -rq 'getUserById\|\.email' src/order.ts 2>/dev/null; then
  USES_EMAIL=1
else
  USES_EMAIL=0
fi

# 3. Subject contains orderId
if grep -rqP '注文確認.*orderId|orderId.*注文確認|注文確認.*\$\{|注文確認.*id' src/order.ts 2>/dev/null; then
  SUBJECT_ID=1
else
  SUBJECT_ID=0
fi

# 4. Test verifies notification
if ls tests/order* tests/notification* 2>/dev/null | head -1 | xargs grep -lq 'sendNotification\|getSentNotifications\|notification' 2>/dev/null; then
  TEST_NOTIFY=1
else
  TEST_NOTIFY=0
fi

# First success = all automated + all functional
if [ "$TESTS_PASS" -eq 1 ] && [ "$TYPECHECK_PASS" -eq 1 ] && [ "$LINT_PASS" -eq 1 ]; then
  FIRST_SUCCESS=1
else
  FIRST_SUCCESS=0
fi

# Tool calls count (placeholder — extracted from JSON output externally)
TOOL_CALLS="-"

echo "${CONDITION},${MODEL},${TRIAL},${TESTS_PASS},${TYPECHECK_PASS},${LINT_PASS},${CALLS_NOTIFY},${USES_EMAIL},${SUBJECT_ID},${TEST_NOTIFY},${FIRST_SUCCESS},${TOOL_CALLS}"
