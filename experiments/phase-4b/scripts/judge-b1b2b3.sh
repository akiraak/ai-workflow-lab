#!/bin/bash
# judge-b1b2b3.sh — B1/B2/B3 共通の 10 ルール遵守判定スクリプト
#
# Usage: ./judge-b1b2b3.sh <project_dir> <experiment> <condition> <trial>
# Output: CSV 行 (experiment,condition,trial,rule1,...,rule10,total)
#
# 各ルールは 1（遵守）or 0（違反）で判定

set -euo pipefail

PROJECT="${1:?Usage: $0 <project_dir> <experiment> <condition> <trial>}"
EXPERIMENT="${2:?}"
CONDITION="${3:?}"
TRIAL="${4:?}"

cd "$PROJECT"

SRC_VALIDATOR="src/validator.ts"
TEST_VALIDATOR="tests/validator.test.ts"

# Helper: check if file exists
file_exists() { [ -f "$1" ]; }

# --- Rule 1: named export (no default export in validator.ts) ---
if file_exists "$SRC_VALIDATOR" && ! grep -q "export default" "$SRC_VALIDATOR"; then
  R1=1
else
  R1=0
fi

# --- Rule 2: Result pattern (no throw in validator.ts) ---
if file_exists "$SRC_VALIDATOR" && ! grep -q "throw " "$SRC_VALIDATOR"; then
  R2=1
else
  R2=0
fi

# --- Rule 3: Test placement (test in tests/ directory) ---
if file_exists "$TEST_VALIDATOR"; then
  R3=1
elif ls tests/*validator* >/dev/null 2>&1 || ls tests/*email* >/dev/null 2>&1; then
  R3=1
else
  R3=0
fi

# --- Rule 4: camelCase function names ---
# Check exported functions are camelCase (start with lowercase)
if file_exists "$SRC_VALIDATOR"; then
  BAD_NAMES=$(grep -oP 'export function \K\w+' "$SRC_VALIDATOR" | grep -E '^[A-Z_]' || true)
  if [ -z "$BAD_NAMES" ]; then
    R4=1
  else
    R4=0
  fi
else
  R4=0
fi

# --- Rule 5: Type annotations on added function ---
# Check validateEmail has parameter type and return type
if file_exists "$SRC_VALIDATOR" && grep -qP 'validateEmail\s*\([^)]*:\s*\w+' "$SRC_VALIDATOR" && grep -qP 'validateEmail\s*\([^)]*\)\s*:\s*\w+' "$SRC_VALIDATOR"; then
  R5=1
else
  R5=0
fi

# --- Rule 6: Function size <= 30 lines ---
if file_exists "$SRC_VALIDATOR"; then
  # Extract validateEmail function and count lines
  FUNC_LINES=$(awk '/function validateEmail/,/^}/' "$SRC_VALIDATOR" | wc -l)
  if [ "$FUNC_LINES" -le 30 ] && [ "$FUNC_LINES" -gt 0 ]; then
    R6=1
  else
    R6=0
  fi
else
  R6=0
fi

# --- Rule 7: JSDoc before validateEmail ---
if file_exists "$SRC_VALIDATOR"; then
  # Check for /** ... */ before validateEmail
  LINE_NUM=$(grep -n 'function validateEmail' "$SRC_VALIDATOR" | head -1 | cut -d: -f1)
  if [ -n "$LINE_NUM" ] && [ "$LINE_NUM" -gt 1 ]; then
    PREV_LINES=$(head -n "$((LINE_NUM - 1))" "$SRC_VALIDATOR" | tail -5)
    if echo "$PREV_LINES" | grep -q '/\*\*'; then
      R7=1
    else
      R7=0
    fi
  else
    R7=0
  fi
else
  R7=0
fi

# --- Rule 8: describe/it in tests ---
if file_exists "$TEST_VALIDATOR"; then
  TEST_FILE="$TEST_VALIDATOR"
elif ls tests/*email* >/dev/null 2>&1; then
  TEST_FILE=$(ls tests/*email* 2>/dev/null | head -1)
else
  TEST_FILE=""
fi

if [ -n "$TEST_FILE" ] && grep -q 'describe' "$TEST_FILE" && grep -q '\bit(' "$TEST_FILE"; then
  R8=1
else
  R8=0
fi

# --- Rule 9: @/ alias (no relative imports in added code) ---
# Check that new imports in validator.ts don't use relative paths
if file_exists "$SRC_VALIDATOR"; then
  RELATIVE_IMPORTS=$(grep -c "from '\.\.\?/" "$SRC_VALIDATOR" || true)
  if [ "$RELATIVE_IMPORTS" -eq 0 ]; then
    R9=1
  else
    R9=0
  fi
else
  R9=0
fi

# --- Rule 10: No console.log in validator.ts ---
if file_exists "$SRC_VALIDATOR" && ! grep -q 'console\.log' "$SRC_VALIDATOR"; then
  R10=1
else
  R10=0
fi

# Calculate total
TOTAL=$((R1 + R2 + R3 + R4 + R5 + R6 + R7 + R8 + R9 + R10))

echo "${EXPERIMENT},${CONDITION},${TRIAL},${R1},${R2},${R3},${R4},${R5},${R6},${R7},${R8},${R9},${R10},${TOTAL}"
