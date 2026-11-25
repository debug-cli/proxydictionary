# Changelog

One entry per version. Dates are the day the change landed on the branch
(`YYYY-MM-DD`).

## v2.0.0 — 2026-11-24

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

### Fixes (pre-release review)
- Heading contrast: every `:root` `light-dark()` pair was inverted (dark value
  first, light value second), so headings disagreed with the background in
  both themes. Swapped all 13 tokens to `light-dark(light value, dark value)`.
  Headings now use the site `--text` token (`h1`–`h6 { color: var(--text) }`)
  instead of Astryx `--color-text-primary`, and the `VERSION:` h3 lost its
  inline `--text-muted` override. The welcome heading, category headings, and
  section headings are readable in both themes (12.4:1 in light, 12.3:1 in
  dark against the page background).
- Sidebar close icon: the Streamline PNG was squished in the 40px collapsed
  header. Replaced it with an inline Lucide `chevrons-left` SVG (18x18,
  `flex-shrink: 0` on the button and the SVG, centered in the collapsed
  header). Deleted `icons/Sidebar-Line-Left--Streamline-Ultimate.png` and the
  empty `icons/` directory.
- Fonts: Consolas replaced by Space Mono (400, 700) for code, URLs, and
  headings; body, sidebar items, and buttons use Space Grotesk (400, 500,
  700). The five woff2 files (OFL-1.1) are self-hosted in `assets/fonts/`
  with `@font-face` rules and system fallbacks. No font CDN: the site keeps
  working offline from `file://`.
- README counts corrected to the verified catalog numbers: 4,138 entries,
  4,126 unique URLs, 31 projects (the README previously said 4,092 links).
- The `v2.0.0` date is 2026-11-24 (the day the change landed on the branch),
  corrected in `CHANGELOG.md` and `README.md`.
- Moved the four Astryx stylesheet links before the site's own `<style>` in
  `index.html`, matching the documented link order.
- Maintenance rule: `AGENTS.md`, the Changelog section of `README.md`, and
  `CHANGELOG.md` must be updated in the same change as the code.

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
