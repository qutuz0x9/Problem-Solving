# Problems

Problems are organized by platform. Each problem lives in its own folder:

```
problems/<platform>/<slug>/
  solution.<ext>
  solution_test.<ext>   (or test_solution.<ext> / solution.test.<ext>)
  benchmark.<ext>
  README.md
```

## Platforms & naming conventions

| Platform    | Folder                  | Slug format                        | Example                     |
|-------------|--------------------------|-------------------------------------|------------------------------|
| LeetCode    | `problems/leetcode/`     | `NNNN-kebab-case-title`             | `0001-two-sum`               |
| Codeforces  | `problems/codeforces/`   | `<contest><problem-letter>-kebab-case-title` | `4a-watermelon`     |
| Other       | `problems/other/`        | freeform kebab-case                 | `acme-rotate-array`           |

## Creating a new problem

Use the scaffold script via `make`:

```
make new PLATFORM=leetcode LANG=go NUM=0001 NAME=two-sum
make new PLATFORM=codeforces LANG=python NUM=4a NAME=watermelon
make new PLATFORM=other LANG=rust NAME=acme-rotate-array
```

See root `README.md` for the full list of `make` targets.
