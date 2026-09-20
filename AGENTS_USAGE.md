# Agents Usage Guide

How to use the six Claude Code agents in this repo: when to call each one, what to say, what it reads and changes,
and what its answer looks like. For the rest of the repo (scaffolding, tests, benchmarks, lint) see
[`USAGE.md`](USAGE.md); this guide expands [`USAGE.md` §9](USAGE.md#9-working-with-claude-code-optional).

> **About the examples.** Every example output below is **illustrative**: I wrote it from this repo's real problems
> (`0219-contains-duplicate-ii`, `0349-intersection-of-two-arrays`) to show the *shape* of an answer. It is not
> captured output, and real answers vary in wording, length and numbers. The "output shape" of each agent is taken
> from its prompt in `.claude/agents/<name>.md`; where a prompt has no fixed template, this guide says so.

## 1. Overview

| Agent                | Use it to...                                                          | Reads                                 | Changes                    | Model  |
|----------------------|-----------------------------------------------------------------------|---------------------------------------|----------------------------|--------|
| `hint-coach`         | Get hints when stuck, without the solution                            | Problem folder, `patterns/`           | Nothing (read-only)        | sonnet |
| `solution-reviewer`  | Review a finished solution and run test and lint                      | The whole problem folder              | Nothing (read-only)        | sonnet |
| `test-writer`        | Replace the placeholder test with real cases                          | README, solution, language template   | Only the test file         | sonnet |
| `problem-documenter` | Fill README TODOs, link a pattern, refresh the index                  | README, solution, `patterns/`         | README, `patterns/`, index | haiku  |
| `benchmark-runner`   | Write the benchmark input builder and check growth vs your complexity | README, solution, benchmark file      | Only the benchmark file    | sonnet |
| `pattern-tutor`      | Explain patterns; write or audit `patterns/` files                    | `patterns/`, and a problem when asked | Only files in `patterns/`  | sonnet |

What every agent has in common:

- It reads `CLAUDE.md` first and works on one problem folder (or, for `pattern-tutor`, on `patterns/`).
- It **never commits and never stages**. Commit with [`/git-commit`](USAGE.md#step-10--update-the-problem-index-and-commit).
- The agents that need a working solution (`test-writer`, `problem-documenter`, `benchmark-runner`) **stop and tell you**
  if the solution is still a stub. `solution-reviewer` reports it as a blocking issue instead.
- Each one has hard limits on what it may edit (the "Changes" column), so you can run it without reviewing every
  file, and `git diff` shows exactly what it touched.

## 2. Calling an agent

There are two ways:

1. **By name**, which is the reliable one. Say which agent and give the folder:

   ```txt
   use solution-reviewer on problems/leetcode/0219-contains-duplicate-ii
   ```

2. **Automatically.** Claude picks an agent when your request matches its description, for example "I'm stuck on
   0219, give me a hint" reaches `hint-coach`.

Good to know:

- An agent starts **fresh**: it does not remember your conversation. Give it the problem folder (or the pattern
  name) and any context it needs, such as "I tried a nested loop and it times out".
- What you read back is **Claude's relay of the agent's report**. If you want every line, ask "show me the full
  report".
- Agents are loaded when Claude Code starts. After adding or editing one, restart Claude Code or open `/agents`.
- You can chain them: run one, fix what it found, run the next (see [section 4](#4-putting-them-together)).

## 3. The agents

### 3.1 hint-coach

**Use it when** you are stuck and want a nudge, want your approach checked, or do not understand why an attempt
fails, but you do **not** want the answer.

**Try saying:**

- `use hint-coach on problems/leetcode/0219-contains-duplicate-ii, I'm stuck`
- `next hint`
- `hint-coach: why does my solution fail on nums = [1,2,3,1], k = 3?`

**Reads** the problem `README.md` and your `solution.<ext>`; may look at `patterns/` to name a technique. It never
opens other problems' solutions.

**Changes** nothing (its tools are read-only).

**Hard rule:** it never writes solution code and never gives the full algorithm at once. If you ask for the
solution it says so and tells you to ask the main Claude session.

**Output shape.** There is no fixed template, but it follows a ladder, one hint per answer, and says which level it
is giving. You move up only by saying you are still stuck:

| Level | Name      | What you get                                                                                |
|-------|-----------|---------------------------------------------------------------------------------------------|
| 1     | Reframe   | The task restated, the brute-force cost, and a question about the bottleneck                |
| 2     | Direction | The family of technique or data structure, without how to use it                            |
| 3     | Key idea  | The invariant or observation in words, plus a tiny worked example                           |
| 4     | Structure | The state you keep, what updates per step, when to stop, and the edge cases (no pseudocode) |

When you share an attempt it finds where it breaks with a small failing input, points at the wrong line or idea, and
asks a question that leads you to the fix.

**Example (illustrative):**

```txt
> use hint-coach on problems/leetcode/0219-contains-duplicate-ii

Level 1: Reframe

You need to know whether some value appears at two positions i and j with
abs(i - j) <= k. Comparing every pair costs O(n^2), and n can reach 10^5.

Which part of that brute force repeats work? What would you like to remember
while you scan the array once from left to right?

> next hint

Level 2: Direction

Two things are worth thinking about: a structure that answers "have I seen this
value, and where?" in constant time, and the fact that only the last k
positions can matter. Which pattern in patterns/ fits both ideas?
```

### 3.2 solution-reviewer

**Use it when** you finished a solution and want it checked before you commit.

**Try saying:**

- `use solution-reviewer on problems/leetcode/0219-contains-duplicate-ii`
- `review my solution for 0349, focus on edge cases`

**Reads** every file in the problem folder. **Runs** only `make test DIR=...` and `make lint DIR=...`, plus read-only
`git` commands. **Changes** nothing.

**What it checks:** unfinished work (`TODO`, stubs, skipped tests, README placeholders), correctness (off-by-one,
overflow, duplicates), edge cases and which ones your tests miss, complexity versus the README's claim, language
idioms, whether the tests can actually fail, and the result of test and lint.

**Output shape** (fixed, from its prompt). Every finding cites `file:line`, and it does not rewrite your solution:

```txt
Verdict: ready | needs changes | blocked

Blocking issues
- <file>:<line> — what is wrong, and a failing input if it has one

Should fix
- <file>:<line> — ...

Suggestions
- ...

make test: pass|fail|skipped   make lint: pass|fail|skipped
```

**Example (illustrative):**

```txt
Verdict: needs changes

Blocking issues
- problems/leetcode/0219-contains-duplicate-ii/solution.cpp:12 — the distance check uses `<`, but the statement says
  abs(i - j) <= k. Fails Example 1: nums = [1,2,3,1], k = 3 returns false, expected true.

Should fix
- problems/leetcode/0219-contains-duplicate-ii/test.cpp:8 — the test only prints "TODO: add test cases"; nothing is
  asserted, so it cannot fail.
- problems/leetcode/0219-contains-duplicate-ii/README.md:49 — the Complexity section is still TODO.

Suggestions
- The map is never trimmed, so space is O(n). Keeping only the last k positions (a sliding window over a set) gives O(k).

make test: pass   make lint: fail
```

### 3.3 test-writer

**Use it when** the solution works and the problem's test file is still the scaffold placeholder.

**Try saying:**

- `use test-writer on problems/leetcode/0219-contains-duplicate-ii`
- `test-writer: add tests for k = 0 and repeated values on 0349`

**Reads** the README (statement and constraints), your solution and the language template in
`helpers/templates/<lang>/`. **Changes only the test file**:

| Language   | File it edits               | Style                                         |
|------------|-----------------------------|-----------------------------------------------|
| Go         | `solution_test.go`          | Table-driven tests with `t.Run`               |
| Python     | `test_solution.py`          | `pytest` with `@pytest.mark.parametrize`      |
| JavaScript | `solution.test.js`          | jest with `test.each`                         |
| TypeScript | `solution.test.ts`          | jest with ts-jest, typed cases, no `any`      |
| C++        | `test.cpp`                  | `assert` in `main`, a success line at the end |
| Rust       | `solution.rs` (`mod tests`) | `#[test]` functions, `#[ignore]` removed      |

It covers the statement's examples, edge cases (empty, single element, duplicates, negatives, zero, sizes at the
constraint limits), and cases that separate a correct solution from a plausible wrong one. It works out expected
values **by hand from the statement**, not by copying your solution's output. It formats the file, then runs test
and lint. If a test fails and it thinks your solution is wrong, it does **not** edit the solution: it reports the
input, the expected value and the actual value.

**Stops** if the solution is still a stub.

**Output shape.** No fixed template. The prompt asks for these parts:

```txt
- which cases were added
- which edge cases they cover
- make test result and make lint result (a skipped check is called "did not run", not "pass")
- (only if a test fails) the failing input, expected value and actual value
```

**Example (illustrative):**

```txt
Replaced the TODO stub in problems/leetcode/0219-contains-duplicate-ii/test.cpp with 10 assert-based cases.

Statement examples
- [1,2,3,1], k=3 -> true    - [1,0,1,1], k=1 -> true    - [1,2,3,1,2,3], k=2 -> false

Edge cases
- k = 0 with a duplicate: [1,1], k=0 -> false
- single element: [5], k=1 -> false
- all equal: [7,7,7], k=1 -> true
- duplicate exactly k apart (true) vs k+1 apart (false), to catch < versus <=
- negative values: [-1,-1], k=1 -> true
- 100000 distinct values -> false

Expected values were worked out by hand from the statement. Formatted with clang-format -i.
make test: pass   make lint: pass
```

### 3.4 problem-documenter

**Use it when** the solution and its tests are done and you want the paperwork finished.

**Try saying:**

- `use problem-documenter on problems/leetcode/0219-contains-duplicate-ii`

**Does three things:**

1. **Fills the problem README** from the template: a clean title (the root index uses it), Link, Difficulty, Tags, a
   paraphrased Problem, and **Approach and Complexity derived from your actual code**. It leaves no `TODO`, and asks
   you instead of guessing difficulty, tags, a URL or a statement it does not know.
2. **Links the problem under `patterns/`**: adds `- [leetcode/0219-...](../problems/leetcode/0219-...) (C++)` under
   `## Problems` in the matching pattern file (or creates a new pattern file and indexes it). If the file has your
   uncommitted edits it makes only a minimal insertion and tells you.
3. **Refreshes the index** with `make index`, and checks that only the index table changed.

**Reads** the README, the solution and `patterns/`. **Runs** `make index`, `make docs` and read-only `git` commands. **Stops** if
the solution is still a stub.

**Output shape.** No fixed template. The prompt asks for:

```txt
- every file changed
- what was filled in
- which pattern(s) were linked
- anything it was unsure about (difficulty, tags, statement)
- a suggestion to commit with /git-commit
```

**Example (illustrative):**

```txt
Changed files
- problems/leetcode/0219-contains-duplicate-ii/README.md: Approach and Complexity filled in (hash map of last
  seen index; O(n) time, O(n) space). No TODO left.
- patterns/sliding-window.md: added one link under ## Problems. The file has your uncommitted edits, so I made a
  one-line insertion and touched nothing else.
- README.md: ran make index; only the Problem Index table was checked, and the row title is correct.

Linked patterns: sliding-window
Unsure: nothing. Difficulty and tags were already filled in.
Next: stage these files and run /git-commit.
```

### 3.5 benchmark-runner

**Use it when** the solution works and you want to know how fast it is, or whether it scales the way your README
claims.

**Try saying:**

- `use benchmark-runner on problems/leetcode/0219-contains-duplicate-ii`
- `benchmark-runner: compare the hash-map solution with a brute force on 0219`

**Reads** the README (constraints and Complexity), the solution and the benchmark file. **Changes only the benchmark
file.** It fills in the input builder for size `n` (a worst-case, deterministic input matched to `solve`'s
signature), adjusts the sizes (default 10, 100, 1,000, 10,000 and 100,000; lower for slow solutions), makes sure the compiler
cannot delete the timed call, then runs `make bench DIR=...` two or three times. To compare approaches it puts the
alternatives inside the benchmark file and never edits your solution.

**How it reads the numbers:** in the `growth` column (each size is 10x the last), `O(n)` should show about x10,
`O(n log n)` about x12-15, and `O(n^2)` about x100. It flags a mismatch with your README's claim, and ignores the smallest size
when timer noise dominates. It never reports a number it did not see: if a toolchain is missing it says the
benchmark did not run.

**Stops** if the solution is still a stub.

**Output shape.** No fixed template. The prompt asks for:

```txt
- the table it measured (all sizes, and each approach if several were compared)
- the growth factor between sizes, next to the claimed complexity
- a one-line verdict
- every edit made to the benchmark file
- (if noticed) a correctness problem in the solution, reported and not fixed
```

**Example (illustrative):**

```txt
Input: n distinct values (worst case for the hash map: nothing repeats), k = n / 2, built once per size.
Edited: problems/leetcode/0219-contains-duplicate-ii/benchmark.cpp (input builder, result kept alive with Keep()).

  size            min ms     median ms    growth
  10            0.000900      0.001000         -
  100           0.007000      0.007200      x7.8
  1000          0.062000      0.064000      x8.9
  10000         0.660000      0.670000     x10.6
  100000        6.800000      6.900000     x10.3

Growth per 10x step: about x10 at the larger sizes. Claimed complexity: O(n), which predicts about x10.
The smallest size is timer noise, so I ignored it. Ran 3 times; results agreed within 5%.
Verdict: the timings match the O(n) claim in the README.
```

### 3.6 pattern-tutor

**Use it when** you want to understand a technique, know which pattern fits a problem, or want a `patterns/` file
written, improved or checked. It has two jobs (and a quiz mode).

**Try saying:**

- `use pattern-tutor to explain sliding window`
- `which pattern fits problems/leetcode/0349-intersection-of-two-arrays?`
- `pattern-tutor: how do I tell two pointers from sliding window?`
- `pattern-tutor: quiz me on patterns`
- `pattern-tutor: write patterns/hash-map.md`
- `pattern-tutor: audit patterns/`

**Job 1: explain (in chat, no edits).** It uses a *different* example from the problem you are working on. If you
ask which pattern fits a problem you have **not solved yet**, it names the pattern and its signals but does not lay
out the algorithm (use `hint-coach` for that). If the problem is already implemented, it can discuss it freely.

**Output shape (explain).** No rigid template, but it covers these parts, in this order:

```txt
1. The idea, in one or two sentences
2. Signals in the statement and constraints, and when NOT to use it
3. A diagram (ASCII, or Mermaid for flows and graphs)
4. A small worked example, traced step by step
5. A C++ template (compiled and run before it is shown)
6. Complexity, common mistakes and edge cases, related patterns and how to tell them apart
```

**Example (illustrative), explain:**

````txt
Sliding window (fixed size)

Idea: keep a window [l..r] and update a running value by adding the element that enters and dropping the one that
leaves, instead of recomputing it from scratch. O(n) instead of O(n*k).

Signals: "subarray or substring of length k", "longest/shortest contiguous part such that ...", one left-to-right pass.
Not for: a sum target with negative numbers (the window cannot be shrunk greedily). Use prefix sums + a hash map.

  index:   0  1  2  3  4  5      k = 3
  value:  [2  1  5  1  3  2]
           [---------]          sum = 8
              [---------]       sum = 8 - 2 + 1 = 7
                 [---------]    sum = 7 - 1 + 3 = 9   <- best
                    [---------] sum = 9 - 5 + 2 = 6

int MaxWindowSum(const std::vector<int>& a, int k) {
    int sum = 0;
    for (int i = 0; i < k; i++) sum += a[i];
    int best = sum;
    for (size_t r = k; r < a.size(); r++) {
        sum += a[r] - a[r - k];  // add the entering element, drop the leaving one
        best = std::max(best, sum);
    }
    return best;
}
// {2, 1, 5, 1, 3, 2}, k = 3 -> 9        (compiled with g++ -std=c++20 -Wall -Wextra and run)

Complexity: O(n) time, O(1) space.
Common mistakes: forgetting the first window, an off-by-one at a[r - k], using it with negative numbers and a sum target.
Related: two pointers (a variable window is two pointers moving the same way); prefix sums (when the window cannot shrink).
````

**Quiz mode.** It gives a paraphrased problem statement, waits for you to name the pattern, then reveals the answer
and the signals you should have spotted.

**Job 2: write, update or audit `patterns/`.** Pattern files use this layout, in order: *When to use*, *Core idea*,
*Template*, *Walkthrough*, *Variants*, *Complexity*, *Common mistakes and edge cases*, *Related patterns*, *Practice
ladder*, and finally `## Problems`. The `## Problems` list is **never rewritten** (it belongs to you and to
`problem-documenter`), it checks `git diff patterns/<file>` before editing so your uncommitted edits survive, and it
only lists practice problems it is certain exist. New pattern files are added to the index in `patterns/README.md`. It checks the files it writes with `make docs`.

**Output shape (write or audit).** No fixed template. The prompt asks for:

```txt
- the files changed, what was added, and what was preserved
- what was verified (C++ compiled and run, links checked)
- anything it was unsure about
```

**Example (illustrative), audit:**

```txt
Audit of patterns/

Index:     5 entries, 5 files. Consistent.
Layout:    0 of 5 files follow the layout (each has only a title, a TODO description and ## Problems).
TODO left: 5 of 5 files.
Links:     no entries under ## Problems yet, so nothing to check.
C++:       no code blocks yet.

Nothing was changed. Say which pattern to write first.
```

## 4. Putting them together

A typical order for one problem. Each step is a separate request, and you decide what to fix between them:

| Step | You say                                                  | What comes back                                       |
|------|----------------------------------------------------------|-------------------------------------------------------|
| 1    | `/problem-readme <url> cpp`                              | The scaffolded folder with a filled README            |
| 2    | (you solve it; `use hint-coach on ...` if you get stuck) | One hint at a time                                    |
| 3    | `use test-writer on ...`                                 | Real test cases, and test and lint results            |
| 4    | `use solution-reviewer on ...`                           | A verdict with file and line findings                 |
| 5    | `use benchmark-runner on ...`                            | A timing table and a verdict on your complexity claim |
| 6    | `use problem-documenter on ...`                          | The README, pattern link and index updated            |
| 7    | `git add <paths>` then `/git-commit`                     | A commit message for you to approve                   |

Alongside these, `use pattern-tutor to explain <technique>` whenever you want to learn the idea behind a pattern.

## 5. Which one do I use?

| You want to...                                       | Use                                        |
|------------------------------------------------------|--------------------------------------------|
| A nudge on the problem you are stuck on, no spoilers | `hint-coach`                               |
| To learn a technique, using other examples           | `pattern-tutor`                            |
| Which pattern fits a problem you have already solved | `pattern-tutor`                            |
| Your finished solution checked                       | `solution-reviewer`                        |
| Real tests instead of the placeholder                | `test-writer`                              |
| To know how fast it is, or whether it scales         | `benchmark-runner`                         |
| The README, pattern links and index finished         | `problem-documenter`                       |
| A new problem folder and README from a URL           | the `/problem-readme` skill (not an agent) |
| A commit                                             | the `/git-commit` skill (not an agent)     |

`hint-coach` versus `pattern-tutor`: `hint-coach` helps you solve *this* problem without spoiling it, one hint at a
time. `pattern-tutor` teaches the *technique* in general, with examples that are not your current problem.

## 6. Troubleshooting and customizing

- **"Agent not found"** — agents load when Claude Code starts. Restart it, or open `/agents`.
- **An agent says "the solution is still a stub"** — `test-writer`, `problem-documenter` and `benchmark-runner` stop
  until `solve` is implemented. `solution-reviewer` reports it as `Verdict: blocked` instead.
- **It did not touch a `patterns/` file I expected** — with uncommitted edits in that file, `problem-documenter` and
  `pattern-tutor` insert minimally or ask first. That is intended.
- **The answer is shorter than the examples here** — you are reading Claude's relay of the report. Ask "show me the
  full report".
- **I want to see what it changed** — run `git status` and `git diff`. Every agent's edits are limited to the files in
  the "Changes" column of [section 1](#1-overview), and none of them commits.
- **Benchmark numbers differ between runs** — that is normal noise; `benchmark-runner` runs it a few times and reports
  what it saw. See [`USAGE.md` Step 8](USAGE.md#step-8--run-the-benchmark).
- **Customizing** — an agent is a Markdown file, `.claude/agents/<name>.md`, with front matter (`name`,
  `description`, `tools`, `model`) followed by its instructions. The `description` decides when Claude picks it
  automatically, `tools` limits what it can do, and `model` picks the model. Edit the file, then restart Claude
  Code.
