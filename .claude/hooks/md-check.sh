#!/usr/bin/env bash
# PostToolUse hook for Edit|Write: lint the Markdown file Claude just changed.
#
# Reads the tool call as JSON on stdin. Exits 0 when there is nothing to report
# (not a .md file, outside this repo, tools not installed, or the file is clean).
# Exits 2 with the problems on stderr, which Claude Code feeds back to Claude so
# it fixes them right away. The rules are in .markdownlint.jsonc and
# .claude/rules/markdown.md; `make docs FIX=1 FILE=<path>` applies the automatic fixes.
set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

file="$(python3 -c 'import json, sys; print((json.load(sys.stdin).get("tool_input") or {}).get("file_path", ""))' 2>/dev/null)"

[[ "$file" == *.md && -f "$file" ]] || exit 0
case "$file" in "$ROOT"/*) ;; *) exit 0 ;; esac
[[ -d "$ROOT/node_modules" ]] || exit 0 # tools not installed; `make docs` says so

rel="${file#"$ROOT"/}"
report="$(
  cd "$ROOT" || exit 0
  npx --no-install markdownlint-cli2 "$rel" 2>&1 | grep -E ' error MD'
  python3 helpers/md_tools.py tables "$rel"
  python3 helpers/md_tools.py links "$rel"
)"

if [[ -n "$report" ]]; then
  {
    echo "Markdown problems in $rel (rules: .claude/rules/markdown.md). Fix them, or run: make docs FIX=1 FILE=$rel"
    echo "$report"
  } >&2
  exit 2
fi
exit 0
