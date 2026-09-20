#!/usr/bin/env bash
# Run benchmarks for one or all problem directories, dispatching by language.
# Skips (with a warning) if the required toolchain isn't installed locally.
# Colors and NO_COLOR/FORCE_COLOR are documented in helpers/ui.sh. Unlike tests,
# the benchmark output is always shown, because the timings are the result.
#
# Usage:
#   helpers/run_bench.sh                 # benchmark every problem (can be slow)
#   helpers/run_bench.sh problems/leetcode/0001-two-sum
set -uo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TARGET="${1:-$REPO_ROOT/problems}"

UI_PASS_LABEL="DONE"
UI_PASS_WORD="completed"
VERBOSE=1

# shellcheck source=helpers/ui.sh
source "$REPO_ROOT/helpers/ui.sh"

bench_dir() {
  local dir="$1"
  local rel="${dir#"$REPO_ROOT"/}"

  if [[ -f "$dir/go.mod" ]]; then
    if [[ ! -f "$dir/benchmark_test.go" ]]; then
      skip go "$rel" "no benchmark_test.go"
    elif have go; then
      run_step go "$dir" "go test -bench=. -benchmem -run='^\$' ./..."
    else
      skip go "$rel" "go not installed"
    fi
  elif [[ -f "$dir/solution.py" ]]; then
    if [[ ! -f "$dir/benchmark.py" ]]; then
      skip python "$rel" "no benchmark.py"
    elif have python3; then
      run_step python "$dir" "python3 benchmark.py"
    else
      skip python "$rel" "python3 not installed"
    fi
  elif [[ -f "$dir/solution.js" ]]; then
    if [[ ! -f "$dir/benchmark.js" ]]; then
      skip javascript "$rel" "no benchmark.js"
    elif have node; then
      run_step javascript "$dir" "node benchmark.js"
    else
      skip javascript "$rel" "node not installed"
    fi
  elif [[ -f "$dir/solution.ts" ]]; then
    if [[ ! -f "$dir/benchmark.ts" ]]; then
      skip typescript "$rel" "no benchmark.ts"
    elif node_deps_ready; then
      run_step typescript "$dir" "npx --no-install ts-node benchmark.ts"
    else
      skip typescript "$rel" "$NODE_SKIP_REASON"
    fi
  elif [[ -f "$dir/solution.cpp" ]]; then
    if [[ ! -f "$dir/benchmark.cpp" ]]; then
      skip cpp "$rel" "no benchmark.cpp"
    elif have g++; then
      run_step cpp "$dir" "g++ -std=c++20 -O2 -o '$WORK_DIR/bench' benchmark.cpp solution.cpp && '$WORK_DIR/bench'"
    else
      skip cpp "$rel" "g++ not installed"
    fi
  elif [[ -f "$dir/solution.rs" ]]; then
    if [[ ! -f "$dir/benchmark.rs" ]]; then
      skip rust "$rel" "no benchmark.rs"
    elif have rustc; then
      run_step rust "$dir" "rustc --edition 2021 -O -o '$WORK_DIR/bench' benchmark.rs && '$WORK_DIR/bench'"
    else
      skip rust "$rel" "rustc not installed"
    fi
  fi
}

ui_header "Running benchmarks"

if [[ -f "$TARGET/solution.go" || -f "$TARGET/solution.py" || -f "$TARGET/solution.js" || -f "$TARGET/solution.ts" || -f "$TARGET/solution.cpp" || -f "$TARGET/solution.rs" ]]; then
  bench_dir "$TARGET"
else
  while IFS= read -r -d '' dir; do
    bench_dir "$dir"
  done < <(find "$TARGET" -type f -name 'solution.*' -exec dirname {} \; | sort -u | tr '\n' '\0')
fi

ui_summary "benchmarks"
