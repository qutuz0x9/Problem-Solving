#!/usr/bin/env bash
# Lint one or all problem directories, dispatching by language.
# Skips (with a warning) if the required linter isn't installed locally.
#
# Usage:
#   helpers/run_lint.sh
#   helpers/run_lint.sh problems/leetcode/0001-two-sum
set -uo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TARGET="${1:-$REPO_ROOT/problems}"

FAILED=0

have() { command -v "$1" >/dev/null 2>&1; }

lint_dir() {
  local dir="$1"
  local rel="${dir#"$REPO_ROOT"/}"

  if [[ -f "$dir/go.mod" ]]; then
    if have golangci-lint; then
      echo "== golangci-lint: $rel =="
      (cd "$dir" && golangci-lint run ./...) || FAILED=1
    elif have gofmt; then
      echo "== gofmt -l: $rel =="
      local out
      out="$(gofmt -l "$dir")"
      if [[ -n "$out" ]]; then
        echo "$out"
        FAILED=1
      fi
    else
      echo "skip (golangci-lint/gofmt not installed): $rel"
    fi
  elif [[ -f "$dir/solution.py" ]]; then
    if have ruff; then
      echo "== ruff: $rel =="
      (cd "$dir" && ruff check .) || FAILED=1
    else
      echo "skip (ruff not installed): $rel"
    fi
  elif [[ -f "$dir/solution.js" || -f "$dir/solution.ts" ]]; then
    if have npx; then
      echo "== eslint: $rel =="
      (cd "$REPO_ROOT" && npx --yes eslint "$dir") || FAILED=1
    else
      echo "skip (eslint/npx not installed): $rel"
    fi
  elif [[ -f "$dir/solution.cpp" ]]; then
    if have clang-format; then
      echo "== clang-format --dry-run: $rel =="
      (cd "$dir" && clang-format --dry-run --Werror solution.cpp solution.h test.cpp benchmark.cpp) || FAILED=1
    else
      echo "skip (clang-format not installed): $rel"
    fi
  elif [[ -f "$dir/solution.rs" ]]; then
    if have rustfmt; then
      echo "== rustfmt --check: $rel =="
      (cd "$dir" && rustfmt --check solution.rs) || FAILED=1
    else
      echo "skip (rustfmt not installed): $rel"
    fi
  fi
}

if [[ -f "$TARGET/solution.go" || -f "$TARGET/solution.py" || -f "$TARGET/solution.js" || -f "$TARGET/solution.ts" || -f "$TARGET/solution.cpp" || -f "$TARGET/solution.rs" ]]; then
  lint_dir "$TARGET"
else
  while IFS= read -r -d '' dir; do
    lint_dir "$dir"
  done < <(find "$TARGET" -type f -name 'solution.*' -exec dirname {} \; | sort -u | tr '\n' '\0')
fi

exit "$FAILED"
