#!/usr/bin/env bash
# Lint one or all problem directories, dispatching by language.
# Skips (with a warning) if the required linter isn't installed locally.
# Colors, VERBOSE and NO_COLOR/FORCE_COLOR are documented in helpers/ui.sh.
#
# Usage:
#   helpers/run_lint.sh
#   helpers/run_lint.sh problems/leetcode/0001-two-sum
set -uo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TARGET="${1:-$REPO_ROOT/problems}"

# shellcheck source=helpers/ui.sh
source "$REPO_ROOT/helpers/ui.sh"

lint_dir() {
  local dir="$1"
  local rel="${dir#"$REPO_ROOT"/}"
  local color="never"
  [[ -n "$GREEN" ]] && color="always"

  if [[ -f "$dir/go.mod" ]]; then
    if have golangci-lint; then
      run_step go "$dir" "golangci-lint run --color $color ./..."
    elif have gofmt; then
      # gofmt -l exits 0 even when files need formatting, so fail on any output.
      run_step go "$dir" 'out="$(gofmt -l .)"; [ -z "$out" ] || { echo "needs gofmt:"; echo "$out"; exit 1; }'
    else
      skip go "$rel" "golangci-lint/gofmt not installed"
    fi
  elif [[ -f "$dir/solution.py" ]]; then
    if have ruff; then
      run_step python "$dir" "ruff check --color $color ."
    else
      skip python "$rel" "ruff not installed"
    fi
  elif [[ -f "$dir/solution.js" || -f "$dir/solution.ts" ]]; then
    local lang="javascript"
    [[ -f "$dir/solution.ts" ]] && lang="typescript"
    if node_deps_ready; then
      run_step "$lang" "$dir" "cd '$REPO_ROOT' && npx --no-install eslint --color '$dir'"
    else
      skip "$lang" "$rel" "$NODE_SKIP_REASON"
    fi
  elif [[ -f "$dir/solution.cpp" ]]; then
    if have clang-format; then
      run_step cpp "$dir" "clang-format --dry-run --Werror solution.cpp solution.h test.cpp benchmark.cpp"
    else
      skip cpp "$rel" "clang-format not installed"
    fi
  elif [[ -f "$dir/solution.rs" ]]; then
    if have rustfmt; then
      run_step rust "$dir" "rustfmt --check --color $color solution.rs"
    else
      skip rust "$rel" "rustfmt not installed"
    fi
  fi
}

ui_header "Running lint"

if [[ -f "$TARGET/solution.go" || -f "$TARGET/solution.py" || -f "$TARGET/solution.js" || -f "$TARGET/solution.ts" || -f "$TARGET/solution.cpp" || -f "$TARGET/solution.rs" ]]; then
  lint_dir "$TARGET"
else
  while IFS= read -r -d '' dir; do
    lint_dir "$dir"
  done < <(find "$TARGET" -type f -name 'solution.*' -exec dirname {} \; | sort -u | tr '\n' '\0')
fi

ui_summary "lint checks"
