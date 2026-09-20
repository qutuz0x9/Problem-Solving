---
name: docs-check
description: Check and fix the repo's Markdown files (markdownlint rules, aligned tables, links and anchors) with make docs, then fix what the automatic fixers cannot. Use when the user asks to check, fix or clean up Markdown docs, or after writing or editing several .md files.
argument-hint: [file ...]
disable-model-invocation: true
allowed-tools: Read, Edit, Bash(make docs:*), Bash(git status:*), Bash(git diff:*)
---

# Docs Check Skill

Make the repo's Markdown pass `make docs`: the markdownlint rules in `.markdownlint.jsonc`, aligned tables, and
relative links and anchors. The conventions are in `.claude/rules/markdown.md`.

## Usage

```txt
/docs-check
/docs-check README.md USAGE.md
```

## Behavior

1. **Note what is already modified.** Run `git status --short` so you can tell the user's uncommitted edits from
   your fixes. Files under `patterns/` are often mid-edit: keep the user's text and change only what the linter
   requires.
2. **Run the fixers.** `make docs FIX=1` for every file, or `make docs FIX=1 FILE="<files>"` when the user named
   files (quote several files as one string). This applies the automatic markdownlint fixes and aligns tables.
3. **Read the report** of the check steps that follow (`markdownlint`, `aligned tables`, `links and anchors`).
4. **Fix what is left by hand.** Use this table, then read the file's context before editing:

   | Rule or message                            | Fix                                                                             |
   |--------------------------------------------|---------------------------------------------------------------------------------|
   | `MD036` emphasis used as heading           | Make it a real heading, or end the bold label with a colon (`**Label:**`)       |
   | `MD040` fence without a language           | Add `txt` (output, templates), `sh` (commands), `markdown`, `cpp`, ...          |
   | `MD024` duplicate heading                  | Rename one so each heading is unique                                            |
   | `MD034` bare URL                           | Wrap it in `<...>` or write `[text](url)`                                       |
   | `MD001` heading level jumps                | Use the next level down (`##` then `###`)                                       |
   | `MD031`, `MD032`, `MD022`, `MD058`         | Add the blank line before and after the fence, list, heading or table           |
   | `MD012`, `MD009`, `MD010`, `MD047`         | Remove extra blank lines, trailing spaces and tabs; end with one newline        |
   | `MD060` or "table columns are not aligned" | Run `make docs FIX=1`, or fix a malformed row (uneven cell count)               |
   | broken link or anchor                      | Point it at the real file, or at the heading's GitHub slug (lowercase, hyphens) |

5. **Run `make docs` again** (with the same `FILE`) and repeat step 4 until it passes. Stop after three rounds and
   tell the user what is left instead of guessing.
6. **Report** what the fixers changed and what you fixed by hand, using `git diff --stat`. Never stage or commit;
   suggest `/git-commit`.

## Rules

- Never edit the Problem Index in `README.md` (between the `PROBLEM_INDEX` markers) by hand. Run `make index`.
- Never rewrite or delete the user's prose to satisfy the linter. Fix formatting, not content.
- Do not change `.markdownlint.jsonc` or disable a rule to make a file pass. If a rule seems wrong, ask the user.
- If `make docs` reports `run 'npm install' first`, tell the user to run `npm install`.
