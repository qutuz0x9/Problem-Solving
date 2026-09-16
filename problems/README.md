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
| Codewars    | `problems/codewars/`     | freeform kebab-case (kata name)     | `multiply-numbers`           |
| Other       | `problems/other/`        | freeform kebab-case                 | `acme-rotate-array`           |

Codewars kata don't have a numeric ID, so `NUM` isn't required — note the kata's
kyu rank in the generated problem `README.md`'s **Difficulty** field instead
(e.g. `6 kyu`).

## Creating a new problem

Use the scaffold script via `make`:

```
make new PLATFORM=leetcode LANG=go NUM=0001 NAME=two-sum
make new PLATFORM=codeforces LANG=python NUM=4a NAME=watermelon
make new PLATFORM=codewars LANG=python NAME=multiply-numbers
make new PLATFORM=other LANG=rust NAME=acme-rotate-array
```

See root `README.md` for the full list of `make` targets.
