# DATA.md — how to add and fix links in the Proxy Dictionary catalog

This file is the single guide for editing the catalog. Read it before you
change any data file. Agents: read AGENTS.md first for the repository map
and rules, then come back here for the catalog steps.

## The data files

**`data/catalog.json` is the source of truth.** Humans and agents edit this
file and nothing else. It is a plain JSON object: project name → version →
array of entries, pretty-printed with 2-space indent so one entry is a few
readable lines:

```json
{
  "Project Name": {
    "v1": [
      {
        "url": "https://new-mirror.example.com",
        "notes": "My school mirror",
        "version": "v1",
        "dateAdded": "2026-07-08"
      }
    ],
    "Unknown": [
      ...
    ]
  },
  ...
}
```

**`data/catalog.js` is generated from the JSON.** The site loads it with a
`<script src="data/catalog.js"></script>` tag — never with `fetch()`, so the
site keeps opening from disk (`file://`) on a USB stick. Never hand-edit
`data/catalog.js`: after any change to the JSON, regenerate it:

```bash
python3 tools/catalog_json_to_js.py
```

Format rules:

- Keep the JSON a single top-level object: `project → version → [entries]`.
- Do not reorder, drop, or rename existing entries or projects.
- Entry keys, in order: `url`, `notes`, `version`, `dateAdded`.

## Entry fields and the URL card

Every line on a URL card maps to one field:

| Card line | Field | Example |
|-----------|-------|---------|
| The link itself | `url` | `https://nebulos.app` |
| Small text under the link (IDENT) | `notes` | `Nebulo OS Gateway` |
| Version pill | `version` | `v1` |
| Date added | `dateAdded` | `2026-07-08` |

The render shows `[VER: <version>] [IDENT: <notes>] [ADDED: <dateAdded>]`
under each link. A missing `dateAdded` renders as `[ADDED: unknown]`.

## dateAdded rule

`dateAdded` is `YYYY-MM-DD`, the date the link was added to the catalog.
Backfill it only where the date is known from git history or the README.
Never invent a date.

- History, for real: the catalog was built by several commits on `master`
  between 2026-07-07 and 2026-07-09 (the initial payload plus the Nebulo OS
  work); the 2026-11-13 merge (PR #1) only rewrote the README. Each URL's
  `dateAdded` is the date of the first commit that introduced that URL in
  the history of `index.html` on `master` (4,137 entries `2026-07-07`,
  `https://nebulos.app` `2026-07-08`). The mapping is produced by
  `tools/backfill_dates.py`, one pass over the history, and spot-checked
  with `git log -S` (see AGENTS.md §2).
- New entries: put today's date (`YYYY-MM-DD`, the day the change lands on
  the branch). If you do not know the date, write `"unknown"` and say so in
  the pull request.

## Validation (runs before every commit)

```bash
python -m json.tool data/catalog.json > /dev/null   # the JSON must parse
python3 tools/catalog_json_to_js.py                 # regenerate catalog.js
node --check data/catalog.js                        # the JS must parse
```

`python3 tools/catalog_json_to_js.py --check` verifies that `data/catalog.js`
already matches the JSON without rewriting it. All checks must pass; they are
part of every change to the catalog.

## Workflow examples

### Add one link

Find the project's version block in `data/catalog.json` and paste one entry
object into the array:

```json
      {
        "url": "https://new-mirror.example.com",
        "notes": "My school mirror",
        "version": "v2",
        "dateAdded": "2026-11-24"
      }
```

Then run the validation commands above, open `index.html`, click the
project, and confirm the new card shows the link, the note, and
`[ADDED: 2026-11-24]`. The link-check workflow (`.github/workflows/links.yml`)
checks every new link when the pull request opens; a dead or error-page link
fails the check and blocks the merge.

### Fix one link's metadata (notes, version, or dateAdded)

Change only the one field on the one entry. Example: correcting the notes of
one link, nothing else. Before:

```json
        "notes": "Nebulo OS Gateway",
```

After:

```json
        "notes": "Nebulo OS main gateway",
```

Same shape applies to `version` and `dateAdded`: one field, one entry, one
change. The `url` stays identical — never replace a URL, add a new entry
instead. Then regenerate `data/catalog.js` and validate.

### Add a whole project section

Paste a new top-level key (any position; the sidebar sorts sections
alphabetically at render time):

```json
  "New Project": {
    "v1": [
      {
        "url": "https://newproject.example.com/",
        "notes": "Found via the project site",
        "version": "v1",
        "dateAdded": "2026-11-24"
      }
    ]
  }
```

A project needs a `githubMap` entry in `index.html` only if you want its
"GitHub:" link on the card.

## What must never change

- No invented URLs: only links you have seen.
- No invented dates: use a known date or `"unknown"`.
- No dropped entries: edits must keep every existing `url`, `notes`, and
  `version` intact.
- No entry shape changes: every entry keeps `url`, `notes`, `version`,
  `dateAdded` and nothing else.
- No hand-edits to `data/catalog.js`: it is generated from the JSON.

## If something breaks

`render()` skips a bad entry, logs it to the browser console, and keeps
rendering the rest — one bad line never empties the sidebar again. If the
sidebar is empty on load, the catalog file did not load: check the JSON with
`python -m json.tool data/catalog.json`, regenerate `data/catalog.js`, and
run `node --check data/catalog.js`.
