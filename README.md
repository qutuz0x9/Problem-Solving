# Problem-Solving

A personal, multi-language workspace for practicing coding problems — LeetCode,
Codeforces, Codewars, and custom/company interview questions — with automated
scaffolding, per-language testing, linting and benchmarking, and an
auto-generated problem index.

## ✨ Features

- **One command to start a new problem** — `make new` scaffolds a full folder
  (solution, tests, benchmark, README) from a template, per platform and language.
- **Multi-language support** — Go, Python, JavaScript, TypeScript, C++, and Rust,
  one language per problem, chosen at creation time.
- **Smart dispatch** — `make test`, `make lint` and `make bench` detect the
  language of each problem and run the right tool, with colored output and a
  summary. A missing toolchain is skipped, not a failure.
- **Benchmarks included** — every problem gets a benchmark harness that times
  your solution on five input sizes (10 to 100,000) and shows how the time grows.
- **Auto-generated problem index** — `make index` keeps the table below in sync
  with everything under `problems/`.
- **CI-ready** — GitHub Actions runs tests, lint and the docs check across all
  toolchains on every push/PR.
- **Docs that lint clean** — `make docs` checks every Markdown file (markdownlint rules, aligned tables, links and
  anchors), the editor uses the same rules, and CI runs it.
- **Optional Claude Code helpers** — build a problem's README from its URL, plus
  agents for hints, reviews, tests, docs, benchmarks and patterns.

## 📁 Project structure

```txt
problems/              # solved problems, organized by platform
  leetcode/<slug>/     # e.g. 0001-two-sum
  codeforces/<slug>/   # e.g. 4a-watermelon
  codewars/<slug>/     # e.g. multiply-numbers
  other/<slug>/        # company/custom questions
patterns/              # cross-reference index of problem-solving techniques
helpers/               # scaffold, fetch, test/lint/bench dispatch, index generator, templates
.claude/               # Claude Code skills and agents (optional)
.github/workflows/     # CI: runs `make test`, `make lint` and `make docs` on every push/PR
package.json           # pinned JS/TS tooling; run `npm install` once
eslint.config.js       # ESLint flat config for JS/TS problems
.markdownlint.jsonc     # Markdown lint rules (also read by the editor)
Makefile               # make new / test / lint / bench / docs / index
```

Each problem folder holds a solution file, a test file, a benchmark file and a
`README.md` (statement, approach, complexity). See
[`USAGE.md` §1](USAGE.md#1-how-the-repo-is-organized) for the full layout.

## 🚀 Quick start

```sh
npm install                                             # once, only for JS/TS problems

make new PLATFORM=leetcode LANG=go NUM=1 NAME=two-sum \
  URL=https://leetcode.com/problems/two-sum/ TITLE="Two Sum"   # scaffold a problem
make test  DIR=problems/leetcode/0001-two-sum           # run its tests
make bench DIR=problems/leetcode/0001-two-sum           # benchmark it
make lint  DIR=problems/leetcode/0001-two-sum           # lint it
make index                                              # refresh the index below
make docs                                               # check the Markdown docs
```

Leave `DIR` off to run a command for every problem. Install only the toolchains
you plan to use (see [Supported languages](#-supported-platforms--languages)).

## 🔁 Workflow at a glance

The same ten steps as in [`USAGE.md` §3](USAGE.md#3-step-by-step-solving-a-new-problem):

1. **Decide** the platform, language and identifiers (`NUM` is needed for LeetCode and Codeforces).
2. **Scaffold** with `make new`.
3. **Tour** the generated files (they differ per language).
4. **Fill in the README**: statement, difficulty, tags.
5. **Implement** `solution.<ext>`.
6. **Write real tests**, replacing the placeholder.
7. **Run the tests**: `make test`.
8. **Run the benchmark**: `make bench`.
9. **Lint**: `make lint`.
10. **Update the index and commit**: `make index`, `make docs`, then commit.

For the agent-assisted version of these steps, with a diagram, a C++ example and the push to GitHub, see
[`WORKFLOW.md`](WORKFLOW.md).

Output options for `make test`, `make lint`, `make bench` and `make docs`: `NO_COLOR=1`
turns colors off, `FORCE_COLOR=1` keeps them when piping, and `VERBOSE=1` also
shows passing output for test and lint.

## 🧩 Supported platforms & languages

**Platforms:** LeetCode, Codeforces, Codewars, and Other/custom.

| Language   | `make test`       | `make lint`                           | `make bench`     |
|------------|-------------------|---------------------------------------|------------------|
| Go         | `go test`         | `golangci-lint` v2 (`gofmt` fallback) | `go test -bench` |
| Python     | `pytest`          | `ruff`                                | `python3`        |
| JavaScript | `jest`            | `eslint`                              | `node`           |
| TypeScript | `ts-jest`         | `eslint`                              | `ts-node`        |
| C++        | `g++` 10+ (C++20) | `clang-format`                        | `g++ -O2`        |
| Rust       | `rustc --test`    | `rustfmt`                             | `rustc -O`       |

You don't need every toolchain: the runners skip what isn't installed, and CI
installs everything. Install commands are in
[`USAGE.md` §2](USAGE.md#2-prerequisites).

## 🤖 Claude Code (optional)

Everything works without AI tooling. With [Claude Code](https://claude.com/claude-code),
`.claude/` adds three skills and six agents (details in
[`USAGE.md` §9](USAGE.md#9-working-with-claude-code-optional) and
[`AGENTS_USAGE.md`](AGENTS_USAGE.md)); none of them commits on its own.

| Skill or agent                 | What it does                                                                                                                                |
|--------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------|
| `/problem-readme <url> [lang]` | Fetches a problem, runs `make new`, and fills the README                                                                                    |
| `/docs-check`                  | Checks and fixes the Markdown docs (`make docs FIX=1`), then repairs what is left                                                           |
| `/git-commit`                  | Writes a Conventional Commits message; you approve it before it commits                                                                     |
| `hint-coach`                   | Gives hints without revealing the solution                                                                                                  |
| `solution-reviewer`            | Reviews a solution (read-only) and runs test and lint                                                                                       |
| `test-writer`                  | Replaces the placeholder test with real cases                                                                                               |
| `problem-documenter`           | Fills Approach/Complexity, links a pattern, runs `make index`                                                                               |
| `benchmark-runner`             | Writes the benchmark input builder and checks growth vs your complexity claim                                                               |
| `pattern-tutor`                | Studies a pattern by following `.claude/prompts/study-pattern.md` (diagrams, verified C++ example, summary table); writes `patterns/` files |

Claude also follows `.claude/rules/markdown.md`, and a hook lints every Markdown file it edits and reports the
problems back, so docs it writes pass `make docs` the first time.

## 📚 Documentation

- [`USAGE.md`](USAGE.md) — complete usage guide, start to finish (includes troubleshooting)
- [`WORKFLOW.md`](WORKFLOW.md) — one problem end to end: create a C++ problem, use the agents, push it to GitHub
- [`AGENTS_USAGE.md`](AGENTS_USAGE.md) — the Claude Code agents: when to use each, examples, output shapes
- [`problems/README.md`](problems/README.md) — directory layout & naming conventions
- [`patterns/README.md`](patterns/README.md) — pattern/technique cross-reference index
- [`CLAUDE.md`](CLAUDE.md) — guidance for Claude Code working in this repo

## Problem Index

<!-- PROBLEM_INDEX:START -->

| Platform | Problem                                                                         | Language |
|----------|---------------------------------------------------------------------------------|----------|
| leetcode | [Contains Duplicate II](problems/leetcode/0219-contains-duplicate-ii)           | C++      |
| leetcode | [Intersection of Two Arrays](problems/leetcode/0349-intersection-of-two-arrays) | C++      |

<!-- PROBLEM_INDEX:END -->
