#!/usr/bin/env bash
# Scaffold a new problem folder from templates.
#
# Usage:
#   helpers/new_problem.sh PLATFORM=leetcode LANG=go NUM=0001 NAME=two-sum [URL=https://...] [TITLE="Two Sum"]
#   helpers/new_problem.sh PLATFORM=codeforces LANG=python NUM=4a NAME=watermelon
#   helpers/new_problem.sh PLATFORM=codewars LANG=python NAME=multiply-numbers
#   helpers/new_problem.sh PLATFORM=other LANG=rust NAME=acme-rotate-array
#
# Typically invoked via `make new PLATFORM=... LANG=... NAME=... [NUM=...]`.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEMPLATES_DIR="$REPO_ROOT/helpers/templates"

PLATFORM=""
LANG=""
NAME=""
NUM=""
URL=""
TITLE=""

for arg in "$@"; do
  case "$arg" in
    PLATFORM=*) PLATFORM="${arg#PLATFORM=}" ;;
    LANG=*) LANG="${arg#LANG=}" ;;
    NAME=*) NAME="${arg#NAME=}" ;;
    NUM=*) NUM="${arg#NUM=}" ;;
    URL=*) URL="${arg#URL=}" ;;
    TITLE=*) TITLE="${arg#TITLE=}" ;;
    *)
      echo "Unknown argument: $arg" >&2
      exit 1
      ;;
  esac
done

usage() {
  cat >&2 <<EOF
Usage: $0 PLATFORM=<leetcode|codeforces|codewars|other> LANG=<go|python|javascript|typescript|cpp|rust> NAME=<slug> [NUM=<id>] [URL=<url>] [TITLE=<title>]
EOF
}

if [[ -z "$PLATFORM" || -z "$LANG" || -z "$NAME" ]]; then
  usage
  exit 1
fi

case "$PLATFORM" in
  leetcode|codeforces|codewars|other) ;;
  *)
    echo "Invalid PLATFORM '$PLATFORM' (expected leetcode|codeforces|codewars|other)" >&2
    exit 1
    ;;
esac

case "$LANG" in
  go) EXT="go" ;;
  python) EXT="py" ;;
  javascript) EXT="js" ;;
  typescript) EXT="ts" ;;
  cpp) EXT="cpp" ;;
  rust) EXT="rs" ;;
  *)
    echo "Invalid LANG '$LANG' (expected go|python|javascript|typescript|cpp|rust)" >&2
    exit 1
    ;;
esac

# Normalize NAME to lowercase kebab-case.
SLUG_NAME="$(echo "$NAME" | tr '[:upper:]' '[:lower:]' | tr -c 'a-z0-9' '-' | sed -E 's/-+/-/g; s/^-|-$//g')"

case "$PLATFORM" in
  leetcode)
    if [[ -z "$NUM" ]]; then
      echo "NUM is required for PLATFORM=leetcode (e.g. NUM=0001)" >&2
      exit 1
    fi
    PADDED_NUM="$(printf '%04d' "$((10#$NUM))")"
    SLUG="${PADDED_NUM}-${SLUG_NAME}"
    ;;
  codeforces)
    if [[ -z "$NUM" ]]; then
      echo "NUM is required for PLATFORM=codeforces (e.g. NUM=4a)" >&2
      exit 1
    fi
    NUM_LOWER="$(echo "$NUM" | tr '[:upper:]' '[:lower:]')"
    SLUG="${NUM_LOWER}-${SLUG_NAME}"
    ;;
  codewars|other)
    SLUG="${SLUG_NAME}"
    ;;
esac

PROBLEM_DIR="$REPO_ROOT/problems/$PLATFORM/$SLUG"

if [[ -e "$PROBLEM_DIR" ]]; then
  echo "Problem folder already exists: $PROBLEM_DIR" >&2
  exit 1
fi

mkdir -p "$PROBLEM_DIR"

# Derive a human-friendly title if not given: "two-sum" -> "Two Sum".
if [[ -z "$TITLE" ]]; then
  TITLE="$(echo "$SLUG_NAME" | sed -E 's/(^|-)([a-z])/\1\U\2/g; s/-/ /g')"
fi

# Go package names must be valid identifiers.
PACKAGE="$(echo "$SLUG" | tr '-' '_')"
case "$PACKAGE" in
  [0-9]*) PACKAGE="p_${PACKAGE}" ;;
esac

# Escape the characters that are special in a sed replacement (/, & and \).
sed_escape() { printf '%s' "$1" | sed -e 's/[\/&\\]/\\&/g'; }

render() {
  local src="$1" dst="$2"
  local title url
  title="$(sed_escape "$TITLE")"
  url="$(sed_escape "$URL")"
  # With no URL, drop lines that hold only the URL (e.g. "// {{URL}}") instead
  # of leaving a comment with trailing whitespace, which gofmt/rustfmt reject.
  local drop_empty_url=()
  if [[ -z "$URL" ]]; then
    drop_empty_url=(
      -e '/^[[:space:]]*{{URL}}[[:space:]]*$/d'
      -e '/^[[:space:]]*\/\/ *{{URL}}[[:space:]]*$/d'
      -e '/^[[:space:]]*\/\/! *{{URL}}[[:space:]]*$/d'
      -e '/^[[:space:]]*\* *{{URL}}[[:space:]]*$/d'
    )
  fi
  sed "${drop_empty_url[@]}" \
    -e "s/{{TITLE}}/${title}/g" \
    -e "s/{{PLATFORM}}/${PLATFORM}/g" \
    -e "s/{{LANGUAGE}}/${LANG}/g" \
    -e "s/{{URL}}/${url}/g" \
    -e "s/{{PACKAGE}}/${PACKAGE}/g" \
    "$src" > "$dst"
}

LANG_TEMPLATE_DIR="$TEMPLATES_DIR/$LANG"

case "$LANG" in
  go)
    render "$LANG_TEMPLATE_DIR/solution.go" "$PROBLEM_DIR/solution.go"
    render "$LANG_TEMPLATE_DIR/solution_test.go" "$PROBLEM_DIR/solution_test.go"
    render "$LANG_TEMPLATE_DIR/benchmark_test.go" "$PROBLEM_DIR/benchmark_test.go"
    render "$LANG_TEMPLATE_DIR/go.mod" "$PROBLEM_DIR/go.mod"
    ;;
  python)
    render "$LANG_TEMPLATE_DIR/solution.py" "$PROBLEM_DIR/solution.py"
    render "$LANG_TEMPLATE_DIR/test_solution.py" "$PROBLEM_DIR/test_solution.py"
    render "$LANG_TEMPLATE_DIR/benchmark.py" "$PROBLEM_DIR/benchmark.py"
    ;;
  javascript)
    render "$LANG_TEMPLATE_DIR/solution.js" "$PROBLEM_DIR/solution.js"
    render "$LANG_TEMPLATE_DIR/solution.test.js" "$PROBLEM_DIR/solution.test.js"
    render "$LANG_TEMPLATE_DIR/benchmark.js" "$PROBLEM_DIR/benchmark.js"
    ;;
  typescript)
    render "$LANG_TEMPLATE_DIR/solution.ts" "$PROBLEM_DIR/solution.ts"
    render "$LANG_TEMPLATE_DIR/solution.test.ts" "$PROBLEM_DIR/solution.test.ts"
    render "$LANG_TEMPLATE_DIR/benchmark.ts" "$PROBLEM_DIR/benchmark.ts"
    cp "$LANG_TEMPLATE_DIR/tsconfig.json" "$PROBLEM_DIR/tsconfig.json"
    ;;
  cpp)
    render "$LANG_TEMPLATE_DIR/solution.cpp" "$PROBLEM_DIR/solution.cpp"
    cp "$LANG_TEMPLATE_DIR/solution.h" "$PROBLEM_DIR/solution.h"
    render "$LANG_TEMPLATE_DIR/test.cpp" "$PROBLEM_DIR/test.cpp"
    render "$LANG_TEMPLATE_DIR/benchmark.cpp" "$PROBLEM_DIR/benchmark.cpp"
    ;;
  rust)
    render "$LANG_TEMPLATE_DIR/solution.rs" "$PROBLEM_DIR/solution.rs"
    render "$LANG_TEMPLATE_DIR/benchmark.rs" "$PROBLEM_DIR/benchmark.rs"
    ;;
esac

render "$TEMPLATES_DIR/README.md" "$PROBLEM_DIR/README.md"

echo "Created $PROBLEM_DIR"
