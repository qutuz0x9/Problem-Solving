---
name: problem-readme
description: Create a problem folder and fill its README from a problem URL (LeetCode, Codewars, Codeforces or any pasted statement). Use when the user pastes a problem link, or asks to scaffold a problem and write its README for them.
argument-hint: <problem-url> [language]
allowed-tools: Read, Edit, AskUserQuestion, Bash(python3 helpers/fetch_problem.py:*), Bash(make new:*), Bash(make index:*), Bash(ls:*), Bash(git status:*)
---

# Problem README Skill

Turn a problem URL into a scaffolded problem folder with a filled-in `README.md`, so the user does not have to write
the statement, difficulty, tags and link by hand.

## Usage

```txt
/problem-readme https://leetcode.com/problems/contains-duplicate-ii/
/problem-readme https://leetcode.com/problems/contains-duplicate-ii/ cpp
```

## Behavior

1. **Fetch the data**
   - Run `python3 helpers/fetch_problem.py "<url>"`. It prints JSON with `platform`, `number`, `slug`, `title`,
     `difficulty`, `tags`, `url`, `folder`, `statement_markdown`, `statement_missing` and `note`.
   - Sources: LeetCode (public GraphQL, unofficial), Codewars (official API), Codeforces (metadata only).
   - If it exits non-zero, show its one-line error and ask the user to paste the statement instead (and the
     difficulty and tags if they are unknown). Do not guess the statement from memory.
   - If `statement_missing` is true (Codeforces, premium LeetCode, unknown site), keep the metadata from the JSON
     and ask the user to paste the statement text. Use exactly what they paste.
2. **Pick the language**
   - Use the language given as the second argument. Otherwise ask with `AskUserQuestion`, offering `cpp`,
     `python`, `go` and `typescript` (the "Other" answer covers `javascript` and `rust`).
3. **Scaffold, or reuse the folder**
   - The folder is `problems/<platform>/<folder>` (the `folder` value from the JSON). Check with `ls`.
   - If it does not exist, run:
     `make new PLATFORM=<platform> LANG=<lang> NUM=<number> NAME=<slug> URL=<url> TITLE=<title>`
     (leave `NUM` out for `codewars` and `other`). Always pass the real `TITLE`, because the default derived from the
     slug gets things like "II" wrong.
   - If it already exists, do not scaffold. Read its `README.md`, keep anything the user already wrote under
     **Approach** and **Complexity**, and only fill the rest.
4. **Fill the README** following `helpers/templates/README.md`:

   ```markdown
   # <Title>

   - **Platform:** <platform>
   - **Language:** <language>
   - **Link:** <url>
   - **Difficulty:** <Easy | Medium | Hard | "8 kyu" | "Rating 800">
   - **Tags:** <comma-separated tags>

   ## Problem

   <short paraphrase of the statement, in your own words>

   ### Examples

   <every example, copied verbatim as in the source>

   ### Constraints

   <constraints, copied verbatim>

   ## Approach

   TODO: describe your approach, complexity, and any gotchas.

   ## Complexity

   - Time: TODO
   - Space: TODO
   ```

   - The first line is the clean title. It becomes the row title in the root README index.
   - **Paraphrase the statement, copy examples and constraints verbatim.** Problem text is copyrighted and this repo
     is pushed to GitHub, so do not paste the whole statement.
   - Keep code fences around example input and output, **always with a language** (` ```txt `). Keep constraints as a
     list with backticks. Wrap the link in angle brackets (`<https://...>`); a bare URL fails the linter.
   - Leave **Approach** and **Complexity** as `TODO`: nothing is solved yet. The `problem-documenter` agent fills
     them once the solution exists.
   - For an existing folder, replace the header block and the **Problem** section, and leave the rest alone.
5. **Refresh the index**: run `make index`, then check the README with `make docs FILE=<path to the README>` and fix
   anything it reports (see `.claude/rules/markdown.md`).
6. **Report** the folder, the language, what was filled in, and anything you could not get (missing statement,
   unknown difficulty). Remind the user to implement `solution.<ext>`, then use `test-writer` and
   `problem-documenter`, and commit with `/git-commit`.

## Rules

- Never stage or commit anything.
- Never invent a statement, example, constraint, difficulty or tag. If the data is missing, ask.
- Never overwrite a solution, a test, or a hand-written Approach or Complexity section.
- Do not touch `patterns/`.
- The LeetCode endpoint is unofficial and may change or rate-limit. If it fails, fall back to asking for the
  pasted statement instead of retrying in a loop.
