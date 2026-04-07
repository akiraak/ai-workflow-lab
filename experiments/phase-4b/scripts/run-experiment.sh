#!/bin/bash
# run-experiment.sh — Phase 4B 実験ランナー
#
# Usage:
#   ./run-experiment.sh B1 [trial_start] [trial_end]
#   ./run-experiment.sh B2 [trial_start] [trial_end]
#   ./run-experiment.sh B3 [trial_start] [trial_end]
#   ./run-experiment.sh B4 [trial_start] [trial_end]
#   ./run-experiment.sh B5 [trial_start] [trial_end]
#   ./run-experiment.sh B6 [trial_start] [trial_end]
#
# Results are appended to results/<experiment>/results.csv

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BASE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
PROJECT_DIR="$BASE_DIR/sample-project"
CLEAN_DIR="$BASE_DIR/sample-project-clean"
CLAUDE_MD_DIR="$BASE_DIR/claude-md-variants"
PROMPTS_DIR="$BASE_DIR/prompts"
RESULTS_DIR="$BASE_DIR/results"

EXPERIMENT="${1:?Usage: $0 <B1|B2|B3|B4|B5|B6> [trial_start] [trial_end]}"
TRIAL_START="${2:-1}"
TRIAL_END="${3:-}"

MODEL="claude-sonnet-4-20250514"

# --- Utility functions ---

restore_project() {
  echo "  Restoring project from clean copy..."
  # Remove src/ and tests/ from working copy, restore from clean
  rm -rf "$PROJECT_DIR/src" "$PROJECT_DIR/tests"
  cp -r "$CLEAN_DIR/src" "$PROJECT_DIR/src"
  cp -r "$CLEAN_DIR/tests" "$PROJECT_DIR/tests"
  # Remove any CLAUDE.md and .claude/ from previous runs
  rm -f "$PROJECT_DIR/CLAUDE.md"
  rm -rf "$PROJECT_DIR/.claude"
}

place_claude_md() {
  local variant="$1"
  echo "  Placing CLAUDE.md: $variant"
  cp "$CLAUDE_MD_DIR/$variant" "$PROJECT_DIR/CLAUDE.md"
}

run_claude() {
  local prompt_file="$1"
  local model="${2:-$MODEL}"
  local prompt
  prompt=$(cat "$prompt_file")
  echo "  Running claude -p with model=$model ..." >&2
  claude -p "$prompt" \
    --model "$model" \
    --output-format json \
    --max-turns 30 \
    --allowedTools "Edit Write Read Bash Glob Grep" \
    2>/dev/null
}

run_claude_text() {
  local prompt_file="$1"
  local model="${2:-$MODEL}"
  local prompt
  prompt=$(cat "$prompt_file")
  claude -p "$prompt" \
    --model "$model" \
    --output-format text \
    --max-turns 10 \
    --allowedTools "Edit Write Read Bash Glob Grep" \
    2>/dev/null
}

apply_patch() {
  local patch_file="$1"
  echo "  Applying patch: $patch_file"
  cd "$PROJECT_DIR" && git apply "$patch_file"
}

count_tool_calls() {
  local json_output="$1"
  echo "$json_output" | jq '[.[] | select(.type == "tool_use")] | length' 2>/dev/null || echo "-"
}

timestamp() {
  date +"%Y-%m-%d %H:%M:%S"
}

# --- Experiment runners ---

run_b1() {
  local trial_end="${TRIAL_END:-10}"
  local csv="$RESULTS_DIR/B1/results.csv"
  mkdir -p "$RESULTS_DIR/B1"

  # Header
  if [ ! -f "$csv" ]; then
    echo "experiment,condition,trial,r1_named_export,r2_result,r3_test_dir,r4_camelcase,r5_types,r6_size,r7_jsdoc,r8_describe_it,r9_alias,r10_logger,total,timestamp" > "$csv"
  fi

  for condition in factual imperative; do
    for trial in $(seq "$TRIAL_START" "$trial_end"); do
      echo "[B1] condition=$condition trial=$trial"
      restore_project
      place_claude_md "B1-${condition}.md"

      cd "$PROJECT_DIR"
      JSON_OUT=$(run_claude "$PROMPTS_DIR/B1-prompt.txt")
      TOOLS=$(count_tool_calls "$JSON_OUT")

      RESULT=$("$SCRIPT_DIR/judge-b1b2b3.sh" "$PROJECT_DIR" "B1" "$condition" "$trial")
      echo "${RESULT},$(timestamp)" >> "$csv"
      echo "  Result: $RESULT"

      # Save raw output
      mkdir -p "$RESULTS_DIR/B1/raw"
      echo "$JSON_OUT" > "$RESULTS_DIR/B1/raw/${condition}_${trial}.json"
    done
  done
}

run_b2() {
  local trial_end="${TRIAL_END:-10}"
  local csv="$RESULTS_DIR/B2/results.csv"
  mkdir -p "$RESULTS_DIR/B2"

  if [ ! -f "$csv" ]; then
    echo "experiment,condition,trial,r1_named_export,r2_result,r3_test_dir,r4_camelcase,r5_types,r6_size,r7_jsdoc,r8_describe_it,r9_alias,r10_logger,total,timestamp" > "$csv"
  fi

  for condition in positive negative; do
    for trial in $(seq "$TRIAL_START" "$trial_end"); do
      echo "[B2] condition=$condition trial=$trial"
      restore_project
      place_claude_md "B2-${condition}.md"

      cd "$PROJECT_DIR"
      JSON_OUT=$(run_claude "$PROMPTS_DIR/B2-prompt.txt")

      RESULT=$("$SCRIPT_DIR/judge-b1b2b3.sh" "$PROJECT_DIR" "B2" "$condition" "$trial")
      echo "${RESULT},$(timestamp)" >> "$csv"
      echo "  Result: $RESULT"

      mkdir -p "$RESULTS_DIR/B2/raw"
      echo "$JSON_OUT" > "$RESULTS_DIR/B2/raw/${condition}_${trial}.json"
    done
  done
}

run_b3() {
  local trial_end="${TRIAL_END:-7}"
  local csv="$RESULTS_DIR/B3/results.csv"
  mkdir -p "$RESULTS_DIR/B3"

  if [ ! -f "$csv" ]; then
    echo "experiment,condition,trial,r1_named_export,r2_result,r3_test_dir,r4_camelcase,r5_types,r6_size,r7_jsdoc,r8_describe_it,r9_alias,r10_logger,total,timestamp" > "$csv"
  fi

  for condition in short medium long; do
    for trial in $(seq "$TRIAL_START" "$trial_end"); do
      echo "[B3] condition=$condition trial=$trial"
      restore_project
      place_claude_md "B3-${condition}.md"

      cd "$PROJECT_DIR"
      JSON_OUT=$(run_claude "$PROMPTS_DIR/B3-prompt.txt")

      RESULT=$("$SCRIPT_DIR/judge-b1b2b3.sh" "$PROJECT_DIR" "B3" "$condition" "$trial")
      echo "${RESULT},$(timestamp)" >> "$csv"
      echo "  Result: $RESULT"

      mkdir -p "$RESULTS_DIR/B3/raw"
      echo "$JSON_OUT" > "$RESULTS_DIR/B3/raw/${condition}_${trial}.json"
    done
  done
}

run_b4() {
  local trial_end="${TRIAL_END:-5}"
  local csv="$RESULTS_DIR/B4/results.csv"
  mkdir -p "$RESULTS_DIR/B4"

  if [ ! -f "$csv" ]; then
    echo "condition,model,trial,tests_pass,typecheck_pass,lint_pass,calls_notify,uses_email,subject_id,test_notify,first_success,tool_calls,timestamp" > "$csv"
  fi

  for model_name in sonnet opus; do
    if [ "$model_name" = "sonnet" ]; then
      model_id="claude-sonnet-4-20250514"
    else
      model_id="claude-opus-4-20250514"
    fi

    for plan_mode in no-plan plan; do
      for trial in $(seq "$TRIAL_START" "$trial_end"); do
        echo "[B4] model=$model_name plan=$plan_mode trial=$trial"
        restore_project
        place_claude_md "B4-common.md"

        cd "$PROJECT_DIR"

        if [ "$plan_mode" = "plan" ]; then
          # Step 1: Get plan
          echo "  Step 1: Getting plan..."
          PLAN_TEXT=$(run_claude_text "$PROMPTS_DIR/B4-plan-step1.txt" "$model_id")

          # Step 2: Execute plan
          STEP2_PROMPT=$(cat "$PROMPTS_DIR/B4-plan-step2-template.txt")
          STEP2_PROMPT="${STEP2_PROMPT/\{PLAN\}/$PLAN_TEXT}"
          echo "$STEP2_PROMPT" > /tmp/b4-step2-prompt.txt
          JSON_OUT=$(run_claude "/tmp/b4-step2-prompt.txt" "$model_id")

          mkdir -p "$RESULTS_DIR/B4/raw"
          echo "$PLAN_TEXT" > "$RESULTS_DIR/B4/raw/${model_name}_plan_${trial}_step1.txt"
          echo "$JSON_OUT" > "$RESULTS_DIR/B4/raw/${model_name}_plan_${trial}_step2.json"
        else
          JSON_OUT=$(run_claude "$PROMPTS_DIR/B4-no-plan.txt" "$model_id")
          mkdir -p "$RESULTS_DIR/B4/raw"
          echo "$JSON_OUT" > "$RESULTS_DIR/B4/raw/${model_name}_no-plan_${trial}.json"
        fi

        TOOLS=$(count_tool_calls "$JSON_OUT")

        RESULT=$("$SCRIPT_DIR/judge-b4.sh" "$PROJECT_DIR" "$plan_mode" "$model_name" "$trial")
        echo "${RESULT%,*},${TOOLS},$(timestamp)" >> "$csv"
        echo "  Result: $RESULT"
      done
    done
  done
}

run_b5() {
  local trial_end="${TRIAL_END:-5}"
  local csv="$RESULTS_DIR/B5/results.csv"
  mkdir -p "$RESULTS_DIR/B5"

  if [ ! -f "$csv" ]; then
    echo "condition,bug_id,trial,tests_pass,regression_free,bug_fixed,new_tests,tool_calls,timestamp" > "$csv"
  fi

  for condition in tdd direct; do
    for bug in bug1 bug2; do
      local patch_file="$SCRIPT_DIR/${bug}-discount.patch"
      if [ "$bug" = "bug2" ]; then
        patch_file="$SCRIPT_DIR/bug2-cart.patch"
      fi

      for trial in $(seq "$TRIAL_START" "$trial_end"); do
        echo "[B5] condition=$condition bug=$bug trial=$trial"
        restore_project

        # Apply bug patch
        apply_patch "$patch_file"
        place_claude_md "B5-common.md"

        cd "$PROJECT_DIR"
        PROMPT_FILE="$PROMPTS_DIR/B5-${condition}-${bug}.txt"
        JSON_OUT=$(run_claude "$PROMPT_FILE")
        TOOLS=$(count_tool_calls "$JSON_OUT")

        RESULT=$("$SCRIPT_DIR/judge-b5.sh" "$PROJECT_DIR" "$condition" "$bug" "$trial")
        echo "${RESULT%,*},${TOOLS},$(timestamp)" >> "$csv"
        echo "  Result: $RESULT"

        mkdir -p "$RESULTS_DIR/B5/raw"
        echo "$JSON_OUT" > "$RESULTS_DIR/B5/raw/${condition}_${bug}_${trial}.json"
      done
    done
  done
}

run_b6() {
  local trial_end="${TRIAL_END:-7}"
  local csv="$RESULTS_DIR/B6/results.csv"
  mkdir -p "$RESULTS_DIR/B6"

  if [ ! -f "$csv" ]; then
    echo "condition,trial,eslint_errors,eslint_warnings,prettier_issues,tests_passed,tests_total,type_errors,timestamp" > "$csv"
  fi

  for condition in no-hooks hooks; do
    for trial in $(seq "$TRIAL_START" "$trial_end"); do
      echo "[B6] condition=$condition trial=$trial"
      restore_project
      place_claude_md "B6-common.md"

      # Set up hooks for condition B
      if [ "$condition" = "hooks" ]; then
        mkdir -p "$PROJECT_DIR/.claude"
        cp "$BASE_DIR/hooks-variants/B6-hooks-settings.json" "$PROJECT_DIR/.claude/settings.json"
        echo "  Hooks enabled"
      fi

      cd "$PROJECT_DIR"
      JSON_OUT=$(run_claude "$PROMPTS_DIR/B6-prompt.txt")

      RESULT=$("$SCRIPT_DIR/judge-b6.sh" "$PROJECT_DIR" "$condition" "$trial")
      echo "${RESULT},$(timestamp)" >> "$csv"
      echo "  Result: $RESULT"

      mkdir -p "$RESULTS_DIR/B6/raw"
      echo "$JSON_OUT" > "$RESULTS_DIR/B6/raw/${condition}_${trial}.json"
    done
  done
}

# --- Main ---

echo "======================================"
echo "Phase 4B Experiment Runner"
echo "Experiment: $EXPERIMENT"
echo "Trials: $TRIAL_START - ${TRIAL_END:-default}"
echo "======================================"

case "$EXPERIMENT" in
  B1) run_b1 ;;
  B2) run_b2 ;;
  B3) run_b3 ;;
  B4) run_b4 ;;
  B5) run_b5 ;;
  B6) run_b6 ;;
  *)
    echo "Unknown experiment: $EXPERIMENT"
    echo "Usage: $0 <B1|B2|B3|B4|B5|B6> [trial_start] [trial_end]"
    exit 1
    ;;
esac

echo ""
echo "Done! Results saved to $RESULTS_DIR/$EXPERIMENT/results.csv"
