#!/usr/bin/env bash
# Regenerate the problem index table in README.md between the
# <!-- PROBLEM_INDEX:START --> / <!-- PROBLEM_INDEX:END --> markers.
#
# The table is written with padded, aligned columns and a blank line on each
# side of it (the style used by the other tables in the docs, and what Markdown
# linters expect).
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
README="$REPO_ROOT/README.md"
START_MARKER="<!-- PROBLEM_INDEX:START -->"
END_MARKER="<!-- PROBLEM_INDEX:END -->"

TABLE_FILE="$(mktemp)"
trap 'rm -f "$TABLE_FILE" "$README.tmp"' EXIT

ext_to_lang() {
  case "$1" in
    go) echo "Go" ;;
    py) echo "Python" ;;
    js) echo "JavaScript" ;;
    ts) echo "TypeScript" ;;
    cpp) echo "C++" ;;
    rs) echo "Rust" ;;
    *) echo "$1" ;;
  esac
}

platforms=()
problems=()
langs=()
while IFS= read -r -d '' solution_file; do
  dir="$(dirname "$solution_file")"
  rel_dir="${dir#"$REPO_ROOT"/}"
  platform="$(echo "$rel_dir" | cut -d/ -f2)"
  slug="$(basename "$dir")"
  ext="${solution_file##*.}"
  lang="$(ext_to_lang "$ext")"

  title="$slug"
  readme="$dir/README.md"
  if [[ -f "$readme" ]]; then
    extracted="$(head -n1 "$readme" | sed -E 's/^#\s*//')"
    [[ -n "$extracted" ]] && title="$extracted"
  fi
  title="${title//|/\\|}" # a raw | would split the table cell

  platforms+=("$platform")
  problems+=("[${title}](problems/${platform}/${slug})")
  langs+=("$lang")
done < <(find "$REPO_ROOT/problems" -mindepth 3 -maxdepth 3 -type f \
  \( -name 'solution.go' -o -name 'solution.py' -o -name 'solution.js' \
     -o -name 'solution.ts' -o -name 'solution.cpp' -o -name 'solution.rs' \) \
  -print0 | sort -z)

if [[ "${#platforms[@]}" -eq 0 ]]; then
  platforms=('_(none yet — run `make new` to add one)_')
  problems=("")
  langs=("")
fi

# Column widths: the longest cell in each column, header included.
w0=8 w1=7 w2=8 # "Platform", "Problem", "Language"
for i in "${!platforms[@]}"; do
  ((${#platforms[i]} > w0)) && w0=${#platforms[i]}
  ((${#problems[i]} > w1)) && w1=${#problems[i]}
  ((${#langs[i]} > w2)) && w2=${#langs[i]}
done

pad() { printf '%s%*s' "$1" $(($2 - ${#1})) ''; }
dashes() { printf '%*s' $(($1 + 2)) '' | tr ' ' '-'; }

{
  echo "| $(pad Platform "$w0") | $(pad Problem "$w1") | $(pad Language "$w2") |"
  echo "|$(dashes "$w0")|$(dashes "$w1")|$(dashes "$w2")|"
  for i in "${!platforms[@]}"; do
    echo "| $(pad "${platforms[i]}" "$w0") | $(pad "${problems[i]}" "$w1") | $(pad "${langs[i]}" "$w2") |"
  done
} > "$TABLE_FILE"

if ! grep -q "$START_MARKER" "$README" 2>/dev/null; then
  {
    echo ""
    echo "## Problem Index"
    echo ""
    echo "$START_MARKER"
    echo ""
    cat "$TABLE_FILE"
    echo ""
    echo "$END_MARKER"
  } >> "$README"
else
  # The table is read from a file, not passed with `awk -v`, because -v would
  # interpret backslash escapes in problem titles.
  awk -v start="$START_MARKER" -v end="$END_MARKER" -v tf="$TABLE_FILE" '
    $0 ~ start { print; print ""; while ((getline line < tf) > 0) print line; close(tf); print ""; skip=1; next }
    $0 ~ end { skip=0 }
    !skip { print }
  ' "$README" > "$README.tmp"
  mv "$README.tmp" "$README"
fi

echo "Problem index regenerated."
