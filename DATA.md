# DATA.md — how to add and fix links in the Proxy Dictionary catalog

This file is the single guide for editing the catalog. Read it before you
change `data/catalog.js`. Agents: read AGENTS.md first for the repository
map and rules, then come back here for the catalog steps.

## The data file

`data/catalog.js` holds the whole catalog as one JavaScript assignment:

```js
const data = {
  "Project Name": {
    "v1": [
      {"url": "...", "notes": "...", "version": "v1", "dateAdded": "YYYY-MM-DD"},
      ...
    ],
    "Unknown": [
      ...
    ],
  },
  ...
};
```

Load it with a `<script src="data/catalog.js"></script>` tag in `index.html`
— never with `fetch()`, so the site keeps opening from disk (`file://`) on a
USB stick.

Format rules:

- One entry per visible line. One project section per top-level key.
- Keep the file valid JavaScript: `node --check data/catalog.js` must pass.
- Do not reorder, drop, or rename existing entries or projects.
- Entry keys, in order: `url`, `notes`, `version`, `dateAdded`.

## Entry fields and the URL card

Every line on a URL card maps to one field:

| Card line | Field | Example |
|-----------|-------|---------|
| The link itself | `url` | `https://nebulos.app` |
| Small text under the link (IDENT) | `notes` | `Nebulo OS Gateway` |
| Version pill | `version` | `v1` |
| Date added | `dateAdded` | `2026-11-13` |

The render shows `[VER: <version>] [IDENT: <notes>] [ADDED: <dateAdded>]`
under each link. A missing `dateAdded` renders as `[ADDED: unknown]`.

## dateAdded rule

`dateAdded` is `YYYY-MM-DD`, the date the link was added to the catalog.
Backfill it only where the date is known from git history or the README.
Never invent a date.

- The whole catalog was introduced in the single commit on `master`,
  `2026-11-13` (`git log --all --format=%ad --date=short`). Every existing
  entry carries `2026-11-13`; no per-entry dates are known.
- New entries: put today's date (`YYYY-MM-DD`, the day the change lands on
  the branch). If you do not know the date, write `"unknown"` and say so in
  the pull request.

## Validation (runs before every commit)

```bash
node --check data/catalog.js
```

The check must pass. A syntax error in this file kills nothing at runtime
(any one bad entry is skipped by `render()`), but the file must still parse
— `node --check` is the gate, and it is part of every change to the catalog.

## Workflow examples

### Add one link

Find the project section and version block, then paste one entry line:

```js
  "Interstellar": {
    "v2": [
      {"url": "https://new-mirror.example.com", "notes": "My school mirror", "version": "v2", "dateAdded": "2026-11-25"},
      ...
    ],
  },
```

Then run `node --check data/catalog.js`, open `index.html`, click Interstellar,
and confirm the new card shows the link, the note, and `[ADDED: 2026-11-25]`.

### Fix one link's metadata (notes, version, or dateAdded)

Change only the one field on the one line. Example: correcting the notes of
one link, nothing else:

Before:

```js
      {"url": "https://nebulos.app", "notes": "Nebulo OS Gateway", "version": "v1", "dateAdded": "2026-11-13"},
```

After:

```js
      {"url": "https://nebulos.app", "notes": "Nebulo OS main gateway", "version": "v1", "dateAdded": "2026-11-13"},
```

Same shape applies to `version` and `dateAdded`: one field, one line, one
change. The `url` stays identical — never replace a URL, add a new entry line
instead.

### Add a whole project section

Paste a new top-level key, in alphabetical order to keep the file tidy:

```js
  "New Project": {
    "v1": [
      {"url": "https://newproject.example.com/", "notes": "Found via the project site", "version": "v1", "dateAdded": "2026-11-25"},
    ],
  },
```

The sidebar sorts sections alphabetically at render time, so the section
appears in the right place automatically. A project needs a `githubMap`
entry in `index.html` only if you want its "GitHub:" link on the card.

## What must never change

- No invented URLs: only links you have seen.
- No invented dates: use a known date or `"unknown"`.
- No dropped entries: edits must keep every existing `url`, `notes`, and
  `version` intact.
- No entry shape changes: every entry keeps `url`, `notes`, `version`,
  `dateAdded` and nothing else.

## If something breaks

`render()` skips a bad entry, logs it to the browser console, and keeps
rendering the rest — one bad line never empties the sidebar again. If the
sidebar is empty on load, the catalog file did not load: check
`data/catalog.js` with `node --check` and check the console.
