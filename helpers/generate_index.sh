#!/usr/bin/env bash
# Regenerate the problem index table in README.md between the
# <!-- PROBLEM_INDEX:START --> / <!-- PROBLEM_INDEX:END --> markers.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
README="$REPO_ROOT/README.md"
START_MARKER="<!-- PROBLEM_INDEX:START -->"
END_MARKER="<!-- PROBLEM_INDEX:END -->"

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

rows=""
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

  rows+="| ${platform} | [${title}](problems/${platform}/${slug}) | ${lang} |"$'\n'
done < <(find "$REPO_ROOT/problems" -mindepth 3 -maxdepth 3 -type f -name 'solution.*' -print0 | sort -z)

TABLE="| Platform | Problem | Language |\n|---|---|---|\n"
if [[ -z "$rows" ]]; then
  TABLE+="| _(none yet — run \`make new\` to add one)_ | | |\n"
else
  TABLE+="$rows"
fi

if ! grep -q "$START_MARKER" "$README" 2>/dev/null; then
  {
    echo ""
    echo "## Problem Index"
    echo ""
    echo "$START_MARKER"
    echo -e "$TABLE"
    echo "$END_MARKER"
  } >> "$README"
else
  awk -v start="$START_MARKER" -v end="$END_MARKER" -v table="$(echo -e "$TABLE")" '
    $0 ~ start { print; print table; skip=1; next }
    $0 ~ end { skip=0 }
    !skip { print }
  ' "$README" > "$README.tmp"
  mv "$README.tmp" "$README"
fi

echo "Problem index regenerated."
