#!/usr/bin/env python3
"""Fetch a problem's metadata and statement from its URL.

Usage:
    python3 helpers/fetch_problem.py <problem-url>

Prints one JSON object to stdout (see `fetch()` for the keys). On failure it
prints a one-line reason to stderr and exits non-zero, so callers can fall
back to asking the user to paste the statement.

Sources (no third-party dependencies):
  - LeetCode:   the public GraphQL endpoint (unofficial, may change).
  - Codewars:   the official code-challenges API.
  - Codeforces: the official problemset API (metadata only; the statement page
                is behind a bot check, so `statement_missing` is set).
  - Anything else: no fetching, `statement_missing` is set.
"""

import json
import re
import sys
import urllib.error
import urllib.parse
import urllib.request
from html.parser import HTMLParser

TIMEOUT = 30
USER_AGENT = "Mozilla/5.0 (compatible; problem-solving-fetch/1.0)"


class FetchError(Exception):
    pass


def kebab(text):
    return re.sub(r"-+", "-", re.sub(r"[^a-z0-9]", "-", text.lower())).strip("-")


def request(url, data=None, headers=None):
    hdrs = {"User-Agent": USER_AGENT, "Accept": "application/json"}
    hdrs.update(headers or {})
    body = json.dumps(data).encode() if data is not None else None
    req = urllib.request.Request(url, data=body, headers=hdrs)
    try:
        with urllib.request.urlopen(req, timeout=TIMEOUT) as resp:
            return json.load(resp)
    except urllib.error.HTTPError as e:
        raise FetchError(f"{urllib.parse.urlparse(url).netloc} returned HTTP {e.code}") from e
    except (urllib.error.URLError, TimeoutError) as e:
        raise FetchError(f"could not reach {urllib.parse.urlparse(url).netloc}: {e}") from e
    except json.JSONDecodeError as e:
        raise FetchError(f"{urllib.parse.urlparse(url).netloc} did not return JSON") from e


class HtmlToMarkdown(HTMLParser):
    """Converts the small HTML subset LeetCode uses for statements to Markdown."""

    def __init__(self):
        super().__init__(convert_charrefs=True)
        self.out = []
        self.in_pre = False
        self.in_code = False
        self.pre_start = 0

    def handle_starttag(self, tag, attrs):
        if tag == "p":
            self.out.append("\n\n")
        elif tag == "pre":
            self.in_pre = True
            self.pre_start = len(self.out)
            self.out.append("\n\n```txt\n")
        elif tag == "code" and not self.in_pre:
            self.in_code = True
            self.out.append("`")
        elif tag in ("strong", "b") and not self.in_pre:
            self.out.append("**")
        elif tag == "sup":
            self.out.append("^")
        elif tag == "sub":
            self.out.append("_")
        elif tag in ("ul", "ol"):
            self.out.append("\n")
        elif tag == "li":
            self.out.append("\n- ")
        elif tag == "br":
            self.out.append("\n")
        elif tag == "img":
            src = dict(attrs).get("src")
            if src:
                self.out.append(f"\n\n![]({src})\n\n")

    def handle_endtag(self, tag):
        if tag == "p":
            self.out.append("\n\n")
        elif tag == "pre":
            self.in_pre = False
            fence, *body = self.out[self.pre_start :]
            self.out[self.pre_start :] = [fence, "".join(body).strip("\n"), "\n```\n\n"]
        elif tag == "code" and self.in_code:
            self.in_code = False
            self.out.append("`")
        elif tag in ("strong", "b") and not self.in_pre:
            self.out.append("**")
        elif tag in ("ul", "ol"):
            self.out.append("\n")

    def handle_data(self, data):
        self.out.append(data.replace("\xa0", " "))

    def markdown(self):
        text = "".join(self.out)
        # Tidy: trim trailing spaces, drop empty bold/code markers left by &nbsp; paragraphs.
        text = re.sub(r"[ \t]+\n", "\n", text)
        text = re.sub(r"\n{3,}", "\n\n", text)
        # Markdown bold must hug its text: "**Follow-up: **x" -> "**Follow-up:** x".
        text = re.sub(r"\*\*([ \t]*)([^*\n]*?)([ \t]*)\*\*", r"\1**\2**\3", text)
        # Keep list items on consecutive lines.
        while True:
            tight = re.sub(r"(\n- [^\n]*)\n\n(?=- )", r"\1\n", text)
            if tight == text:
                break
            text = tight
        return text.strip()


def html_to_markdown(html_text):
    parser = HtmlToMarkdown()
    parser.feed(html_text)
    parser.close()
    return parser.markdown()


def fetch_leetcode(url, parts):
    try:
        slug = parts[parts.index("problems") + 1]
    except (ValueError, IndexError) as e:
        raise FetchError("not a LeetCode problem URL (expected .../problems/<slug>)") from e

    query = (
        "query q($s: String!) { question(titleSlug: $s) "
        "{ questionFrontendId title titleSlug difficulty topicTags { name } content isPaidOnly } }"
    )
    data = request(
        "https://leetcode.com/graphql",
        data={"query": query, "variables": {"s": slug}},
        headers={
            "Content-Type": "application/json",
            "Referer": f"https://leetcode.com/problems/{slug}/",
        },
    )
    question = (data.get("data") or {}).get("question")
    if not question:
        raise FetchError(f"LeetCode has no problem with slug '{slug}'")

    content = question.get("content")
    return {
        "platform": "leetcode",
        "number": str(question["questionFrontendId"]),
        "slug": question["titleSlug"],
        "title": question["title"],
        "difficulty": question["difficulty"],
        "tags": [t["name"] for t in question["topicTags"]],
        "url": f"https://leetcode.com/problems/{question['titleSlug']}/",
        "statement_markdown": html_to_markdown(content) if content else "",
        "statement_missing": not content,
        "note": "premium problem, statement not available" if not content else "",
    }


def fetch_codewars(url, parts):
    try:
        ident = parts[parts.index("kata") + 1]
    except (ValueError, IndexError) as e:
        raise FetchError("not a Codewars kata URL (expected .../kata/<id-or-slug>)") from e

    data = request(f"https://www.codewars.com/api/v1/code-challenges/{ident}")
    if data.get("success") is False:
        raise FetchError(f"Codewars: {data.get('reason', 'kata not found')}")

    description = data.get("description") or ""
    return {
        "platform": "codewars",
        "number": None,
        "slug": kebab(data["name"]),
        "title": data["name"],
        "difficulty": (data.get("rank") or {}).get("name", ""),
        "tags": data.get("tags", []),
        "url": data.get("url", url),
        "statement_markdown": description.strip(),
        "statement_missing": not description.strip(),
        "note": "",
    }


def fetch_codeforces(url, parts):
    contest = letter = None
    if "problemset" in parts and "problem" in parts:
        rest = parts[parts.index("problem") + 1 :]
        if len(rest) >= 2:
            contest, letter = rest[0], rest[1]
    elif "contest" in parts and "problem" in parts:
        contest = parts[parts.index("contest") + 1]
        rest = parts[parts.index("problem") + 1 :]
        letter = rest[0] if rest else None
    if not (contest and letter and contest.isdigit()):
        raise FetchError(
            "not a Codeforces problem URL (expected .../problemset/problem/<n>/<letter>)"
        )

    data = request("https://codeforces.com/api/problemset.problems")
    if data.get("status") != "OK":
        raise FetchError("Codeforces API returned an error")
    for problem in data["result"]["problems"]:
        if str(problem["contestId"]) == contest and problem["index"].upper() == letter.upper():
            rating = problem.get("rating")
            return {
                "platform": "codeforces",
                "number": f"{contest}{letter.lower()}",
                "slug": kebab(problem["name"]),
                "title": problem["name"],
                "difficulty": f"Rating {rating}" if rating else "",
                "tags": problem.get("tags", []),
                "url": f"https://codeforces.com/problemset/problem/{contest}/{letter.upper()}",
                "statement_markdown": "",
                "statement_missing": True,
                "note": "Codeforces blocks fetching the statement page; paste the statement text",
            }
    raise FetchError(f"Codeforces problem {contest}{letter.upper()} not found")


def fetch_other(url, parts):
    return {
        "platform": "other",
        "number": None,
        "slug": kebab(parts[-1]) if parts else "",
        "title": "",
        "difficulty": "",
        "tags": [],
        "url": url,
        "statement_markdown": "",
        "statement_missing": True,
        "note": "unknown site; paste the statement text",
    }


def fetch(url):
    parsed = urllib.parse.urlparse(url if "://" in url else f"https://{url}")
    host = parsed.netloc.lower().removeprefix("www.")
    parts = [p for p in parsed.path.split("/") if p]

    if host == "leetcode.com":
        result = fetch_leetcode(url, parts)
    elif host == "codewars.com":
        result = fetch_codewars(url, parts)
    elif host == "codeforces.com":
        result = fetch_codeforces(url, parts)
    else:
        result = fetch_other(url, parts)

    # Folder name exactly as helpers/new_problem.sh builds it.
    if result["platform"] == "leetcode":
        result["folder"] = f"{int(result['number']):04d}-{result['slug']}"
    elif result["platform"] == "codeforces":
        result["folder"] = f"{result['number']}-{result['slug']}"
    else:
        result["folder"] = result["slug"]
    return result


def main(argv):
    if len(argv) != 2 or argv[1] in ("-h", "--help"):
        print(__doc__.strip().split("\n\n")[1], file=sys.stderr)
        return 2
    try:
        print(json.dumps(fetch(argv[1]), indent=2, ensure_ascii=False))
    except FetchError as e:
        print(f"error: {e}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
