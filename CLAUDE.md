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
make index                                   # regenerate README.md's Problem Index table
```

- `NUM` is required for `leetcode` (zero-padded to 4 digits) and `codeforces` (e.g. `4a`);
  not used for `codewars`/`other` (note kyu rank in the problem's README `Difficulty` field instead).
- `make new` refuses to overwrite an existing problem folder.
- There is no single benchmark target — run the language's native benchmark command directly
  inside the problem folder (see `USAGE.md` §8 for the exact command per language, e.g.
  `go test -bench=. -run=^$`, `python benchmark.py`, `npx ts-node benchmark.ts`, etc.).
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
- `helpers/run_tests.sh` / `helpers/run_lint.sh` — detect a problem's language (by which solution
  file extension is present) and dispatch to the matching tool, skipping gracefully if that
  toolchain isn't installed. When run with no `DIR`, they walk every folder under `problems/`.
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
- `.github/workflows/ci.yml` is the only thing under `.github/`.

## Adding a solved problem (typical flow)

1. `make new PLATFORM=... LANG=... NAME=... [NUM=...] [URL=...] [TITLE=...]`
2. Fill in the generated `README.md`'s TODO placeholders (problem statement, difficulty, tags).
3. Implement the solution, replacing the `TODO`/`unimplemented!`/`NotImplementedError` stub.
4. Replace the skipped placeholder test with real assertions.
5. `make test DIR=problems/<platform>/<slug>` and `make lint DIR=problems/<platform>/<slug>`.
6. If the solution uses a known pattern, add a link to it under the matching file in `patterns/`.
7. `make index` to refresh the root README table, then commit.

Full walkthrough with worked examples: `USAGE.md`.
