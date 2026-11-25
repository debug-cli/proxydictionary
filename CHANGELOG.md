# Changelog

One entry per version. Dates are the day the change landed on the branch
(`YYYY-MM-DD`).

## v2.0.0 — 2026-11-25

### Astryx design language migration
- Migrated the UI to the Astryx design language, neutral theme, in plain CSS
  with vanilla JS and no build step.
- Vendored `@astryxdesign/core@0.7.17` and `@astryxdesign/theme-neutral@0.7.17`
  (MIT) into `assets/astryx/`: `reset.css` (11,928 bytes), `astryx.css`
  (314,582 bytes), `theme-neutral.css` (30,284 bytes), `fonts.css` (3,751
  bytes). No Figtree woff2 files; `fonts.css` falls back to system sans.
- Linked the four stylesheets in `index.html` before the site's own styles:
  `reset.css`, `astryx.css`, `theme-neutral.css`, `fonts.css`.
- Set `data-astryx-theme="neutral"` on `<html>`.
- Replaced the hand-written dark/light token blocks with Astryx
  `light-dark()` values; mapped radius and duration tokens
  (`--radius-element`, `--duration-fast`, `--duration-medium`) with fallbacks.
- Kept the sidebar layout, search box, copy buttons, theme toggle, offline
  behavior, and mobile readability.

### Splash messages
- Replaced the generic one-word splash list with fresh proxydict phrases in
  `assets/splashes/splashes.txt` (48 phrases), graip style, written for this
  site, not copied from graip.
- `loadSplashes()` fetches the list over HTTP and falls back to an inline list
  of 10 phrases on `file://`; the splash renders as text nodes (`textContent`,
  never `innerHTML`) and picks one phrase at random per load.

### Left-bar fix
- Root cause: a stray comma in the inline catalog literal of `index.html`
  (`...}]}, , "Rosin": ...`) killed the whole script, so `render()` never ran.
- Deleted the stray comma; `node --check` on the extracted script now passes.
- One bad entry must never kill the page again: see the defensive render rule
  in AGENTS.md §7.

### Data editing and date-added metadata
- Moved the catalog out of `index.html` into `data/catalog.js`, loaded with a
  `<script src>` tag (not `fetch()`), so `file://` offline use still works.
- Added `dateAdded` (YYYY-MM-DD) to every entry; shown on the URL card as
  `[ADDED: …]`. All 4,138 entries carry `2026-11-13`, the date the catalog was
  introduced in git history (the single commit on `master`); no per-entry
  dates are known.
- Wrote `DATA.md`: the single guide for adding links, with copy-paste examples
  for adding one link, fixing one link's metadata, and adding a project
  section, plus the validation command `node --check data/catalog.js`.
- `render()` now skips bad entries, logs them to the console, and keeps
  rendering the rest.

### Documentation
- Wrote `AGENTS.md` in technical book style: mental model, repository map,
  data format and metadata rules, URL card field map, link-adding workflow and
  validation command, defensive render rule, offline constraint, Astryx
  migration, splash system, sidebar and render flow, the left-bar bug and its
  fix, testing, traps, playbooks, review checklist, open questions.
- Wrote this `CHANGELOG.md` and updated the Changelog section of `README.md`
  with the same `v2.0.0` entry.

## v1.0.0 — 2026-11-13 — Initial Release

- Single-file offline index of public web proxy mirrors, grouped by project.
- 31 projects, 4,138 entries (4,126 unique URLs), Interstellar mirrors make up
  4,014 of them.
- No build step, no dependencies, runs from a USB stick by opening
  `index.html` directly from disk.

## Unchanged (still true after v2.0.0)

- Data entries, URLs, versions, and notes: nothing dropped, invented, or
  altered. Verified entry-by-entry against the previous version.
- Offline behavior: `index.html` opens from disk with no server.
- No build step, no dependencies, no bundler, no framework, no npm.
