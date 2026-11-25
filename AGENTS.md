# Proxy Dictionary — engineering handbook

This is the deep reference for anyone changing this repository: maintainers,
contributors, and AI coding agents. It assumes you can read HTML, JavaScript,
and the command line. If you are looking for "what is this site and why
should I use it", that lives in [`README.md`](README.md).

Nothing here is aspirational. Every claim was checked against the files in
this tree or against `git log`, and the counts are reproducible with the
commands in [Verifying this document](#verifying-this-document). Dates are
`YYYY-MM-DD`.

---

## Hard rules that no section overrides

1. No build step, no package manifest, no bundler, no framework, no npm.
   Every tracked file is served as-is.
2. The site opens from a USB stick: open `index.html` directly from disk
   (`file://`), no server, no internet needed once you have the file.
3. The catalog lives in `data/catalog.js`, loaded by a `<script src>` tag —
   never by `fetch()`. Validate every change with `node --check data/catalog.js`.
4. `render()` must skip a bad entry, log it to the console, and keep rendering.
   One bad entry must never empty the sidebar again.
5. After any change to the site, update `AGENTS.md`, the Changelog section of
   `README.md`, and `CHANGELOG.md` in the same change. Keeping them in sync is
   part of every change, not a separate chore.

---

## 0. How to use this document

| If you are… | Read |
|---|---|
| Opening the repo for the first time | §1 mental model, §2 map |
| Editing the catalog | §3, §4, §5, §6, then DATA.md |
| Changing the UI | §8 (offline constraint), §9 (Astryx), §11 (sidebar and render) |
| Touching the splash | §10 |
| Chasing the empty-sidebar bug | §12 |
| Reviewing a PR | §15 review checklist, §13 verification |

---

## 1. Mental model

Proxy Dictionary is a static index of public web proxy mirrors, grouped by
project. The browser tab is the entire runtime: there is no server component,
no backend, and no database. The host serves bytes; the browser runs everything.

```
┌──────────────────────────── browser tab ─────────────────────────────┐
│                                                                      │
│  index.html  ── shell, sidebar, search, theme toggle, splash        │
│  │  data/catalog.js  ── the catalog: project → version → entries   │
│  │  inline script  ── render(), filterCategories(), copy(), etc.   │
│  └───────────────┬────────────────────────────────────────────────┘   │
│                  │ renders URL cards into #category-container        │
│                  ▼                                                    │
│  assets/astryx/  ── vendored Astryx CSS (reset, base, neutral theme)│
│  assets/splashes/  ── splashes.txt, fetched over HTTP                │
└──────────────────────────────────────────────────────────────────────┘
```

Consequences:

- **Everything is inline or same-origin.** `index.html` plus its local
  `assets/` folder is the whole product. Copy the folder, put it on a USB
  stick, open `index.html` — it works.
- **Links are collected, not tested.** Mirrors go down and get blocked often.
  The site lists them; it does not vouch for them.
- **One bad line must never kill the page.** The old inline catalog had a
  stray comma that killed the whole script (§12). The defensive render rule
  (§7) exists so that cannot happen again.

---

## 2. Repository map

Tracked tree (2026-11-25, this branch). Counts verified with `wc` and `git`.

```
.
├── index.html                 292 lines  the site: markup + inline script
├── proxydictionary.html       older copy of the site; use index.html
├── data/catalog.js            4,268 lines  the catalog, const data = {...}
├── DATA.md                    143 lines  the catalog editing guide
├── AGENTS.md                    this file  engineering handbook
├── CHANGELOG.md                  one entry per version
├── README.md                     user guide + Changelog section
├── install.bat                 Windows offline-copy installer
├── vercel.json                 static hosting config (Vercel)
├── LICENSE                     MIT
├── assets/astryx/              vendored Astryx CSS, v0.7.17, MIT
│   ├── reset.css               11,928 bytes
│   ├── astryx.css              314,582 bytes
│   ├── theme-neutral.css       30,284 bytes
│   └── fonts.css               3,751 bytes  (Figtree woff2s deliberately omitted)
├── assets/splashes/
│   └── splashes.txt            53 lines, 48 phrases
├── icons/                      UI icons
└── tools/                      one-off build scripts (not part of the site)
```

- Catalog: 31 projects, 33 version blocks, 4,138 entries, 4,126 unique URLs.
  Interstellar mirrors make up 4,014 of the entries.
- All entry dates come from git history: the single commit on `master`
  (`2026-11-13`) introduced the catalog, so every entry carries
  `dateAdded: "2026-11-13"`. No per-entry dates are known.
- `tools/` holds the one-off scripts that generated `data/catalog.js`; they are
  not loaded by the site and may change freely.

---

## 3. How data is found and added

The catalog is `data/catalog.js`, one assignment:

```js
const data = {
  "Project": {
    "v1": [
      {"url": "...", "notes": "...", "version": "v1", "dateAdded": "2026-11-13"},
    ],
    "Unknown": [
      ...
    ],
  },
};
```

Shape: `project → version → [ {url, notes, version, dateAdded} ]`. Entries are
flat: one entry per visible line, so a bad line is easy to spot.

How links get in:

1. A human or agent finds a mirror URL and notes where it was seen.
2. Add one entry line to the right project and version block (§6).
3. Run `node --check data/catalog.js`. It must pass.
4. Open `index.html`, click the project, confirm the card shows the link,
   the note, and `[ADDED: <date>]`.
5. Send a pull request. The branch stays a draft; no merge to `master` without
   explicit user approval.

Where links come from: public mirror lists, project Discords, READMEs, and
user reports. Never invent a URL and never invent a date.

---

## 4. Data format and metadata rules

- `url` (string): the mirror address. Only links you have seen.
- `notes` (string): shown on the card as IDENT. Short, plain text.
- `version` (string): the project's own version when known, otherwise
  `"Unknown"`.
- `dateAdded` (string, `YYYY-MM-DD`): the date the entry was added. Backfill
  only from git history or the README; otherwise `"unknown"`. Never invent.

What must never change in an edit: no invented URLs, no invented dates, no
dropped entries, no extra or missing entry keys. See DATA.md for the
copy-paste examples (add one link, fix one link's metadata, add a project
section).

---

## 5. URL card field map

Each rendered card shows:

| Card line | Source field | Example |
|---|---|---|
| The link | `url` | `https://nebulos.app` |
| Small text under the link | `notes` → `[IDENT: ...]` | `[IDENT: Nebulo OS Gateway]` |
| Version | `version` → `[VER: ...]` | `[VER: v1]` |
| Date added | `dateAdded` → `[ADDED: ...]` | `[ADDED: 2026-11-13]` or `[ADDED: unknown]` |

The URL also gets a COPY button that writes it to the clipboard. Above the
cards, the section header shows the project name and its GitHub link from
`githubMap` in `index.html`.

---

## 6. Link-adding workflow and the validation command

Human workflow (under a minute):

1. Open `data/catalog.js`. Find the project section and version block.
2. Paste one entry line: `{"url": "...", "notes": "...", "version": "...", "dateAdded": "YYYY-MM-DD"},`
3. Validate: `node --check data/catalog.js`
4. Open `index.html` from disk or the local server; click the project; confirm
   the card.
5. Commit with the data change, the AGENTS.md update, and both changelog
   updates in one change.

The validation command is the gate:

```bash
node --check data/catalog.js
```

It parses the file as JavaScript. Any syntax error fails the command and the
change does not ship. This is documented in DATA.md and here so agents and
humans run the same check.

---

## 7. Defensive render rule

`render()` in `index.html` processes the catalog project by project:

- If `data` did not load, it logs an error and returns; the sidebar stays
  empty but the page stays alive.
- A bad project section, a bad version block, or a bad entry is skipped with
  `console.error("[proxydict] ...")` and the rest keeps rendering.
- An entry missing `url` or `notes` is skipped and logged.
- A missing `dateAdded` renders as `[ADDED: unknown]`.

One bad entry must never empty the sidebar again. This is the direct fix for
the left-bar bug (§12).

Test: copy `data/catalog.js` to a scratch file, break one entry (for example
remove `"url"` from one line), point `index.html` at the scratch copy, and
confirm the sidebar still lists the other projects and the console logs the
skipped entry. Delete the scratch copy afterward.

---

## 8. Offline single-file constraint

The site must keep working by opening `index.html` directly from disk
(`file://`):

- The catalog is loaded with `<script src="data/catalog.js">`, not `fetch()`
  — `fetch()` is blocked for `file://` in browsers.
- The splash list is loaded with `fetch("assets/splashes/splashes.txt")` only
  when `location.protocol` is `http:` or `https:`; on `file://` the fetch is
  skipped and an inline fallback list of 10 phrases in `index.html` is used.
- The Astryx stylesheets are `<link rel="stylesheet">` tags to local files,
  which load from disk fine.
- No npm, no bundler, no network calls except the optional splash fetch.

The fonts.css we vendor references `./fonts/*.woff2` files that we do not
copy (task rule: no woff2 files). Those requests 404 when served over HTTP;
the font-face rules fall back to the system sans stack. This is deliberate:
fonts are cosmetic, the text stays readable.

---

## 9. Astryx migration (neutral theme)

The UI was migrated to the Astryx design language, neutral theme, translated
to plain CSS. No React: Astryx components need React, and this site stays
vanilla JS with no build step.

Files vendored from npm (`@astryxdesign/core@0.7.17` and
`@astryxdesign/theme-neutral@0.7.17`, MIT), CSS and text files only:

| File | Source | Bytes |
|---|---|---|
| `assets/astryx/reset.css` | `@astryxdesign/core/src/reset.css` | 11,928 |
| `assets/astryx/astryx.css` | `@astryxdesign/core/dist/astryx.css` | 314,582 |
| `assets/astryx/theme-neutral.css` | `@astryxdesign/theme-neutral/dist/theme.css` | 30,284 |
| `assets/astryx/fonts.css` | `@astryxdesign/theme-neutral/fonts.css` | 3,751 |

No woff2 font files were copied; no `tokens.json` exists in the packages to
copy. No code from the packages runs in the page.

Link order in `index.html`, before the site's own `<style>`:

```html
<link rel="stylesheet" href="assets/astryx/reset.css">
<link rel="stylesheet" href="assets/astryx/astryx.css">
<link rel="stylesheet" href="assets/astryx/theme-neutral.css">
<link rel="stylesheet" href="assets/astryx/fonts.css">
```

`<html lang="en" data-theme="dark" data-astryx-theme="neutral">` — the neutral
theme scope activates Astryx tokens.

Token mapping:

- The hand-written `:root` / `[data-theme="light"]` blocks were replaced with
  one `:root` block using `light-dark(dark, light)` for every color:
  `--bg`, `--sidebar-bg`, `--sidebar-border`, `--text`, `--text-muted`,
  `--link`, `--entry-bg`, `--entry-border`, `--code-bg`, `--btn-bg`,
  `--btn-border`, `--active-bg`, `--splash`.
- `border-radius: var(--radius-element, 8px)` on `.entry`.
- `transition: var(--duration-medium, 0.2s)` on `body` and `.url-link`;
  `transition: var(--duration-fast, 0.1s)` on `.sidebar-item`.
- Fallbacks (the `, 8px` part) keep the old values if a token is undefined.

What was kept: sidebar layout and width, the search box, the copy buttons,
the theme toggle, the collapsed sidebar, the welcome screen, the splash
animation, the `data-theme` dark/light toggle, the offline behavior, mobile
readability (320 px sidebar stack, wrapping URL cards).

The theme toggle now also sets `html.style.colorScheme` so `light-dark()`
switches with the saved theme (dark by default, `localStorage` key `theme`).

---

## 10. Splash system

The `#splash` element shows one short phrase per load, picked at random.

Canonical list: `assets/splashes/splashes.txt`, 48 phrases, one per line,
plain text. Up to a few promo lines may use the Markdown-link form
`[text](https://...)`; they render as literal text because the splash is set
with `textContent`, never `innerHTML` — a phrase cannot inject markup.

Loading:

- Over HTTP: `loadSplashes()` fetches `assets/splashes/splashes.txt`, trims
  and filters lines (non-blank, non-comment), and shows a random one. On
  failure it falls back to the inline list and logs to the console.
- From disk (`file://`): the fetch is skipped; the inline fallback list of
  10 phrases in `index.html` is used. The splash always shows.

Do not copy graip's phrases; the proxydict list is written fresh. Phrases are
short, casual, one-liners, some personal, some about the site.

---

## 11. Sidebar and render flow

`render()` runs at startup:

1. Reads `data` (loaded from `data/catalog.js` before the inline script).
2. Sorts project names alphabetically; renders one `.sidebar-item` per
   project into `#sidebar-list`, and one `.category-section` per project into
   `#category-container`.
3. Within a project, version blocks sort with `"Unknown"` last; each entry
   becomes a card: URL link, COPY button, and the meta-line
   `[VER: …] [IDENT: …] [ADDED: …]`.
4. Clicking a sidebar item calls `showCategory(cat, el)`, which hides
   `#welcome`, activates the matching section and sidebar item.

`filterCategories()` filters sidebar items by typed text (case-insensitive
substring match on `innerText`).

---

## 12. The left-bar bug and its fix

**Symptom (verified on the live site, 2026-11-24):** the sidebar was empty on
load and after reload, no project was clickable, the search box changed
nothing, and the splash showed the literal placeholder text "Splash!".

**Root cause:** one stray comma in the inline data literal of `index.html`.
Between the Lunar section close and the Rosin section open the single
554,594-character data line read:

```
...}]}, , "Rosin": {...}
```

`node --check` on the extracted script failed with
`SyntaxError: Unexpected token ','`. The whole inline script died, so
`render()` never ran and the splash code never ran either.

**Fix:** delete the stray comma (`]}, , "Rosin":` → `]}, "Rosin":`). After
the fix `node --check` passes, the sidebar lists all 31 projects on load,
clicking a project shows its links, and the search box filters.

**Prevention:** the catalog moved out of `index.html` into `data/catalog.js`
(§6), the render is defensive (§7), and every change runs `node --check`
before it ships. One bad entry can never kill the whole page again.

---

## 13. Testing and verification

Run these on every change:

```bash
node --check data/catalog.js        # the catalog must parse
git diff --check                    # no whitespace errors
node --check <extracted script>     # any extracted or added JavaScript
```

Manual checks (Chrome, Edge, or Helium; the preview URL counts):

1. Open the preview: the sidebar lists all 31 projects on load.
2. Click a project: its links show.
3. Type in the search box: the sidebar filters.
4. A splash phrase shows and changes on reload.
5. Theme toggle works in light and dark mode; `light-dark()` colors follow.
6. Copy buttons write the URL to the clipboard and show the toast.
7. Mobile width: sidebar and cards remain readable.
8. Open `index.html` from disk with no server: all data shows, splash shows
   (fallback list), no console errors from missing fetch.
9. Break one entry in a scratch copy of `data/catalog.js`: the sidebar still
   renders the other projects and the console logs the skip.

Report each `node --check` and `git diff --check` result in the change note.

---

## 14. Traps

- **Do not put the catalog back in `index.html`.** A 554 KB single line with
  one stray comma is exactly how the left-bar bug happened.
- **Do not `fetch()` the catalog.** `file://` blocks it; the site would open
  empty from disk.
- **Do not use `innerHTML` for the splash.** A phrase with markup would
  execute it. Use `textContent`.
- **Do not copy the Figtree woff2 files.** `fonts.css` asks for them and they
  are not vendored; 404s are expected and harmless (system sans fallback).
- **Do not drop `data-astryx-theme="neutral"` from `<html>`.** Without it the
  Astryx token scope is inactive and the theme CSS does not apply.
- **Do not edit `proxydictionary.html`.** It is the older copy; leave it unless
  it conflicts with this work.
- **Function declarations hoist.** `showCategory` appears once; a duplicate
  declaration silently overrides the first.

---

## 15. Playbooks

### Add one link

1. Edit `data/catalog.js`: one entry line in the project's version block.
2. `node --check data/catalog.js` — must pass.
3. Open `index.html`, click the project, confirm the card and `[ADDED: …]`.
4. Update AGENTS.md, README.md Changelog section, CHANGELOG.md in the same
   change (§5 hard rule 5).

### Fix one link's metadata

Change one field on one line (`notes`, `version`, or `dateAdded`). Keep the
`url` identical. Run `node --check data/catalog.js`, reload, confirm the card.

### Add a whole project section

Add a top-level key with one version block and at least one entry. The
sidebar sorts sections alphabetically at render time. Add a `githubMap`
entry in `index.html` only if a GitHub link should show on the card.

### Release a version

1. Set the version name and date with the user (never guess).
2. Add a `vX.Y.Z` entry to `CHANGELOG.md` and the same entry to the
   Changelog section of `README.md`.
3. Update AGENTS.md (sections affected, file map, counts).
4. One commit with all three files.

---

## 16. Review checklist

- [ ] `node --check data/catalog.js` passes
- [ ] `git diff --check` is clean
- [ ] Catalog entry count preserved (4,138 entries, 31 projects — verified by
      the §13 script or by recounting the tree)
- [ ] Every new entry has `url`, `notes`, `version`, `dateAdded`
- [ ] No invented URLs or dates; dates are `YYYY-MM-DD` or `"unknown"`
- [ ] Splash shows over HTTP and from disk (fallback list)
- [ ] Sidebar lists all projects; search filters; click shows links
- [ ] Theme toggle switches light/dark; `colorScheme` follows
- [ ] `index.html` opens from disk with no server
- [ ] AGENTS.md, README.md Changelog section, CHANGELOG.md updated together

---

## 17. Open questions

- The README states "4,092 unique URLs" as of 2026-11-13; the tree shows
  4,126 unique raw URLs (4,122 scheme-insensitive). The difference is
  unverified; do not change either number without re-counting the tree.
- `fonts.css` 404s for the missing woff2 files are deliberate per the task,
  but noisy in the console. Revisit if the font files are ever vendored.
- No CI or test runner exists in this repo; verification is manual plus
  `node --check`.

---

## Maintenance rule

After any change to the site, update `AGENTS.md` in the same change, update
the Changelog section in `README.md`, and update `CHANGELOG.md`. The three
files are `AGENTS.md`, `README.md` (Changelog section), and `CHANGELOG.md`.
Keeping them in sync is part of every change, not a separate chore. Never
ship a change with a stale `AGENTS.md` or a missing changelog entry.

---

## Verifying this document

Everything here is checkable from a clone:

```bash
wc -l index.html data/catalog.js assets/splashes/splashes.txt      # 292, 4268, 53
wc -c assets/astryx/reset.css assets/astryx/astryx.css             # 11928, 314582
wc -c assets/astryx/theme-neutral.css assets/astryx/fonts.css      # 30284, 3751
grep -vcE '^\s*(#|$)' assets/splashes/splashes.txt                 # 48 phrases
git log --all --format=%ad --date=short | sort -u                   # 2026-11-13
git rev-list --all --count                                          # 1 commit
node --check data/catalog.js                                        # exit 0
git diff --check                                                    # clean
```

If a number here disagrees with the tree, the tree is right: fix the
document in the same commit that changed the code.
