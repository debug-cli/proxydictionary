<div align="center">

<h1 align="center"><a href="https://proxydict.vercel.app"><img alt="proxydict" src="assets/title.svg" width="760"></a></h1>

<p>A single-page, offline index of public web proxy mirrors, grouped by project.</p>

<p align="center">
<a href="https://github.com/debug-cli/proxydictionary/stargazers"><picture><source media="(prefers-color-scheme: dark)" srcset="https://www.shieldcn.dev/github/stars/debug-cli/proxydictionary.svg?variant=flat-square&size=sm&mode=dark&font=jetbrains-mono"><img alt="GitHub stars" src="https://www.shieldcn.dev/github/stars/debug-cli/proxydictionary.svg?variant=flat-square&size=sm&mode=light&font=jetbrains-mono"></picture></a>
<a href="https://github.com/debug-cli/proxydictionary/network/members"><picture><source media="(prefers-color-scheme: dark)" srcset="https://www.shieldcn.dev/github/forks/debug-cli/proxydictionary.svg?variant=flat-square&size=sm&mode=dark&font=jetbrains-mono"><img alt="GitHub forks" src="https://www.shieldcn.dev/github/forks/debug-cli/proxydictionary.svg?variant=flat-square&size=sm&mode=light&font=jetbrains-mono"></picture></a>
<a href="https://github.com/debug-cli/proxydictionary/commits/master"><picture><source media="(prefers-color-scheme: dark)" srcset="https://www.shieldcn.dev/github/last-commit/debug-cli/proxydictionary.svg?variant=flat-square&size=sm&mode=dark&font=jetbrains-mono"><img alt="GitHub last commit" src="https://www.shieldcn.dev/github/last-commit/debug-cli/proxydictionary.svg?variant=flat-square&size=sm&mode=light&font=jetbrains-mono"></picture></a>
<a href="https://github.com/debug-cli/proxydictionary/commits/master"><picture><source media="(prefers-color-scheme: dark)" srcset="https://www.shieldcn.dev/github/commits/debug-cli/proxydictionary.svg?variant=flat-square&size=sm&mode=dark&font=jetbrains-mono"><img alt="GitHub commits" src="https://www.shieldcn.dev/github/commits/debug-cli/proxydictionary.svg?variant=flat-square&size=sm&mode=light&font=jetbrains-mono"></picture></a>
<a href="https://github.com/debug-cli/proxydictionary/issues"><picture><source media="(prefers-color-scheme: dark)" srcset="https://www.shieldcn.dev/github/open-issues/debug-cli/proxydictionary.svg?variant=flat-square&size=sm&mode=dark&font=jetbrains-mono"><img alt="GitHub open issues" src="https://www.shieldcn.dev/github/open-issues/debug-cli/proxydictionary.svg?variant=flat-square&size=sm&mode=light&font=jetbrains-mono"></picture></a>
<a href="https://github.com/debug-cli/proxydictionary/pulls"><picture><source media="(prefers-color-scheme: dark)" srcset="https://www.shieldcn.dev/github/open-prs/debug-cli/proxydictionary.svg?variant=flat-square&size=sm&mode=dark&font=jetbrains-mono"><img alt="GitHub open PRs" src="https://www.shieldcn.dev/github/open-prs/debug-cli/proxydictionary.svg?variant=flat-square&size=sm&mode=light&font=jetbrains-mono"></picture></a>
<a href="https://github.com/debug-cli/proxydictionary/blob/master/LICENSE"><picture><source media="(prefers-color-scheme: dark)" srcset="https://www.shieldcn.dev/github/license/debug-cli/proxydictionary.svg?variant=flat-square&size=sm&mode=dark&font=jetbrains-mono"><img alt="GitHub license" src="https://www.shieldcn.dev/github/license/debug-cli/proxydictionary.svg?variant=flat-square&size=sm&mode=light&font=jetbrains-mono"></picture></a>
<a href="https://github.com/debug-cli/proxydictionary/actions/workflows/links.yml"><picture><source media="(prefers-color-scheme: dark)" srcset="https://github.com/debug-cli/proxydictionary/actions/workflows/links.yml/badge.svg?branch=master"><img alt="Link check" src="https://github.com/debug-cli/proxydictionary/actions/workflows/links.yml/badge.svg?branch=master"></picture></a>
</p>

<p align="center">
<picture><source media="(prefers-color-scheme: dark)" srcset="https://www.shieldcn.dev/badge/Build-No_build_step-1d5fa8.svg?variant=secondary&size=sm&mode=dark&font=jetbrains-mono"><img alt="Build" src="https://www.shieldcn.dev/badge/Build-No_build_step-1d5fa8.svg?variant=secondary&size=sm&mode=light&font=jetbrains-mono"></picture>
<picture><source media="(prefers-color-scheme: dark)" srcset="https://www.shieldcn.dev/badge/Runs-Offline_from_a_USB-1d5fa8.svg?variant=secondary&size=sm&mode=dark&font=jetbrains-mono"><img alt="Runs offline" src="https://www.shieldcn.dev/badge/Runs-Offline_from_a_USB-1d5fa8.svg?variant=secondary&size=sm&mode=light&font=jetbrains-mono"></picture>
<picture><source media="(prefers-color-scheme: dark)" srcset="https://www.shieldcn.dev/badge/Dependencies-None-1d5fa8.svg?variant=secondary&size=sm&mode=dark&font=jetbrains-mono"><img alt="Dependencies" src="https://www.shieldcn.dev/badge/Dependencies-None-1d5fa8.svg?variant=secondary&size=sm&mode=light&font=jetbrains-mono"></picture>
<picture><source media="(prefers-color-scheme: dark)" srcset="https://www.shieldcn.dev/badge/Agent--friendly-AGENTS.md-D97757.svg?variant=secondary&size=sm&mode=dark&font=jetbrains-mono"><img alt="Agent-friendly" src="https://www.shieldcn.dev/badge/Agent--friendly-AGENTS.md-D97757.svg?variant=secondary&size=sm&mode=light&font=jetbrains-mono"></picture>
</p>

<p><a href="https://proxydict.vercel.app"><b>Live site</b></a> · <a href="#quick-start"><b>Quick start</b></a> · <a href="#whats-in-it"><b>What's in it</b></a> · <a href="#adding-or-fixing-a-link"><b>Add a link</b></a></p>

</div>

## Quick start

Open https://proxydict.vercel.app. Pick a project in the sidebar, then copy or open a link.

The site is one page: `index.html` loads the catalog from `data/catalog.js`. It needs no server, no account, and no internet connection once you have the file. Open `index.html` directly from disk (file://) and it works offline, even from a USB stick.

## Offline copy

Use this to carry the catalog on a USB stick.

1. Download `install.bat`:

   ```cmd
   curl -L -o install.bat https://raw.githubusercontent.com/debug-cli/proxydictionary/master/install.bat
   ```

2. Read it, then run it:

   ```cmd
   install.bat
   ```

3. Pick a drive from the numbered list. The script installs Git through winget if needed and clones the repo into a new `proxydictionary` folder on that drive.
4. Open `proxydictionary\index.html` in any browser.

Already have Git? Skip the script:

```cmd
git clone https://github.com/debug-cli/proxydictionary.git
```

## Updating

```cmd
cd proxydictionary
git pull
```

Then reload the page with Ctrl + Shift + R.

## What's in it

As of 2026-11-13 the catalog holds 4,138 entries (4,126 unique URLs) across 31 projects. Interstellar mirrors make up 4,014 of them. Other projects include Koopbin, Nebulo OS, Lucide, Dominum UBG, DogeUB, Lunar, and a general Website Unblockers list.

Each entry has a URL, the project it runs, the project's own version when known, and a short note. Projects with a public source repo link to it.

Links are checked when they are added: the link-check workflow verifies each new link before it merges. Older mirrors still go down and get blocked often. If one fails, try the next.

## Adding or fixing a link

Open an issue or a pull request with:

- The URL
- The project it runs (Interstellar, DogeUB, and so on)
- Where you found it
- The date you last saw it load

Contributors and AI agents: the catalog is edited in `data/catalog.json` ([DATA.md](DATA.md) has copy-paste examples and the validation commands). Read [AGENTS.md](AGENTS.md) for the data format, how to edit one link's metadata, and how versions and the changelog work.

## Repository

| Path | What it is |
| --- | --- |
| `index.html` | The site (sidebar, search, theme toggle, splash, render). Vercel serves it at `/`. |
| `data/catalog.json` | The catalog source of truth (edit this): project → version → entries. |
| `data/catalog.js` | The catalog generated from `catalog.json`: `const data = { project: { version: [entries] } }`. Loaded by a `<script src>` tag, not `fetch()`. Never hand-edited. |
| `proxydictionary.html` | Older copy of the site. Use `index.html`. |
| `install.bat` | Windows installer for an offline copy |
| `DATA.md` | Guide for adding and fixing links (copy-paste examples). |
| `AGENTS.md` | Engineering handbook for anyone changing this repository. |
| `CHANGELOG.md` | One entry per version. |
| `assets/astryx/` | Vendored Astryx CSS v0.7.17 (reset, base, neutral theme, fonts). |
| `assets/splashes/splashes.txt` | Splash phrases, one per line. |
| `vercel.json` | Static hosting config |
| `tools/` | Catalog pipeline (`backfill_dates.py`, `catalog_json_to_js.py`) and the link checker (`check_links.py`); not part of the site. |
| `.github/workflows/links.yml` | Link-check CI: PR gate for new links, weekly full-catalog check. |

## Changelog

See [CHANGELOG.md](CHANGELOG.md).

### v2.0.0 — 2026-11-24

- Astryx design language migration (neutral theme, vendored
  `assets/astryx/reset.css`, `astryx.css`, `theme-neutral.css`, `fonts.css`
  from `@astryxdesign/core@0.7.17` and `@astryxdesign/theme-neutral@0.7.17`,
  `data-astryx-theme="neutral"`, `light-dark()` tokens).
- Splash messages moved to `assets/splashes/splashes.txt` (48 phrases), fetched
  over HTTP with an inline fallback for `file://`, rendered as text nodes.
- Left-bar fix: deleted the stray comma in the inline catalog literal that
  killed the whole script; the sidebar now lists all 31 projects on load.
- Catalog moved from `index.html` to `data/catalog.js` (`<script src>` tag,
  not `fetch()`); every entry gained `dateAdded`, shown on the card as
  `[ADDED: …]` — real per-URL dates from git history (the catalog was built
  on `master` between 2026-07-07 and 2026-07-09; 4,137 entries `2026-07-07`,
  `https://nebulos.app` `2026-07-08`), not guesses; `render()` skips bad
  entries and logs them.
- `data/catalog.json` is now the catalog source of truth (edit it);
  `data/catalog.js` is generated from it with `tools/catalog_json_to_js.py`
  and never hand-edited.
- Link-check workflow (`.github/workflows/links.yml`): every new or changed
  link is verified on its PR (lychee HTTP status + `tools/check_links.py`
  content check for error pages) with results posted as a PR comment, and
  the whole catalog is re-checked weekly. The README gained a link-check
  status tile. On bulk changes the comment is capped per section so it
  posts instead of failing GitHub's comment size limit.
- `DATA.md` (link-editing guide with copy-paste examples and the
  `node --check data/catalog.js` validation command) and `AGENTS.md`
  (technical book handbook) added.
- Pre-release fixes: heading contrast corrected in both themes (all
  `light-dark()` token pairs reordered to `light-dark(light, dark)`; headings
  use the site `--text` token), sidebar close icon replaced with an inline
  Lucide `chevrons-left` SVG that no longer squishes when collapsed, fonts
  switched to self-hosted Space Mono (code, URLs, headings) and Space Grotesk
  (body, sidebar, buttons) with no CDN, and the README counts corrected to
  4,138 entries / 4,126 unique URLs / 31 projects.

### v1.0.0 — 2026-11-13 — Initial Release

- Single-file offline index of public web proxy mirrors, grouped by project.
- 31 projects, 4,138 entries (4,126 unique URLs); no build step, no
  dependencies; runs from a USB stick by opening `index.html` from disk.

## Unchanged

- Data entries, URLs, versions, and notes: nothing dropped, invented, or
  altered. Offline behavior and the no-build-step rule still hold.


## License

[MIT](LICENSE). Each listed site belongs to its own operator and has its own terms.

## Disclaimer

proxydict lists publicly posted web addresses. It does not host, run, or endorse any of them. Many networks forbid proxies. Follow the rules of the network you use.
