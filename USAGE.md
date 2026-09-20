# Usage Guide

This is the complete, step-by-step guide to using this repo: from creating a brand
new problem, to implementing it, to testing/benchmarking/linting it, to keeping the
README index up to date. If you only read one doc in this repo, read this one.

For quick reference see also:

- `problems/README.md` — directory layout & slug/naming conventions
- `patterns/README.md` — cross-reference index of problem-solving techniques

---

## 1. How the repo is organized

```txt
problems/
  leetcode/<slug>/     # LeetCode problems, slug = NNNN-kebab-title
  codeforces/<slug>/   # Codeforces problems, slug = <contest+letter>-kebab-title
  codewars/<slug>/     # Codewars kata, slug = freeform kebab-case kata name
  other/<slug>/        # Company/custom questions, slug = freeform kebab-case
patterns/
  README.md            # index of techniques -> links to problems that use them
  two-pointers.md, sliding-window.md, binary-search.md, ...
helpers/
  templates/<lang>/    # per-language file templates used when scaffolding
  new_problem.sh       # scaffolds a new problem folder (used by `make new`)
  fetch_problem.py     # fetches a problem's title/tags/statement from its URL
  run_tests.sh         # dispatches `make test` to the right test runner
  run_lint.sh          # dispatches `make lint` to the right linter
  ui.sh                # shared colors/icons/summary used by run_tests.sh and run_lint.sh
  generate_index.sh    # regenerates the problem table in README.md
  makefile             # actual Makefile target logic (included by root Makefile)
.claude/
  skills/              # Claude Code skills: /git-commit, /problem-readme
  agents/              # Claude Code agents: hint-coach, solution-reviewer, test-writer, problem-documenter
.github/workflows/     # CI: runs `make test` and `make lint` on every push/PR
package.json           # pinned JS/TS tooling (jest, ts-jest, eslint, ...); run `npm install` once
eslint.config.js       # ESLint flat config for JS/TS problems
Makefile               # thin wrapper: `include helpers/makefile`
```

Lint/format settings live in the repo root: `.clang-format` (Google style, 4
spaces, 100 columns), `ruff.toml`, `.golangci.yml` (golangci-lint v2 format),
`rustfmt.toml`, `.prettierrc` and `eslint.config.js`.

Each problem is a self-contained folder with a solution file, a test file, a
benchmark file, and a `README.md` describing the problem — all generated
automatically by the scaffold script.

Supported languages: **Go, Python, JavaScript, TypeScript, C++, Rust** — one
language per problem (pick the language when you scaffold it).

## 2. Prerequisites

You don't need every toolchain installed — `make test` and `make lint` detect
what's available and print `skip (... not installed): <path>` for anything
missing, without failing the whole run. Install only what you plan to use:

| Language   | Needed for tests                  | Needed for lint                                |
|------------|-----------------------------------|------------------------------------------------|
| Go         | `go`                              | `golangci-lint` v2 (or `gofmt`, used as fallback) |
| Python     | `python3` + `pytest`              | `ruff`                                         |
| JavaScript | `node` + `npm install` (jest)     | `node` + `npm install` (eslint)                |
| TypeScript | `node` + `npm install` (ts-jest)  | `node` + `npm install` (eslint)                |
| C++        | `g++`                             | `clang-format`                                 |
| Rust       | `rustc`                           | `rustfmt`                                      |

For JavaScript/TypeScript, run `npm install` once in the repo root. The
tools (jest, ts-jest, eslint, typescript, ts-node, prettier) are pinned in
`package.json` / `package-lock.json` and run from `node_modules`, so nothing is
downloaded on the fly. Until you do, JS/TS problems are skipped with
`run 'npm install' first`. Needs Node 20.19+, 22.13+, or 24+.

### Installing the toolchains

Only install what you need. These commands work on Linux (adapt them for your
OS or package manager), and none of them needs `sudo` except `apt`:

| Tool                | How to install                                                                                     |
|---------------------|----------------------------------------------------------------------------------------------------|
| Go + `gofmt`        | Download the tarball from <https://go.dev/dl/>, extract it (e.g. to `~/.local/go`), and add its `bin/` to `PATH` |
| `golangci-lint` v2  | `go install github.com/golangci/golangci-lint/v2/cmd/golangci-lint@latest` (needs `~/go/bin` on `PATH`) |
| Python tools        | `pip install pytest ruff`. If your system blocks that (PEP 668), install each one separately with `uv tool install <tool>` or `pipx install <tool>` |
| `clang-format`      | `pip install clang-format` (or `uv tool install clang-format`), or `sudo apt install clang-format` |
| Rust + `rustfmt`    | `rustup` from <https://rustup.rs> (`rustup component add rustfmt` if it is missing)              |
| Node packages       | Install Node 20.19+/22.13+/24+, then `npm install` in the repo root                                |

Make sure the install locations (`~/.local/bin`, `~/go/bin`, `~/.cargo/bin`,
`~/.local/go/bin`) are on your `PATH`, for example in `~/.zshrc` or
`~/.bashrc`. Open a new terminal afterwards.

> **golangci-lint v1 vs v2.** The install path *without* `/v2` gives you v1,
> which rejects this repo's `.golangci.yml` ("unsupported version of the
> configuration"). Use the `/v2` path above.

CI (`.github/workflows/ci.yml`) installs all of the above automatically
(including `npm ci`), so everything is checked on every push/PR regardless of
what you have locally.

## 3. Step-by-step: solving a new problem

### Step 1 — Decide platform, language, and identifiers

- **Platform**: `leetcode`, `codeforces`, `codewars`, or `other`.
- **Language**: `go`, `python`, `javascript`, `typescript`, `cpp`, or `rust`.
- **NUM** is *required* for `leetcode` (the problem number, e.g. `1` or `0001`)
  and for `codeforces` (contest+letter, e.g. `4a`). Not used for `codewars` or
  `other` — Codewars kata don't have numeric IDs, so note the kata's kyu rank
  in the generated README's Difficulty field instead (e.g. `6 kyu`).
- **NAME** is the problem slug/title source (e.g. `two-sum`); it gets lowercased
  and normalized to kebab-case automatically.

### Step 2 — Scaffold the problem

```sh
# LeetCode — slug becomes 0001-two-sum (NUM is zero-padded to 4 digits)
make new PLATFORM=leetcode LANG=go NUM=1 NAME=two-sum URL=https://leetcode.com/problems/two-sum/ TITLE="Two Sum"

# Codeforces — slug becomes 4a-watermelon
make new PLATFORM=codeforces LANG=python NUM=4a NAME=watermelon

# Codewars — slug becomes multiply-numbers (no NUM needed)
make new PLATFORM=codewars LANG=python NAME=multiply-numbers URL=https://www.codewars.com/kata/... TITLE="Multiply Numbers"

# Other/custom — slug becomes acme-rotate-array (no NUM needed)
make new PLATFORM=other LANG=rust NAME=acme-rotate-array
```

Arguments:

| Arg        | Required | Notes                                                                             |
|------------|----------|-----------------------------------------------------------------------------------|
| `PLATFORM` | yes      | `leetcode` \| `codeforces` \| `codewars` \| `other`                               |
| `LANG`     | yes      | `go` \| `python` \| `javascript` \| `typescript` \| `cpp` \| `rust`               |
| `NAME`     | yes      | freeform; normalized to kebab-case                                                |
| `NUM`      | leetcode/codeforces only | leetcode: any int, zero-padded to 4 digits; codeforces: e.g. `4a` |
| `URL`      | no       | source URL, inserted into solution header + README                                |
| `TITLE`    | no       | human title; auto-derived from `NAME` if omitted (`two-sum` → `Two Sum`)          |

`TITLE` and `URL` may contain spaces and characters such as `&`, `?` or `'`;
just quote them as in the examples above. If the target folder already exists,
the script errors out instead of overwriting it.

### Step 3 — Tour of the generated folder

Files created depend on the language (all under `problems/<platform>/<slug>/`):

- **Go**: `solution.go`, `solution_test.go`, `benchmark_test.go`, `go.mod`, `README.md`
- **Python**: `solution.py`, `test_solution.py`, `benchmark.py`, `README.md`
- **JavaScript**: `solution.js`, `solution.test.js`, `benchmark.js`, `README.md`
- **TypeScript**: `solution.ts`, `solution.test.ts`, `benchmark.ts`, `tsconfig.json`, `README.md`
- **C++**: `solution.cpp`, `solution.h`, `test.cpp`, `benchmark.cpp`, `README.md`
- **Rust**: `solution.rs` (contains the solution, `main`, and `#[cfg(test)] mod tests`), `README.md`

Every `README.md` starts with a template: Platform / Language / Link /
Difficulty / Tags, plus **Problem**, **Approach**, and **Complexity** sections
to fill in.

### Step 4 — Fill in the problem README

Open `problems/<platform>/<slug>/README.md` and replace the `TODO` placeholders:
paste/summarize the problem statement, note difficulty and tags, and (once
solved) describe your approach and time/space complexity.

**Shortcut: let Claude do Steps 2 and 4 from a URL.** In Claude Code, run:

```txt
/problem-readme https://leetcode.com/problems/contains-duplicate-ii/ cpp
```

It fetches the title, difficulty, tags, examples and constraints, runs
`make new` with the right number, slug, title and link, and fills the README
(the statement is paraphrased; examples and constraints are copied verbatim).
Approach and Complexity stay `TODO` until you solve it (the `problem-documenter`
agent can fill them in afterwards; see [section 9](#9-working-with-claude-code-optional)).

| Site        | What is fetched                                                          |
|-------------|--------------------------------------------------------------------------|
| LeetCode    | Everything, through LeetCode's unofficial GraphQL endpoint (it may change) |
| Codewars    | Everything, through the official API                                     |
| Codeforces  | Title, rating and tags only; you paste the statement text                |
| Other sites | Nothing; you paste the statement text                                    |

Premium LeetCode problems have no public statement, so you paste it too. The
fetch step is `helpers/fetch_problem.py <url>`, which you can also run on its
own to see the JSON.

### Step 5 — Implement the solution

Edit `solution.<ext>` and replace the `TODO`/`unimplemented!`/`NotImplementedError`
stub with your real implementation. Example (Go, for a problem whose slug is
`0001-two-sum`, so the package is `p_0001_two_sum`):

```go
package p_0001_two_sum

func Solve(nums []int, target int) []int {
    seen := make(map[int]int, len(nums))
    for i, n := range nums {
        if j, ok := seen[target-n]; ok {
            return []int{j, i}
        }
        seen[n] = i
    }
    return nil
}
```

### Step 6 — Write real test cases

Replace the skipped placeholder test (`t.Skip(...)` / `@pytest.mark.skip(...)` /
`test.skip(...)` / `#[ignore]`) with real assertions. Example (Go):

```go
func TestSolve(t *testing.T) {
    cases := []struct {
        nums   []int
        target int
        want   []int
    }{
        {[]int{2, 7, 11, 15}, 9, []int{0, 1}},
        {[]int{3, 2, 4}, 6, []int{1, 2}},
    }
    for _, c := range cases {
        if got := Solve(c.nums, c.target); !reflect.DeepEqual(got, c.want) {
            t.Errorf("Solve(%v, %d) = %v, want %v", c.nums, c.target, got, c.want)
        }
    }
}
```

Tip: cover the examples from the statement plus edge cases (empty input, a
single element, duplicates, negative numbers, zero, maximum sizes). In Claude
Code, the `test-writer` agent can do this for you.

### Step 7 — Run the tests

```sh
make test                                          # run every problem's tests
make test DIR=problems/leetcode/0001-two-sum        # run just this one
```

Each problem prints one line with its result, language and time, followed by
a summary. Output for a passing Go problem:

```txt
▶ Running tests
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  ✓ PASS  go          problems/leetcode/0001-two-sum  0.33s
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 ✓ 1 passed   ✗ 0 failed   ○ 0 skipped   0.34s

All tests passed.
```

- In a terminal the output is colored: green for pass, red for fail, yellow
  for skip, and a color per language.
- A failing problem prints `✗ FAIL`, then the tool's full output indented under
  a red bar, and the summary lists every failed problem. The command exits with
  status 1. Passing problems only show their one-line result.
- A problem whose toolchain is missing prints `○ SKIP  <lang>  <path>  (<reason>)`
  and does not count as a failure.

Output options (environment variables, work for `make test` and `make lint`):

| Variable         | Effect                                                                 |
|------------------|------------------------------------------------------------------------|
| `VERBOSE=1`      | Also show the tool's output for passing problems                       |
| `NO_COLOR=1`     | Turn colors off (this is automatic when output is piped or in CI)      |
| `FORCE_COLOR=1`  | Keep colors when piping                                                |

For example: `VERBOSE=1 make test DIR=problems/leetcode/0001-two-sum`. If the
terminal isn't UTF-8, the icons fall back to `ok`, `x` and `-`. To restyle the
output (colors, icons, layout), edit `helpers/ui.sh`, which both commands share.

### Step 8 — Run the benchmark

There's no single `make bench` target (benchmark tooling differs too much per
language) — run the language's native benchmark command directly inside the
problem folder:

```sh
cd problems/leetcode/0001-two-sum

# Go
go test -bench=. -run=^$

# Python
python benchmark.py

# JavaScript
node benchmark.js

# TypeScript (needs `npm install` once in the repo root)
npx ts-node benchmark.ts

# C++
g++ -std=c++17 -O2 -o /tmp/bench benchmark.cpp solution.cpp && /tmp/bench

# Rust
rustc --edition 2021 -O -o /tmp/bench solution.rs && /tmp/bench
```

Example Go output:

```txt
BenchmarkSolve-16     30715885         38.82 ns/op
```

### Step 9 — Lint

```sh
make lint                                          # lint every problem
make lint DIR=problems/leetcode/0001-two-sum        # lint just this one
```

The output has the same layout as `make test`. Fix anything reported, or run the
formatter for auto-fixable issues: `gofmt -w`, `ruff format`,
`npx prettier --write`, `clang-format -i` (C++), `rustfmt`. A freshly scaffolded
problem passes lint in every language, with or without a `URL`. After you edit
C++ files, run `clang-format -i solution.cpp solution.h test.cpp benchmark.cpp`
inside the problem folder.

### Step 10 — Update the problem index and commit

```sh
make index    # regenerates the Problem Index table in README.md
git add problems/<platform>/<slug> README.md patterns/
```

Then commit. In Claude Code, `/git-commit` writes a
[Conventional Commits](https://www.conventionalcommits.org/) message from the
staged changes and only commits after you approve the exact text, for example
`feat(leetcode): solve 0001 two-sum in Go`. Its scopes come from the changed
paths: `leetcode`, `codeforces`, `codewars`, `other`, `patterns`, `helpers`,
`ci`, `docs`, `claude` and `lint`. Without Claude Code, write the same style of
message with plain `git commit -m "..."`.

`make index` is idempotent — running it multiple times won't duplicate rows.

## 4. Full worked example (start to finish)

```sh
# 1. Scaffold
make new PLATFORM=leetcode LANG=go NUM=1 NAME=two-sum \
  URL=https://leetcode.com/problems/two-sum/ TITLE="Two Sum"
# -> Created problems/leetcode/0001-two-sum

# 2. Implement solution.go (see Step 5 above)
# 3. Write solution_test.go (see Step 6 above)

# 4. Test
make test DIR=problems/leetcode/0001-two-sum
# -> ok  p_0001_two_sum  0.002s

# 5. Benchmark
cd problems/leetcode/0001-two-sum && go test -bench=. -run=^$ && cd -
# -> BenchmarkSolve-16   30715885   38.82 ns/op

# 6. Lint
make lint DIR=problems/leetcode/0001-two-sum

# 7. Update index and commit
make index
git add problems/leetcode/0001-two-sum README.md
git commit -m "feat(leetcode): solve 0001 two-sum in Go"
```

## 5. Cross-referencing a pattern

If your solution uses a known technique (two pointers, sliding window, binary
search, DP, BFS/DFS, ...), add a link under the matching file in `patterns/`:

```markdown
## Problems
- [leetcode/0001-two-sum](../problems/leetcode/0001-two-sum) (Go)
```

If the technique doesn't have a file yet, create `patterns/<pattern-name>.md`
and add it to the index in `patterns/README.md`.

## 6. Makefile reference

| Target       | Arguments                                                     | Description                                                 |
|--------------|---------------------------------------------------------------|-------------------------------------------------------------|
| `make new`   | `PLATFORM=`, `LANG=`, `NAME=`, `[NUM=]`, `[URL=]`, `[TITLE=]` | Scaffold a new problem folder from templates                |
| `make test`  | `[DIR=<problem-path>]`                                        | Run tests for one problem, or all problems if `DIR` omitted |
| `make lint`  | `[DIR=<problem-path>]`                                        | Lint one problem, or all problems if `DIR` omitted          |
| `make index` | —                                                             | Regenerate the Problem Index table in root `README.md`      |

`make test` and `make lint` also read the environment variables `VERBOSE`,
`NO_COLOR` and `FORCE_COLOR` (see Step 7).

## 7. Troubleshooting

- **`Problem folder already exists: ...`** — `make new` refuses to overwrite an
  existing problem folder; choose a different `NAME`/`NUM` or delete the old
  folder first.
- **`NUM is required for PLATFORM=leetcode/codeforces`** — pass `NUM=...`; it's
  optional for `PLATFORM=codewars` and `PLATFORM=other`.
- **`skip (<tool> not installed): <path>`** — the test/lint runner detected a
  missing toolchain and skipped that problem instead of failing; install the
  toolchain locally, or rely on CI which installs everything.
- **`skip ... (run 'npm install' first)`** — JS/TS problems need the pinned tools
  from `package.json`; run `npm install` once in the repo root.
- **`unsupported version of the configuration` from golangci-lint** — you have
  golangci-lint v1. Install v2 with
  `go install github.com/golangci/golangci-lint/v2/cmd/golangci-lint@latest`.
- **`make lint` fails on C++ formatting** — run `clang-format -i` on the files it
  lists (`solution.cpp`, `solution.h`, `test.cpp`, `benchmark.cpp`). The style is
  Google-based with 4-space indents; see `.clang-format`.
- **A C++ test passes but prints `TODO: add test cases`** — the scaffold's test
  has no assertions yet. Add real ones (Step 6) so it can actually fail.
- **TypeScript: `Cannot find name 'test'`** — make sure the problem's
  `tsconfig.json` has `"types": ["jest", "node"]` (new scaffolds do).
- **`/problem-readme` can't fetch a problem** — LeetCode's endpoint is unofficial
  and may be rate-limited, Codeforces and premium problems have no public
  statement, and unknown sites aren't fetched. Paste the statement when asked.
- **The new Claude Code skill or agent isn't found** — skills and agents are
  loaded when Claude Code starts; restart it (or open `/agents`).
- **Slug looks different than expected** — `NAME` is always lowercased and
  non-alphanumeric characters are collapsed to single hyphens (e.g.
  `Two Sum!!` → `two-sum`).
- **Go package name errors** — package names are derived from the slug with
  hyphens replaced by underscores, and prefixed with `p_` if the slug starts
  with a digit (e.g. slug `0001-two-sum` → package `p_0001_two_sum`).

## 8. FAQ / tips

- **Why one language per problem instead of multiple?** Keeps each problem
  folder simple (single toolchain, single set of files) and matches how most
  people practice — pick the language when you scaffold, per problem.
- **Local vs. CI**: locally, `make test`/`make lint` skip toolchains you don't
  have installed; CI (`.github/workflows/ci.yml`) always installs Go, Python,
  Node (with `npm ci`), Rust, and clang-format, so nothing is silently skipped
  there. CI output has no colors because it isn't a terminal.
- **Is a green `make test` on a fresh scaffold meaningful?** No. The placeholder
  test is skipped (or, for C++, has no assertions), so replace it (Step 6)
  before trusting a green run.
- **Can I restyle the terminal output?** Yes: colors, icons, separator width and
  labels all live in `helpers/ui.sh`.
- **Re-running `make index` is safe** — it replaces content between
  `<!-- PROBLEM_INDEX:START -->` / `<!-- PROBLEM_INDEX:END -->` markers in
  `README.md`, so it never duplicates rows.

## 9. Working with Claude Code (optional)

Everything above works without any AI tooling. If you use
[Claude Code](https://claude.com/claude-code) in this folder, `.claude/` adds two
skills (slash commands) and four agents that automate the tedious steps around
solving a problem. None of them commits anything on their own.

**Skills**

| Command                          | What it does                                                                                     |
|----------------------------------|--------------------------------------------------------------------------------------------------|
| `/problem-readme <url> [lang]`   | Fetches the problem, runs `make new`, and fills the README (Step 4 shortcut)                     |
| `/git-commit`                    | Writes a Conventional Commits message from the staged changes; you approve the exact text first  |

**Agents** (Claude picks them when the task fits, or ask for one by name)

| Agent                | Use it to...                                                                                              | Can edit files?        |
|----------------------|-----------------------------------------------------------------------------------------------------------|------------------------|
| `hint-coach`         | Get progressive hints when you're stuck, without being shown the solution                                  | No (read-only)         |
| `solution-reviewer`  | Review a finished solution: correctness, edge cases, complexity claims, leftover stubs; runs test and lint | No (read-only)         |
| `test-writer`        | Replace the placeholder test with real cases and edge cases, then run test and lint                        | Only the test file     |
| `problem-documenter` | Fill the README's Approach/Complexity, link the problem under `patterns/`, and run `make index`            | README, `patterns/`    |

**A typical session**

```txt
/problem-readme https://leetcode.com/problems/contains-duplicate-ii/ cpp
   ...you solve it (ask hint-coach if you get stuck)...
"use test-writer on problems/leetcode/0219-contains-duplicate-ii"
"use solution-reviewer on problems/leetcode/0219-contains-duplicate-ii"
"use problem-documenter on problems/leetcode/0219-contains-duplicate-ii"
git add problems/leetcode/0219-contains-duplicate-ii README.md patterns/
/git-commit
```

Skills and agents are plain Markdown files (`.claude/skills/<name>/SKILL.md`
and `.claude/agents/<name>.md`), so you can read and change them. They are
loaded when Claude Code starts.
