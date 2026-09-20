#!/usr/bin/env bash
# Run tests for one or all problem directories, dispatching by language.
# Skips (with a warning) if the required toolchain isn't installed locally.
# Colors, VERBOSE and NO_COLOR/FORCE_COLOR are documented in helpers/ui.sh.
#
# Usage:
#   helpers/run_tests.sh                 # run tests for every problem
#   helpers/run_tests.sh problems/leetcode/0001-two-sum
set -uo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TARGET="${1:-$REPO_ROOT/problems}"

# shellcheck source=helpers/ui.sh
source "$REPO_ROOT/helpers/ui.sh"

run_in_dir() {
  local dir="$1"
  local rel="${dir#"$REPO_ROOT"/}"

  if [[ -f "$dir/go.mod" ]]; then
    if have go; then
      run_step go "$dir" "go test ./..."
    else
      skip go "$rel" "go not installed"
    fi
  elif [[ -f "$dir/test_solution.py" ]]; then
    local color_flag=""
    [[ -n "$GREEN" ]] && color_flag="--color=yes"
    if have pytest; then
      run_step python "$dir" "pytest -q $color_flag"
    elif have python3; then
      run_step python "$dir" "python3 -m pytest -q $color_flag"
    else
      skip python "$rel" "python/pytest not installed"
    fi
  elif [[ -f "$dir/solution.test.js" ]]; then
    if node_deps_ready; then
      run_step javascript "$dir" "npx --no-install jest --config '{}' solution.test.js"
    else
      skip javascript "$rel" "$NODE_SKIP_REASON"
    fi
  elif [[ -f "$dir/solution.test.ts" ]]; then
    if node_deps_ready; then
      run_step typescript "$dir" "npx --no-install jest --config '{\"preset\":\"ts-jest\"}' solution.test.ts"
    else
      skip typescript "$rel" "$NODE_SKIP_REASON"
    fi
  elif [[ -f "$dir/test.cpp" ]]; then
    if have g++; then
      run_step cpp "$dir" "g++ -std=c++17 -o '$WORK_DIR/test_bin' test.cpp solution.cpp && '$WORK_DIR/test_bin'"
    else
      skip cpp "$rel" "g++ not installed"
    fi
  elif [[ -f "$dir/solution.rs" ]]; then
    if have rustc; then
      run_step rust "$dir" "rustc --edition 2021 --test -o '$WORK_DIR/rust_test_bin' solution.rs && '$WORK_DIR/rust_test_bin' --include-ignored"
    else
      skip rust "$rel" "rustc not installed"
    fi
  fi
}

ui_header "Running tests"

if [[ -f "$TARGET/solution.go" || -f "$TARGET/solution.py" || -f "$TARGET/solution.js" || -f "$TARGET/solution.ts" || -f "$TARGET/solution.cpp" || -f "$TARGET/solution.rs" ]]; then
  run_in_dir "$TARGET"
else
  while IFS= read -r -d '' dir; do
    run_in_dir "$dir"
  done < <(find "$TARGET" -type f -name 'solution.*' -exec dirname {} \; | sort -u | tr '\n' '\0')
fi

ui_summary "tests"
