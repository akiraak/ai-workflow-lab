#!/bin/bash
# judge-b5.sh — B5: TDD Bug Fix パターンの効果判定
#
# Usage: ./judge-b5.sh <project_dir> <condition> <bug_id> <trial>
# Output: CSV 行 (condition,bug_id,trial,tests_pass,regression_free,
#                  bug_fixed,new_tests_count,tool_calls)

set -euo pipefail

PROJECT="${1:?Usage: $0 <project_dir> <condition> <bug_id> <trial>}"
CONDITION="${2:?}"
BUG_ID="${3:?}"
TRIAL="${4:?}"

cd "$PROJECT"

# --- Tests pass ---
TEST_OUTPUT=$(npx vitest run 2>&1)
if echo "$TEST_OUTPUT" | grep -q "Tests.*passed" && ! echo "$TEST_OUTPUT" | grep -q "Tests.*failed"; then
  TESTS_PASS=1
else
  TESTS_PASS=0
fi

# --- Regression free (existing tests still pass) ---
# We check that no existing test files have failures
# This is effectively the same as TESTS_PASS if all tests pass
REGRESSION_FREE=$TESTS_PASS

# --- Bug-specific fix verification ---
case "$BUG_ID" in
  bug1)
    # applyDiscount(1000, 110) should return a positive number <= 1000
    # Check that the guard/clamp is back
    if grep -q 'percentage.*100\|Math\.max\|percentage.*<.*0' src/discount.ts; then
      BUG_FIXED=1
    else
      BUG_FIXED=0
    fi
    ;;
  bug2)
    # calculateTotal([]) should return 0 without throwing
    # Check that empty array handling is present
    if grep -q 'length.*===.*0\|\.length.*0\|items\.reduce.*,\s*0)' src/cart.ts; then
      BUG_FIXED=1
    else
      BUG_FIXED=0
    fi
    ;;
  *)
    echo "Unknown bug_id: $BUG_ID" >&2
    BUG_FIXED=0
    ;;
esac

# --- Count new tests added ---
# Compare test files against clean baseline
CLEAN_DIR="../sample-project-clean/tests"
NEW_TESTS=0

for test_file in tests/*.test.ts; do
  basename=$(basename "$test_file")
  if [ -f "$CLEAN_DIR/$basename" ]; then
    # Count new it() blocks
    OLD_COUNT=$(grep -c '\bit(' "$CLEAN_DIR/$basename" 2>/dev/null || echo 0)
    NEW_COUNT=$(grep -c '\bit(' "$test_file" 2>/dev/null || echo 0)
    ADDED=$((NEW_COUNT - OLD_COUNT))
    if [ "$ADDED" -gt 0 ]; then
      NEW_TESTS=$((NEW_TESTS + ADDED))
    fi
  else
    # Entirely new test file
    COUNT=$(grep -c '\bit(' "$test_file" 2>/dev/null || echo 0)
    NEW_TESTS=$((NEW_TESTS + COUNT))
  fi
done

# Tool calls (placeholder)
TOOL_CALLS="-"

echo "${CONDITION},${BUG_ID},${TRIAL},${TESTS_PASS},${REGRESSION_FREE},${BUG_FIXED},${NEW_TESTS},${TOOL_CALLS}"
