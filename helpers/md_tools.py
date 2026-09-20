#!/usr/bin/env python3
"""Markdown checks that markdownlint does not cover.

Usage:
    python3 helpers/md_tools.py tables [--fix] [FILE...]   # aligned table columns
    python3 helpers/md_tools.py links [FILE...]            # relative links and #anchors

With no FILE, every Markdown file tracked by git (or not ignored) is checked.
Problems are printed as `file:line: message` and the exit status is 1. `tables --fix`
rewrites misaligned tables in place (padded cells, `|-----|` separators).

Both checks skip fenced code blocks, so examples of Markdown are left alone.
"""

import re
import subprocess
import sys
import unicodedata
from pathlib import Path

FENCE = re.compile(r"^\s{0,3}(`{3,}|~{3,})")
HEADING = re.compile(r"^\s{0,3}(#{1,6})\s+(.*?)\s*#*\s*$")
DELIMITER_CELL = re.compile(r":?-+:?")
TABLE_ROW = re.compile(r"^(\s*)\|")
LINK = re.compile(r"!?\[[^\]]*\]\(([^)\s]+)(?:\s+\"[^\"]*\")?\)")
INLINE_CODE = re.compile(r"(`+)(.+?)\1")


def repo_root():
    out = subprocess.run(
        ["git", "rev-parse", "--show-toplevel"], capture_output=True, text=True, check=False
    )
    return Path(out.stdout.strip()) if out.returncode == 0 else Path.cwd()


def markdown_files(root, args):
    if args:
        return [Path(a) for a in args]
    out = subprocess.run(
        ["git", "ls-files", "-co", "--exclude-standard", "*.md"],
        capture_output=True,
        text=True,
        check=False,
        cwd=root,
    )
    return [root / f for f in out.stdout.split("\n") if f]


def outside_fences(lines):
    """Yield (index, line) for lines that are not inside a fenced code block."""
    fence = None
    for i, line in enumerate(lines):
        m = FENCE.match(line)
        if m:
            marker = m.group(1)
            if fence is None:
                fence = marker[0] * len(marker)
            elif marker[0] == fence[0] and len(marker) >= len(fence):
                fence = None
            continue
        if fence is None:
            yield i, line


# ---------------------------------------------------------------- tables


def split_row(line):
    """Split a table row on unescaped pipes; the outer pipes are dropped."""
    cells, cur, i = [], "", 0
    body = line.strip()
    body = body[1:] if body.startswith("|") else body
    body = body[:-1] if body.endswith("|") and not body.endswith("\\|") else body
    while i < len(body):
        ch = body[i]
        if ch == "\\" and i + 1 < len(body) and body[i + 1] == "|":
            cur += "\\|"
            i += 2
            continue
        if ch == "|":
            cells.append(cur.strip())
            cur = ""
        else:
            cur += ch
        i += 1
    cells.append(cur.strip())
    return cells


def display_width(text):
    width = 0
    for ch in text:
        if unicodedata.combining(ch):
            continue
        width += 2 if unicodedata.east_asian_width(ch) in ("W", "F") else 1
    return width


def pad(text, width):
    return text + " " * (width - display_width(text))


def pipe_positions(line):
    """Display-width columns of the unescaped pipes in a table row."""
    positions, col, prev = [], 0, ""
    for ch in line:
        if ch == "|" and prev != "\\":
            positions.append(col)
        col += display_width(ch)
        prev = ch
    return positions


def is_aligned(block):
    """True when every row has its pipes in the same columns (what markdownlint's MD060 checks)."""
    first = pipe_positions(block[0])
    return all(pipe_positions(line) == first for line in block[1:])


def table_indent(block):
    """The common leading whitespace of the rows, or None if the rows are indented differently."""
    indents = {TABLE_ROW.match(line).group(1) for line in block}
    return indents.pop() if len(indents) == 1 else None


def format_table(block):
    """Return the aligned lines for a table block, or None if it is malformed."""
    rows = [split_row(line) for line in block]
    cols = len(rows[0])
    if any(len(r) != cols for r in rows) or not all(DELIMITER_CELL.fullmatch(c) for c in rows[1]):
        return None
    widths = [max(display_width(r[c]) for k, r in enumerate(rows) if k != 1) for c in range(cols)]
    widths = [max(w, 1) for w in widths]
    out = []
    for k, row in enumerate(rows):
        if k == 1:
            cells = []
            for c in range(cols):
                left = ":" if rows[1][c].startswith(":") else "-"
                right = ":" if rows[1][c].endswith(":") else "-"
                cells.append(left + "-" * widths[c] + right)
            out.append("|" + "|".join(cells) + "|")
        else:
            out.append("| " + " | ".join(pad(row[c], widths[c]) for c in range(cols)) + " |")
    return out


def check_tables(path, fix):
    text = path.read_text(encoding="utf-8")
    lines = text.split("\n")
    problems, i = [], 0
    visible = {n for n, _ in outside_fences(lines)}
    while i < len(lines):
        if i in visible and TABLE_ROW.match(lines[i]):
            start = i
            while i < len(lines) and i in visible and TABLE_ROW.match(lines[i]):
                i += 1
            block = lines[start:i]
            if len(block) < 2:
                continue
            indent = table_indent(block)
            fixed = format_table([line.strip() for line in block]) if indent is not None else None
            if fixed is None:
                problems.append(
                    (
                        start + 1,
                        "table is malformed (uneven columns, no separator row, or mixed indent)",
                    )
                )
            elif not is_aligned(block):
                problems.append((start + 1, "table columns are not aligned"))
                if fix:
                    lines[start:i] = [indent + line for line in fixed]
        else:
            i += 1
    if fix and any("not aligned" in msg for _, msg in problems):
        path.write_text("\n".join(lines), encoding="utf-8")
    return problems


# ----------------------------------------------------------------- links


def slug(heading):
    """GitHub's heading anchor: lowercase, drop punctuation and emoji, spaces to hyphens."""
    text = re.sub(r"<[^>]+>", "", heading)
    text = re.sub(r"!?\[([^\]]*)\]\([^)]*\)", r"\1", text)
    text = re.sub(r"[`*~]", "", text).strip().lower()
    text = re.sub(r"[^\w\- ]", "", text)
    return text.replace(" ", "-")


_anchor_cache = {}


def anchors(path):
    if path not in _anchor_cache:
        seen, found = {}, set()
        for _, line in outside_fences(path.read_text(encoding="utf-8").split("\n")):
            m = HEADING.match(line)
            if m:
                base = slug(m.group(2))
                n = seen.get(base, 0)
                seen[base] = n + 1
                found.add(base if n == 0 else f"{base}-{n}")
        _anchor_cache[path] = found
    return _anchor_cache[path]


def check_links(path):
    problems = []
    lines = path.read_text(encoding="utf-8").split("\n")
    for i, line in outside_fences(lines):
        scrubbed = INLINE_CODE.sub(lambda m: " " * len(m.group(0)), line)
        for target in LINK.findall(scrubbed):
            if re.match(r"^[a-zA-Z][a-zA-Z0-9+.-]*:", target):  # http:, https:, mailto:, ...
                continue
            file_part, _, frag = target.partition("#")
            dest = (path.parent / file_part).resolve() if file_part else path.resolve()
            if not dest.exists():
                problems.append((i + 1, f"broken link: {target}"))
            elif frag and dest.suffix == ".md" and frag not in anchors(dest):
                problems.append((i + 1, f"broken anchor: {target}"))
    return problems


# ------------------------------------------------------------------ main


def main(argv):
    if len(argv) < 2 or argv[1] not in ("tables", "links") or "-h" in argv or "--help" in argv:
        print(__doc__.strip(), file=sys.stderr)
        return 2
    mode, rest = argv[1], argv[2:]
    fix = "--fix" in rest
    root = repo_root()
    files = markdown_files(root, [a for a in rest if a != "--fix"])
    total = 0
    for path in files:
        problems = check_tables(path, fix) if mode == "tables" else check_links(path)
        try:
            shown = path.resolve().relative_to(root)
        except ValueError:
            shown = path
        for line_no, message in problems:
            fixed = fix and mode == "tables" and "not aligned" in message
            print(f"{shown}:{line_no}: {message}{' (fixed)' if fixed else ''}")
            total += 0 if fixed else 1
    return 1 if total else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
