#!/usr/bin/env python3
"""Content-check catalog links.

A 200 alone does not prove a page loaded: error pages, parked domains, and
Cloudflare challenge pages can all return 200. For each URL this script
requires:

1. final HTTP status 200,
2. a body longer than 1,000 bytes,
3. no error-page markers in the <title> or the body (words like "404",
   "not found", "access denied", "attention required", Cloudflare challenge
   pages, and parked-domain notices).

Usage:
    python3 tools/check_links.py URL...                 # check given URLs
    python3 tools/check_links.py --file urls.txt        # one URL per line
    python3 tools/check_links.py --catalog data/catalog.json   # every URL
    python3 tools/check_links.py --failures-only ...   # only failing rows

Prints a markdown table (URL, result, reason) for the PR comment or the
workflow run summary. Exit code 0 = all pass, 1 = at least one failure,
2 = usage error.
"""

import argparse
import json
import re
import sys
import time
import urllib.error
import urllib.request
from concurrent.futures import ThreadPoolExecutor
from pathlib import Path

USER_AGENT = (
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 "
    "(KHTML, like Gecko) Chrome/124.0 Safari/537.36 proxydict-linkcheck/1.0"
)
MIN_BODY_BYTES = 1_000
MAX_BODY_BYTES = 5_000_000
TITLE_RE = re.compile(r"<title[^>]*>(.*?)</title>", re.IGNORECASE | re.DOTALL)

# Error-page markers, case-insensitive.
# Title markers: anything here in <title> fails the link.
TITLE_MARKERS = [
    "404",
    "not found",
    "access denied",
    "attention required",
    "cloudflare",
    "just a moment",
    "domain is for sale",
    "parked",
]
# Body markers: distinctive error-page phrases. Bare "404" and bare
# "cloudflare" are NOT body markers: healthy pages contain "404" inside
# decimal numbers (SVG path data like "1.404-2.336") and may mention
# Cloudflare legitimately. "404" in the body is matched as a standalone
# token only (see TOKEN_404), Cloudflare via its challenge phrases.
BODY_MARKERS = [
    "not found",
    "access denied",
    "attention required",
    "just a moment",
    "checking your browser",
    "challenge-platform",
    "cdn-cgi/challenge",
    "cf-browser-verification",
    "this domain is for sale",
    "domain is for sale",
    "domain may be for sale",
    "parked domain",
    "domain is parked",
    "buy this domain",
]
TOKEN_404 = re.compile(r"(?<![\d.])404(?!\d)")

# Transient fetch failures (connection reset, disconnect, timeout, DNS)
# are retried: hosts sometimes drop a single request from a GitHub runner
# even when the link is alive. A real HTTP status or a content verdict is
# never retried — those are definitive answers, not noise.
MAX_ATTEMPTS = 3
RETRY_DELAY_SECONDS = 2


def fetch_url(url, timeout=30):
    """Fetch once. Returns (status, body) or raises on a transport failure."""
    req = urllib.request.Request(url, headers={"User-Agent": USER_AGENT})
    with urllib.request.urlopen(req, timeout=timeout) as resp:
        return resp.status, resp.read(MAX_BODY_BYTES)


def check_url(url, timeout=30):
    """Return (ok, reason). Fetches the URL and applies the three rules."""
    body = None
    status = None
    attempts = 0
    last_error = None
    while attempts < MAX_ATTEMPTS:
        attempts += 1
        try:
            status, body = fetch_url(url, timeout)
            last_error = None
            break
        except urllib.error.HTTPError as e:
            return False, f"HTTP {e.code}"
        except Exception as e:  # connection, SSL, timeout, DNS
            last_error = e
            if attempts < MAX_ATTEMPTS:
                time.sleep(RETRY_DELAY_SECONDS * attempts)
    if last_error is not None:
        return False, (
            f"fetch error after {attempts} attempts: "
            f"{last_error.__class__.__name__}: {last_error}"
        )
    retried = f" (after {attempts} attempts)" if attempts > 1 else ""

    if status != 200:
        return False, f"HTTP {status}"
    if len(body) <= MIN_BODY_BYTES:
        return False, f"body too small ({len(body)} bytes, need > {MIN_BODY_BYTES})"

    text = body.decode("utf-8", errors="replace")
    m = TITLE_RE.search(text)
    title = m.group(1) if m else ""
    low_title = title.lower()
    for marker in TITLE_MARKERS:
        if marker in low_title:
            return False, f"error-page marker in title: {marker!r}"
    if TOKEN_404.search(title):
        return False, "error-page marker in title: '404'"
    low_body = text.lower()
    for marker in BODY_MARKERS:
        if marker in low_body:
            return False, f"error-page marker in body: {marker!r}"
    if TOKEN_404.search(text):
        return False, "error-page marker in body: standalone '404'"
    return True, f"HTTP 200, {len(body)} bytes, no error markers{retried}"


def load_catalog_urls(path):
    data = json.loads(Path(path).read_text(encoding="utf-8"))
    urls = []
    for versions in data.values():
        for entries in versions.values():
            for e in entries:
                if e["url"] not in urls:
                    urls.append(e["url"])
    return urls


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("urls", nargs="*", help="URLs to check")
    ap.add_argument("--file", help="file with one URL per line")
    ap.add_argument("--catalog", help="check every URL in a catalog JSON file")
    ap.add_argument("--timeout", type=int, default=30)
    ap.add_argument("--workers", type=int, default=16)
    ap.add_argument("--failures-only", action="store_true",
                    help="print only failing rows (for the weekly run summary)")
    args = ap.parse_args()

    urls = list(args.urls)
    if args.file:
        urls += [
            line.strip()
            for line in Path(args.file).read_text(encoding="utf-8").splitlines()
            if line.strip() and not line.strip().startswith("#")
        ]
    if args.catalog:
        urls += load_catalog_urls(args.catalog)
    # dedupe, keep order
    seen = set()
    urls = [u for u in urls if not (u in seen or seen.add(u))]
    if not urls:
        sys.exit("no URLs to check (usage error)")

    print(f"Checking {len(urls)} URL(s) with {args.workers} workers...\n")
    with ThreadPoolExecutor(max_workers=args.workers) as pool:
        results = list(pool.map(lambda u: (u, check_url(u, args.timeout)), urls))

    failures = 0
    all_rows = []
    fail_rows = []
    for url, (ok, reason) in results:
        verdict = "pass" if ok else "fail"
        row = f"| {url} | {verdict} | {reason} |"
        all_rows.append(row)
        if not ok:
            failures += 1
            fail_rows.append(row)
    out_rows = fail_rows if args.failures_only else all_rows
    if out_rows:
        print("| URL | Result | Reason |")
        print("| --- | --- | --- |")
        for row in out_rows:
            print(row)
    print(f"\n{len(results) - failures} passed, {failures} failed")
    sys.exit(1 if failures else 0)


if __name__ == "__main__":
    main()
