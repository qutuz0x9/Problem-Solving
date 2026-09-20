#!/usr/bin/env bash
# Check (or fix) the Markdown files: markdownlint rules, aligned tables, and
# relative links/anchors. Colors and NO_COLOR/FORCE_COLOR are documented in
# helpers/ui.sh. The rules live in .markdownlint.jsonc, which the VS Code
# markdownlint extension reads too, so the editor and this command agree.
#
# Usage:
#   helpers/run_docs.sh                    # check every Markdown file
#   helpers/run_docs.sh README.md USAGE.md # check only these files
#   helpers/run_docs.sh --fix              # apply the automatic fixes, then check
set -uo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

FIX="${FIX:-}"
FILES=()
for arg in "$@"; do
  case "$arg" in
    --fix) FIX=1 ;;
    *) FILES+=("$arg") ;;
  esac
done

# With --fix, show what the fixers changed.
[[ -n "$FIX" ]] && VERBOSE=1

# shellcheck source=helpers/ui.sh
source "$REPO_ROOT/helpers/ui.sh"

# Quote the file arguments for the command strings below.
quoted=""
for f in "${FILES[@]+"${FILES[@]}"}"; do quoted+=" $(printf '%q' "$f")"; done
globs="${quoted:-\"**/*.md\"}"

md_step() {
  local label="$1" cmd="$2"
  if [[ "$cmd" == *markdownlint-cli2* ]] && ! node_deps_ready; then
    skip markdown "$label" "$NODE_SKIP_REASON"
  elif [[ "$cmd" == *md_tools.py* ]] && ! have python3; then
    skip markdown "$label" "python3 not installed"
  else
    run_step markdown "$REPO_ROOT" "$cmd" "$label"
  fi
}

if [[ -n "$FIX" ]]; then
  ui_header "Fixing docs"
  md_step "markdownlint --fix" "npx --no-install markdownlint-cli2 --fix $globs || true"
  md_step "align tables" "python3 helpers/md_tools.py tables --fix$quoted"
else
  ui_header "Checking docs"
fi

md_step "markdownlint" "npx --no-install markdownlint-cli2 $globs"
md_step "aligned tables" "python3 helpers/md_tools.py tables$quoted"
md_step "links and anchors" "python3 helpers/md_tools.py links$quoted"

ui_summary "doc checks"
