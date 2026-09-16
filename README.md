# Problem-Solving

A personal workspace for practicing coding problems (LeetCode, Codeforces, and
custom/company questions) across multiple languages, with automated scaffolding,
testing, linting, and an auto-generated problem index.

See `problems/README.md` for directory layout/naming conventions and
`patterns/README.md` for a cross-reference index of problem-solving techniques.

📖 **New here? Read [`USAGE.md`](USAGE.md) for the full step-by-step guide** —
from scaffolding a problem to implementing, testing, benchmarking, and linting it.

## Usage

Create a new problem:

```sh
make new PLATFORM=leetcode LANG=go NUM=0001 NAME=two-sum
make new PLATFORM=codeforces LANG=python NUM=4a NAME=watermelon
make new PLATFORM=other LANG=rust NAME=acme-rotate-array
```

Run tests (all problems, or a single one):

```sh
make test
make test DIR=problems/leetcode/0001-two-sum
```

Run linters/formatters (all problems, or a single one):

```sh
make lint
make lint DIR=problems/leetcode/0001-two-sum
```

Regenerate the problem index table below:

```sh
make index
```

Supported languages: Go, Python, JavaScript, TypeScript, C++, Rust. Test/lint
commands skip gracefully (with a message) if the relevant toolchain isn't
installed locally; CI installs all of them.

## Problem Index

<!-- PROBLEM_INDEX:START -->
| Platform | Problem | Language |
|---|---|---|
| leetcode | [Two Sum](problems/leetcode/0001-two-sum) | Go |
<!-- PROBLEM_INDEX:END -->
