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
  run_tests.sh         # dispatches `make test` to the right test runner
  run_lint.sh          # dispatches `make lint` to the right linter
  generate_index.sh    # regenerates the problem table in README.md
  makefile             # actual Makefile target logic (included by root Makefile)
Makefile               # thin wrapper: `include helpers/makefile`
```

Each problem is a self-contained folder with a solution file, a test file, a
benchmark file, and a `README.md` describing the problem — all generated
automatically by the scaffold script.

Supported languages: **Go, Python, JavaScript, TypeScript, C++, Rust** — one
language per problem (pick the language when you scaffold it).

## 2. Prerequisites

You don't need every toolchain installed — `make test` and `make lint` detect
what's available and print `skip (... not installed): <path>` for anything
missing, without failing the whole run. Install only what you plan to use:

| Language   | Needed for tests           | Needed for lint                                |
|------------|----------------------------|------------------------------------------------|
| Go         | `go`                       | `golangci-lint` (or `gofmt`, used as fallback) |
| Python     | `python3` + `pytest`       | `ruff`                                         |
| JavaScript | `node` + `npm install` (jest) | `node` + `npm install` (eslint)             |
| TypeScript | `node` + `npm install` (ts-jest) | `node` + `npm install` (eslint)          |
| C++        | `g++`                      | `clang-format`                                 |
| Rust       | `rustc`                    | `rustfmt`                                      |

For JavaScript/TypeScript, run `npm install` once in the repo root. The
tools (jest, ts-jest, eslint, typescript, ts-node, prettier) are pinned in
`package.json` / `package-lock.json` and run from `node_modules`, so nothing is
downloaded on the fly. Until you do, JS/TS problems are skipped with
`run 'npm install' first`. Needs Node 20.19+, 22.13+, or 24+.

CI (`.github/workflows/ci.yml`) installs all of the above automatically, so
everything is checked on every push/PR regardless of what you have locally.

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

If the target folder already exists, the script errors out instead of
overwriting it.

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

### Step 5 — Implement the solution

Edit `solution.<ext>` and replace the `TODO`/`unimplemented!`/`NotImplementedError`
stub with your real implementation. Example (Go, from the included
`problems/leetcode/0001-two-sum/solution.go`):

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

### Step 7 — Run the tests

```sh
make test                                          # run every problem's tests
make test DIR=problems/leetcode/0001-two-sum        # run just this one
```

Expected output for a passing Go problem:

```txt
== go test: problems/leetcode/0001-two-sum ==
ok  p_0001_two_sum 0.002s
```

If a toolchain isn't installed you'll see `skip (go not installed): problems/...`
instead of a failure.

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

# TypeScript
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

Fix anything reported (or run the formatter, e.g. `gofmt -w`, `ruff format`,
`npx prettier --write`, `clang-format -i`, `rustfmt`, for auto-fixable issues).

### Step 10 — Update the problem index and commit

```sh
make index    # regenerates the Problem Index table in README.md
git add -A
git commit -m "Solve <platform>/<slug>"
```

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
git add -A && git commit -m "Solve leetcode/0001-two-sum"
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

## 7. Troubleshooting

- **`Problem folder already exists: ...`** — `make new` refuses to overwrite an
  existing problem folder; choose a different `NAME`/`NUM` or delete the old
  folder first.
- **`NUM is required for PLATFORM=leetcode/codeforces`** — pass `NUM=...`; it's
  optional for `PLATFORM=codewars` and `PLATFORM=other`.
- **`skip (<tool> not installed): <path>`** — the test/lint runner detected a
  missing toolchain and skipped that problem instead of failing; install the
  toolchain locally, or rely on CI which installs everything.
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
  Node, Rust, and clang-format, so nothing is silently skipped there.
- **Re-running `make index` is safe** — it replaces content between
  `<!-- PROBLEM_INDEX:START -->` / `<!-- PROBLEM_INDEX:END -->` markers in
  `README.md`, so it never duplicates rows.
