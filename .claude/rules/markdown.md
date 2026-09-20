---
paths:
  - "**/*.md"
---

# Markdown Conventions

Rules for every Markdown file in this repo. They are enforced by `make docs` (rules in `.markdownlint.jsonc`, which the
editor's markdownlint extension reads too) and by a hook that lints each `.md` file you edit. Write files that pass the
first time. To check one: `make docs FILE=<path>`. To apply the automatic fixes: `make docs FIX=1 FILE=<path>`.

## Headings

- One level-1 heading (`#`) per file, as its title on the first line (after any front matter). Do not skip levels
  (`##` then `####`).
- Never use bold or italic text alone on a line as a heading (`MD036`). Use a real heading. If it must stay a label,
  end it with a colon: `**Try saying:**`.
- Do not repeat the same heading text in a file (`MD024`); make each one specific.
- A blank line before and after every heading.

## Code blocks

- Every fenced block has a language (`MD040`): `sh` for commands, `txt` for output, templates and plain text,
  `markdown`, `cpp`, `go`, and so on. Never a bare fence.
- A blank line before and after every fenced block. Inside a list item, indent the fence to the item's text.

## Tables

- Padded, aligned columns (`MD060`): one space around each cell, a separator row like `|-----|-----|` as wide as its
  column, and every pipe in the same column. A blank line before and after the table.
- Escape a pipe inside a cell as `\|`. Never let a row have more or fewer cells than the header.
- Do not align long tables by hand: `make docs FIX=1 FILE=<path>` (or `python3 helpers/md_tools.py tables --fix <path>`)
  does it.

## Lists, links and text

- A blank line before and after every list (`MD032`). Use `-` for bullets and `1.` `2.` `3.` for ordered lists.
- No bare URLs (`MD034`): write `<https://example.com>` or `[text](https://example.com)`.
- Relative links must point to a file or folder that exists, and `#anchors` must match a heading (GitHub's slug:
  lowercase, punctuation and emoji removed, spaces become hyphens). `make docs` checks both.
- No trailing spaces, no tabs, no two blank lines in a row, and one newline at the end of the file.
- Line length is not enforced. Keep prose readable (about 120 columns) and never wrap a table row.

## Generated and templated files

- The Problem Index in `README.md`, between `<!-- PROBLEM_INDEX:START -->` and `<!-- PROBLEM_INDEX:END -->`, is written
  by `make index`. Never edit it by hand.
- Problem READMEs follow `helpers/templates/README.md`. Write the link as `- **Link:** <https://...>`, or `TODO`.
- Examples of Markdown inside a fenced block are not linted, so keep them valid anyway.

## Before you say you are done

Run `make docs FILE=<the files you changed>` and fix everything it reports. If the change touched a file in `patterns/`
that has uncommitted edits by the user, keep their text and change only what the linter requires.
