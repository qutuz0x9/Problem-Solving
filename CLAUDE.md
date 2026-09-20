# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

A personal, multi-language workspace for practicing coding problems (LeetCode, Codeforces,
Codewars, and custom/company questions), built around a scaffolding tool that generates a
consistent per-problem folder structure across six languages, plus dispatch scripts that
run the right test/lint tool for whichever language a problem happens to use.

## Commands

```sh
make new PLATFORM=<leetcode|codeforces|codewars|other> LANG=<go|python|javascript|typescript|cpp|rust> NAME=<slug> [NUM=<id>] [URL=<url>] [TITLE=<title>]
make test [DIR=problems/<platform>/<slug>]   # all problems if DIR omitted
make lint [DIR=problems/<platform>/<slug>]   # all problems if DIR omitted
make bench [DIR=problems/<platform>/<slug>]  # all problems if DIR omitted
make docs [FIX=1] [FILE="a.md b.md"]         # check (or fix) Markdown: markdownlint, aligned tables, links
make index                                   # regenerate README.md's Problem Index table
```

- `NUM` is required for `leetcode` (zero-padded to 4 digits) and `codeforces` (e.g. `4a`);
  not used for `codewars`/`other` (note kyu rank in the problem's README `Difficulty` field instead).
- `make new` refuses to overwrite an existing problem folder.
- `make bench` runs each problem's benchmark file (`helpers/run_bench.sh`, same colored UI as
  test/lint, output always shown). Every language's benchmark template builds inputs of several
  sizes (a marked `TODO` spot in `make_input`/`makeInput`), warms up, and prints min/median ms per
  size (Go prints `go test -bench` output). A fresh scaffold's benchmark calls `solve`, so it fails
  with the stub's `TODO` error until `solve` is implemented. See `USAGE.md` Step 8.
- `make docs` lints every Markdown file (`helpers/run_docs.sh`): markdownlint with the rules in
  `.markdownlint.jsonc` (shared with the editor; line length off), aligned tables, and relative links/anchors
  (`helpers/md_tools.py`). `FIX=1` applies the automatic fixes. CI runs it. Write Markdown per
  `.claude/rules/markdown.md`: real headings (not bold lines), a language on every code fence, `<url>` instead of
  bare URLs, aligned tables.
- JS/TS tooling (jest, ts-jest, eslint, ts-node, prettier) is pinned in the root `package.json`
  and lockfile; run `npm install` once. The runners use `npx --no-install`, and JS/TS problems are
  skipped (not failed) with `run 'npm install' first` if `node_modules` is missing. ESLint uses the
  flat config in `eslint.config.js`.
- Locally, `make test`/`make lint` print `skip (<tool> not installed): <path>` and continue when
  a toolchain isn't present, rather than failing — this is expected on a machine without every
  language installed. CI (`.github/workflows/ci.yml`) always installs Go, Python, Node, Rust,
  and clang-format, so nothing is silently skipped there.

## Architecture

- `Makefile` is a thin wrapper that just `include`s `helpers/makefile`, which holds the actual
  target logic (`new`, `test`, `lint`, `index`).
- `helpers/new_problem.sh` — scaffolds a new problem folder from `helpers/templates/<lang>/`,
  substituting slug/title/URL/package-name placeholders. Go package names are derived from the
  slug with hyphens replaced by underscores, prefixed with `p_` if the slug starts with a digit
  (e.g. slug `0001-two-sum` → package `p_0001_two_sum`).
- `helpers/run_tests.sh` / `helpers/run_lint.sh` / `helpers/run_bench.sh` — detect a problem's language (by which solution
  file extension is present) and dispatch to the matching tool, skipping gracefully if that
  toolchain isn't installed. When run with no `DIR`, they walk every folder under `problems/`.
- `helpers/run_docs.sh` + `helpers/md_tools.py` — the Markdown checks behind `make docs` (same UI as the other
  runners). `.claude/hooks/md-check.sh`, wired in `.claude/settings.json`, runs them on every `.md` file Claude
  edits and feeds the problems back; `.claude/rules/markdown.md` holds the conventions; `/docs-check` is the
  on-demand skill.
- `helpers/generate_index.sh` — regenerates the Problem Index table in root `README.md` between
  the `<!-- PROBLEM_INDEX:START -->` / `<!-- PROBLEM_INDEX:END -->` markers; idempotent, safe to
  re-run.
- `problems/<platform>/<slug>/` — one self-contained folder per solved problem: a solution file,
  a test file, a benchmark file, and a `README.md` with Platform/Language/Link/Difficulty/Tags
  plus Problem/Approach/Complexity sections. One language per problem, chosen at scaffold time.
  Slug conventions live in `problems/README.md`.
- `patterns/<pattern-name>.md` — a cross-reference index of problem-solving techniques (two
  pointers, sliding window, binary search, DP, BFS/DFS), independent of the platform-based
  `problems/` organization. Each file has a short description plus a list of links to problems
  that use that technique. New pattern files must be added to the index in `patterns/README.md`.
- `.claude/skills/git-commit/` — the `/git-commit` skill: writes a Conventional Commits message
  from the staged changes and only commits after you approve the exact message. Scopes are
  derived from paths (`leetcode`, `codewars`, `patterns`, `helpers`, `ci`, `docs`, `claude`, `lint`).
- `.claude/agents/` — custom subagents for the problem workflow: `hint-coach` (hints only, never
  the solution), `solution-reviewer` (read-only review + `make test`/`make lint`), `test-writer`
  (replaces the placeholder test with real cases), and `problem-documenter` (README TODOs,
  `patterns/` link, `make index`), and `benchmark-runner` (writes the benchmark input builder, runs
  `make bench`, checks growth vs the README's complexity), and `pattern-tutor` (explains patterns
  with diagrams and verified C++ examples; writes/audits `patterns/` files). None of them commit. `AGENTS_USAGE.md` documents how to use
  them, with example outputs and output shapes.
- `.claude/skills/problem-readme/` — the `/problem-readme <url> [lang]` skill: fetches a problem via
  `helpers/fetch_problem.py` (LeetCode GraphQL, Codewars API, Codeforces metadata only), runs `make new`,
  and fills the README (paraphrased statement, verbatim examples/constraints; Approach/Complexity stay TODO).
- `.github/workflows/ci.yml` is the only thing under `.github/`.

## Adding a solved problem (typical flow)

1. `make new PLATFORM=... LANG=... NAME=... [NUM=...] [URL=...] [TITLE=...]`
2. Fill in the generated `README.md`'s TODO placeholders (problem statement, difficulty, tags).
3. Implement the solution, replacing the `TODO`/`unimplemented!`/`NotImplementedError` stub.
4. Replace the skipped placeholder test with real assertions.
5. `make test DIR=problems/<platform>/<slug>` and `make lint DIR=problems/<platform>/<slug>`.
6. If the solution uses a known pattern, add a link to it under the matching file in `patterns/`.
7. `make index` to refresh the root README table, `make docs` to check the Markdown, then commit.

Full walkthrough with worked examples: `USAGE.md`.
