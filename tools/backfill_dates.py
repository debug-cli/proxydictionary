#!/usr/bin/env python3
"""Backfill dateAdded from real git history.

The catalog originally claimed every entry was added on 2026-11-13 ("the
single commit on master that introduced the catalog"). That was wrong: the
catalog was built by several commits on master between 2026-07-07 and
2026-07-09, and the 2026-11-13 merge (PR #1) only rewrote the README. A
backfilled date that is not from git history is an invented date, and the
docs forbid invented dates.

This script reads the history of the file that held the catalog on master
(`index.html`) and finds the first commit that introduced each URL.
`dateAdded` becomes that commit's date (YYYY-MM-DD). URLs that git history
does not date get "unknown". No date is ever invented.

Method: one pass over the history. The commits that touched `index.html` are
listed oldest first, each commit's snapshot of the file is parsed once, and
every catalog URL not yet dated is assigned the date of the oldest snapshot
that contains it. There is no per-URL `git log` call.

Usage:
    python3 tools/backfill_dates.py [--repo DIR] [--from-js] [--dry-run]

Writes `data/catalog.json` (pretty, 2-space indent) with the fixed dates and
prints a summary. `--from-js` reads the current catalog from
`data/catalog.js` (first run); otherwise the JSON is read when present.
"""

import argparse
import json
import re
import subprocess
import sys
from pathlib import Path

URL_RE = re.compile(r"""https?://[^\s"'<>\\]+""")
TRAILING_PUNCT = ".,;:!?)]}"
U_ESCAPE_RE = re.compile(r"""\\u([0-9a-fA-F]{4})""")


def decode_u_escapes(text):
    """History stores non-ASCII URL characters JSON-escaped (re\\u00f1aca)."""
    return U_ESCAPE_RE.sub(lambda m: chr(int(m.group(1), 16)), text)


def git(repo, *args):
    out = subprocess.run(
        ["git", *args], cwd=repo, capture_output=True, check=True
    ).stdout
    return out.decode("utf-8", errors="replace")


def load_catalog_js(repo):
    src = (repo / "data" / "catalog.js").read_text(encoding="utf-8")
    body = src[src.index("=") + 1 :].strip()
    if not body.endswith(";"):
        sys.exit("data/catalog.js does not end with ';'")
    return json.loads(body[:-1])


def catalog_urls(data):
    seen = []
    for versions in data.values():
        for entries in versions.values():
            for e in entries:
                if e["url"] not in seen:
                    seen.append(e["url"])
    return seen


def history_pass(repo, wanted):
    """One pass over master's index.html history, oldest commit first.

    Returns {url: "YYYY-MM-DD"} for every wanted URL found in a snapshot.
    """
    log = git(
        repo,
        "log",
        "--reverse",
        "--format=%H %ad",
        "--date=short",
        "master",
        "--",
        "index.html",
    )
    commits = [line.split() for line in log.splitlines() if line.strip()]
    found = {}
    remaining = set(wanted)
    for sha, date in commits:
        if not remaining:
            break
        snapshot = decode_u_escapes(git(repo, "show", f"{sha}:index.html"))
        urls = set()
        for m in URL_RE.findall(snapshot):
            urls.add(m.rstrip(TRAILING_PUNCT))
            urls.add(m)
        for url in list(remaining):
            if url in urls:
                found[url] = date
                remaining.discard(url)
    return found


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--repo", default=".", help="repository root")
    ap.add_argument("--from-js", action="store_true",
                    help="read the catalog from data/catalog.js instead of the JSON")
    ap.add_argument("--dry-run", action="store_true",
                    help="print the summary without writing data/catalog.json")
    args = ap.parse_args()

    repo = Path(args.repo).resolve()
    json_path = repo / "data" / "catalog.json"
    if args.from_js or not json_path.exists():
        data = load_catalog_js(repo)
    else:
        data = json.loads(json_path.read_text(encoding="utf-8"))

    wanted = catalog_urls(data)
    dates = history_pass(repo, wanted)

    unknown = [u for u in wanted if u not in dates]
    for versions in data.values():
        for entries in versions.values():
            for e in entries:
                e["dateAdded"] = dates.get(e["url"], "unknown")

    entries = sum(len(v) for p in data.values() for v in p.values())
    print(f"entries: {entries}")
    print(f"unique URLs: {len(wanted)}")
    dist = {}
    for versions in data.values():
        for entries_ in versions.values():
            for e in entries_:
                dist[e["dateAdded"]] = dist.get(e["dateAdded"], 0) + 1
    for date in sorted(dist):
        print(f"  {date}: {dist[date]}")
    if unknown:
        print(f"unknown URLs ({len(unknown)}):")
        for u in unknown[:20]:
            print(f"  {u}")
        if len(unknown) > 20:
            print(f"  ... and {len(unknown) - 20} more")

    if args.dry_run:
        print("dry run: data/catalog.json not written")
        return

    with open(json_path, "w", encoding="utf-8") as f:
        json.dump(data, f, indent=2, ensure_ascii=False)
        f.write("\n")
    print(f"wrote {json_path}")


if __name__ == "__main__":
    main()
