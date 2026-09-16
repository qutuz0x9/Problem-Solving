#!/usr/bin/env bash
# Run tests for one or all problem directories, dispatching by language.
# Skips (with a warning) if the required toolchain isn't installed locally.
#
# Usage:
#   helpers/run_tests.sh                 # run tests for every problem
#   helpers/run_tests.sh problems/leetcode/0001-two-sum
set -uo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TARGET="${1:-$REPO_ROOT/problems}"

FAILED=0
RAN=0

have() { command -v "$1" >/dev/null 2>&1; }

run_in_dir() {
  local dir="$1"
  local rel="${dir#"$REPO_ROOT"/}"

  if [[ -f "$dir/go.mod" ]]; then
    if have go; then
      echo "== go test: $rel =="
      (cd "$dir" && go test ./...) || FAILED=1
      RAN=1
    else
      echo "skip (go not installed): $rel"
    fi
  elif [[ -f "$dir/test_solution.py" ]]; then
    if have pytest; then
      echo "== pytest: $rel =="
      (cd "$dir" && pytest -q) || FAILED=1
      RAN=1
    elif have python3; then
      echo "== python3 -m pytest: $rel =="
      (cd "$dir" && python3 -m pytest -q) || FAILED=1
      RAN=1
    else
      echo "skip (python/pytest not installed): $rel"
    fi
  elif [[ -f "$dir/solution.test.js" ]]; then
    if have npx; then
      echo "== jest: $rel =="
      (cd "$dir" && npx --yes jest --config '{}' solution.test.js) || FAILED=1
      RAN=1
    else
      echo "skip (node/npx not installed): $rel"
    fi
  elif [[ -f "$dir/solution.test.ts" ]]; then
    if have npx; then
      echo "== ts-jest: $rel =="
      (cd "$dir" && npx --yes jest --config '{"preset":"ts-jest"}' solution.test.ts) || FAILED=1
      RAN=1
    else
      echo "skip (node/npx not installed): $rel"
    fi
  elif [[ -f "$dir/test.cpp" ]]; then
    if have g++; then
      echo "== g++ test: $rel =="
      (cd "$dir" && g++ -std=c++17 -o /tmp/test_bin test.cpp solution.cpp && /tmp/test_bin) || FAILED=1
      RAN=1
    else
      echo "skip (g++ not installed): $rel"
    fi
  elif [[ -f "$dir/solution.rs" ]]; then
    if have rustc; then
      echo "== rustc --test: $rel =="
      (cd "$dir" && rustc --edition 2021 --test -o /tmp/rust_test_bin solution.rs && /tmp/rust_test_bin --include-ignored) || FAILED=1
      RAN=1
    else
      echo "skip (rustc not installed): $rel"
    fi
  fi
}

if [[ -f "$TARGET/solution.go" || -f "$TARGET/solution.py" || -f "$TARGET/solution.js" || -f "$TARGET/solution.ts" || -f "$TARGET/solution.cpp" || -f "$TARGET/solution.rs" ]]; then
  run_in_dir "$TARGET"
else
  while IFS= read -r -d '' dir; do
    run_in_dir "$dir"
  done < <(find "$TARGET" -type f -name 'solution.*' -exec dirname {} \; | sort -u | tr '\n' '\0')
fi

if [[ "$RAN" -eq 0 ]]; then
  echo "No tests ran (no problems found or no toolchains installed)."
fi

exit "$FAILED"
