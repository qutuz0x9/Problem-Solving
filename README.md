# Problem-Solving

A personal, multi-language workspace for practicing coding problems — LeetCode,
Codeforces, and custom/company interview questions — with automated scaffolding,
per-language testing and linting, benchmarks, and an auto-generated problem index.

## ✨ Features

- **One command to start a new problem** — `make new` scaffolds a full folder
  (solution, tests, benchmark, README) from a template, per platform and language.
- **Multi-language support** — Go, Python, JavaScript, TypeScript, C++, and Rust,
  one language per problem, chosen at creation time.
- **Smart test/lint dispatch** — `make test` and `make lint` detect the language
  of each problem and run the right tool, skipping gracefully if a toolchain
  isn't installed locally.
- **Benchmarks included** — every problem gets a benchmark file/harness for its
  language.
- **Auto-generated problem index** — `make index` keeps the table below in sync
  with everything under `problems/`.
- **CI-ready** — GitHub Actions runs tests and lint across all toolchains on
  every push/PR.

## 📁 Project structure

```
problems/            # solved problems, organized by platform
  leetcode/<slug>/    # e.g. 0001-two-sum
  codeforces/<slug>/  # e.g. 4a-watermelon
  other/<slug>/       # company/custom questions
patterns/             # cross-reference index of problem-solving techniques
helpers/              # scaffold script, test/lint dispatch, index generator, templates
Makefile              # make new / test / lint / index
```

## 🚀 Quick start

```sh
make new PLATFORM=leetcode LANG=go NUM=1 NAME=two-sum   # scaffold a problem
make test DIR=problems/leetcode/0001-two-sum            # run its tests
make lint DIR=problems/leetcode/0001-two-sum             # lint it
make index                                               # refresh the index below
```

📖 **For the full step-by-step walkthrough** (implementing a solution, writing
real tests, running benchmarks, troubleshooting, etc.), see **[`USAGE.md`](USAGE.md)**.

## 🧩 Supported platforms & languages

| Platforms  | Languages                                              |
|------------|----------------------------------------------------------|
| LeetCode, Codeforces, Other/custom | Go, Python, JavaScript, TypeScript, C++, Rust |

## 📚 Documentation

- [`USAGE.md`](USAGE.md) — complete usage guide, start to finish
- [`problems/README.md`](problems/README.md) — directory layout & naming conventions
- [`patterns/README.md`](patterns/README.md) — pattern/technique cross-reference index

## Problem Index

<!-- PROBLEM_INDEX:START -->
| Platform | Problem | Language |
|---|---|---|
| leetcode | [Two Sum](problems/leetcode/0001-two-sum) | Go |
<!-- PROBLEM_INDEX:END -->
