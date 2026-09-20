# Shared terminal UI for helpers/run_tests.sh and helpers/run_lint.sh.
# Meant to be sourced, not executed. Requires REPO_ROOT to be set by the caller.
#
# Output:
#   Colors and icons are used when stdout is a terminal. Set NO_COLOR=1 to
#   disable them, or FORCE_COLOR=1 to keep them when piping (e.g. in CI).
#   Passing steps print one line each; the full tool output is shown only for
#   failures. Set VERBOSE=1 to always show it.
#
# Provides: run_step, skip, ui_header, ui_summary, plus $WORK_DIR (a temp dir
# removed on exit) and the color variables ($GREEN, $RED, ...).

PASSED=0
FAILED=0
SKIPPED=0
FAILED_NAMES=()

WORK_DIR="$(mktemp -d)"
trap 'rm -rf "$WORK_DIR"' EXIT

if [[ -n "${FORCE_COLOR:-}" || ( -t 1 && -z "${NO_COLOR:-}" ) ]]; then
  BOLD=$'\e[1m'; DIM=$'\e[2m'; RESET=$'\e[0m'
  RED=$'\e[31m'; GREEN=$'\e[32m'; YELLOW=$'\e[33m'; BLUE=$'\e[34m'
  MAGENTA=$'\e[35m'; CYAN=$'\e[36m'
else
  BOLD=""; DIM=""; RESET=""
  RED=""; GREEN=""; YELLOW=""; BLUE=""; MAGENTA=""; CYAN=""
fi

if [[ "${LC_ALL:-${LC_CTYPE:-${LANG:-}}}" == *[Uu][Tt][Ff]-8* ]]; then
  ICON_PASS="✓"; ICON_FAIL="✗"; ICON_SKIP="○"; ICON_START="▶"; RULE_CHAR="━"
else
  ICON_PASS="ok"; ICON_FAIL="x"; ICON_SKIP="-"; ICON_START=">"; RULE_CHAR="="
fi

rule() {
  local line
  printf -v line '%*s' "${1:-56}" ''
  printf '%s%s%s\n' "$DIM" "${line// /$RULE_CHAR}" "$RESET"
}

now_ms() {
  local n
  n="$(date +%s%N 2>/dev/null)"
  if [[ "$n" =~ ^[0-9]+$ ]]; then echo $((n / 1000000)); else echo $(($(date +%s) * 1000)); fi
}

fmt_ms() {
  local ms="$1"
  printf '%d.%02ds' $((ms / 1000)) $(((ms % 1000) / 10))
}

# Language badge, padded to a fixed width so the columns line up.
badge() {
  local color
  case "$1" in
    go) color="$CYAN" ;;
    python) color="$YELLOW" ;;
    javascript) color="$YELLOW" ;;
    typescript) color="$BLUE" ;;
    cpp) color="$MAGENTA" ;;
    rust) color="$RED" ;;
    *) color="$RESET" ;;
  esac
  printf '%s%-10s%s' "$color" "$1" "$RESET"
}

have() { command -v "$1" >/dev/null 2>&1; }

# skip <lang> <problem rel path> <reason>
skip() {
  local lang="$1" rel="$2" reason="$3"
  SKIPPED=$((SKIPPED + 1))
  printf '  %s%s SKIP%s  %s  %s  %s(%s)%s\n' \
    "$YELLOW" "$ICON_SKIP" "$RESET" "$(badge "$lang")" "$rel" "$DIM" "$reason" "$RESET"
}

# run_step <lang> <problem dir> <shell command>
# Runs the command inside the problem dir, captures its output, and prints a
# one-line result. Output is shown in full only on failure (or with VERBOSE=1).
run_step() {
  local lang="$1" dir="$2" cmd="$3"
  local rel="${dir#"$REPO_ROOT"/}"
  local out="$WORK_DIR/out.txt"
  local start end elapsed status

  start="$(now_ms)"
  (cd "$dir" && eval "$cmd") >"$out" 2>&1
  status=$?
  end="$(now_ms)"
  elapsed="$(fmt_ms $((end - start)))"

  if [[ "$status" -eq 0 ]]; then
    PASSED=$((PASSED + 1))
    printf '  %s%s PASS%s  %s  %s  %s%s%s\n' \
      "$GREEN$BOLD" "$ICON_PASS" "$RESET" "$(badge "$lang")" "$rel" "$DIM" "$elapsed" "$RESET"
  else
    FAILED=$((FAILED + 1))
    FAILED_NAMES+=("$rel")
    printf '  %s%s FAIL%s  %s  %s  %s%s%s\n' \
      "$RED$BOLD" "$ICON_FAIL" "$RESET" "$(badge "$lang")" "$rel" "$DIM" "$elapsed" "$RESET"
  fi

  if [[ "$status" -ne 0 || -n "${VERBOSE:-}" ]] && [[ -s "$out" ]]; then
    local color="$DIM"
    [[ "$status" -ne 0 ]] && color="$RED"
    sed "s/^/      ${color}│${RESET} /" "$out"
    echo
  fi
}

# ui_header <title>
ui_header() {
  printf '\n%s%s %s%s\n' "$BOLD" "$ICON_START" "$1" "$RESET"
  rule
  SUITE_START="$(now_ms)"
}

# ui_summary <noun>   e.g. "tests" or "lint checks"
# Prints the totals and exits 1 if anything failed, 0 otherwise.
ui_summary() {
  local noun="$1"
  local elapsed total
  elapsed="$(fmt_ms $(($(now_ms) - SUITE_START)))"
  total=$((PASSED + FAILED + SKIPPED))

  rule
  if [[ "$total" -eq 0 ]]; then
    echo "${YELLOW}No $noun ran (no problems found).${RESET}"
    echo
    exit 0
  fi

  printf ' %s%s %d passed%s   %s%s %d failed%s   %s%s %d skipped%s   %s%s%s\n' \
    "$GREEN$BOLD" "$ICON_PASS" "$PASSED" "$RESET" \
    "$RED$BOLD" "$ICON_FAIL" "$FAILED" "$RESET" \
    "$YELLOW$BOLD" "$ICON_SKIP" "$SKIPPED" "$RESET" \
    "$DIM" "$elapsed" "$RESET"

  if [[ "$FAILED" -gt 0 ]]; then
    printf '\n%s%s Failed:%s\n' "$RED$BOLD" "$ICON_FAIL" "$RESET"
    local name
    for name in "${FAILED_NAMES[@]}"; do
      printf '   %s%s%s\n' "$RED" "$name" "$RESET"
    done
    echo
    exit 1
  fi

  echo
  if [[ "$PASSED" -eq 0 ]]; then
    echo "${YELLOW}No $noun ran (every toolchain was skipped).${RESET}"
  else
    echo "${GREEN}${BOLD}All $noun passed.${RESET}"
  fi
  echo
  exit 0
}
