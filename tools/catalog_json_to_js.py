#!/usr/bin/env python3
"""Generate data/catalog.js from data/catalog.json.

`data/catalog.json` is the source of truth that humans and agents edit.
`data/catalog.js` is generated from it, one entry per line, and is what the
site loads with a `<script src>` tag (never `fetch()`, so `file://` offline
use keeps working). Never hand-edit `data/catalog.js`: regenerate it.

Usage:
    python3 tools/catalog_json_to_js.py            # rewrite data/catalog.js
    python3 tools/catalog_json_to_js.py --check    # fail if it is out of date

The output format is the historical one: `const data = {...};` with one
entry object per visible line.
"""

import argparse
import json
import sys
from pathlib import Path


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
    lines.append(f"{sp}}}")
    return "\n".join(lines)


def generate(data):
    return "const data = " + fmt(data) + ";\n"


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--repo", default=".", help="repository root")
    ap.add_argument("--check", action="store_true",
                    help="verify data/catalog.js matches the JSON without writing")
    args = ap.parse_args()

    repo = Path(args.repo).resolve()
    json_path = repo / "data" / "catalog.json"
    js_path = repo / "data" / "catalog.js"

    data = json.loads(json_path.read_text(encoding="utf-8"))
    out = generate(data)

    if args.check:
        current = js_path.read_text(encoding="utf-8")
        if current != out:
            sys.exit("data/catalog.js is out of date with data/catalog.json; "
                     "run python3 tools/catalog_json_to_js.py")
        print("data/catalog.js matches data/catalog.json")
        return

    js_path.write_text(out, encoding="utf-8")
    entries = sum(len(v) for p in data.values() for v in p.values())
    print(f"wrote {js_path} ({entries} entries)")


if __name__ == "__main__":
    main()
