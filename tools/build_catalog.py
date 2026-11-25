#!/usr/bin/env python3
"""Build data/catalog.js from the inline catalog in index.html.

- Extracts `const data = {...}` from index.html.
- Adds dateAdded (YYYY-MM-DD) to every entry, backfilled from git history:
  the whole catalog was introduced in the single commit on master, 2026-11-13.
  No per-entry dates are known, so every entry carries that one verifiable date.
- Writes data/catalog.js: one entry per visible line, loadable with a <script> tag.
"""
import json
import re
import subprocess
import sys

REPO = "/home/user/proxydictionary"
DATE_ADDED = "2026-11-13"  # verified: git log --all --format=%ad --date=short -> 2026-11-13


def git_date():
    out = subprocess.run(
        ["git", "log", "--all", "--format=%ad", "--date=short"],
        cwd=REPO, capture_output=True, text=True, check=True,
    ).stdout.split()
    dates = sorted(set(out))
    return dates


def extract_data(html):
    m = re.search(r"const data = (.*?);\n\s*const githubMap", html, re.DOTALL)
    if not m:
        sys.exit("could not find const data block")
    return json.loads(m.group(1))  # the literal is JSON-compatible


def fmt(obj, indent=0):
    """Custom formatter: one entry per visible line."""
    sp = " " * indent
    sp1 = " " * (indent + 2)
    sp2 = " " * (indent + 4)
    lines = ["{"]
    items = list(obj.items())
    for i, (key, val) in enumerate(items):
        comma = "," if i < len(items) - 1 else ""
        if isinstance(val, dict):
            lines.append(f'{sp1}{json.dumps(key)}: {fmt(val, indent + 2).rstrip()}{comma}')
        else:  # list of entries
            lines.append(f'{sp1}{json.dumps(key)}: [')
            for j, e in enumerate(val):
                ec = "," if j < len(val) - 1 else ""
                lines.append(f'{sp2}{json.dumps(e, ensure_ascii=False)}{ec}')
            lines.append(f'{sp1}]{comma}')
    lines.append(f'{sp}}}')
    return "\n".join(lines)


def main():
    html = open(f"{REPO}/index.html", encoding="utf-8").read()
    data = extract_data(html)
    dates = git_date()
    print("git commit dates:", dates)

    total = 0
    for project, versions in data.items():
        for ver, entries in versions.items():
            for e in entries:
                e["dateAdded"] = DATE_ADDED
                total += 1
    print("entries:", total)

    out = "const data = " + fmt(data) + ";\n"
    with open(f"{REPO}/data/catalog.js", "w", encoding="utf-8") as f:
        f.write(out)
    print("wrote data/catalog.js")


if __name__ == "__main__":
    main()
