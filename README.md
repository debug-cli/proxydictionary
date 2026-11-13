<div align="center">

<h1 align="center"><a href="https://proxydict.vercel.app"><img alt="proxydict" src="assets/title.svg" width="760"></a></h1>

<p>A single-file, offline index of public web proxy mirrors, grouped by project.</p>

<p align="center">
<a href="https://github.com/debug-cli/proxydictionary/stargazers"><picture><source media="(prefers-color-scheme: dark)" srcset="https://www.shieldcn.dev/github/stars/debug-cli/proxydictionary.svg?variant=flat-square&size=sm&mode=dark&font=jetbrains-mono"><img alt="GitHub stars" src="https://www.shieldcn.dev/github/stars/debug-cli/proxydictionary.svg?variant=flat-square&size=sm&mode=light&font=jetbrains-mono"></picture></a>
<a href="https://github.com/debug-cli/proxydictionary/network/members"><picture><source media="(prefers-color-scheme: dark)" srcset="https://www.shieldcn.dev/github/forks/debug-cli/proxydictionary.svg?variant=flat-square&size=sm&mode=dark&font=jetbrains-mono"><img alt="GitHub forks" src="https://www.shieldcn.dev/github/forks/debug-cli/proxydictionary.svg?variant=flat-square&size=sm&mode=light&font=jetbrains-mono"></picture></a>
<a href="https://github.com/debug-cli/proxydictionary/commits/master"><picture><source media="(prefers-color-scheme: dark)" srcset="https://www.shieldcn.dev/github/last-commit/debug-cli/proxydictionary.svg?variant=flat-square&size=sm&mode=dark&font=jetbrains-mono"><img alt="GitHub last commit" src="https://www.shieldcn.dev/github/last-commit/debug-cli/proxydictionary.svg?variant=flat-square&size=sm&mode=light&font=jetbrains-mono"></picture></a>
<a href="https://github.com/debug-cli/proxydictionary/commits/master"><picture><source media="(prefers-color-scheme: dark)" srcset="https://www.shieldcn.dev/github/commits/debug-cli/proxydictionary.svg?variant=flat-square&size=sm&mode=dark&font=jetbrains-mono"><img alt="GitHub commits" src="https://www.shieldcn.dev/github/commits/debug-cli/proxydictionary.svg?variant=flat-square&size=sm&mode=light&font=jetbrains-mono"></picture></a>
<a href="https://github.com/debug-cli/proxydictionary/issues"><picture><source media="(prefers-color-scheme: dark)" srcset="https://www.shieldcn.dev/github/open-issues/debug-cli/proxydictionary.svg?variant=flat-square&size=sm&mode=dark&font=jetbrains-mono"><img alt="GitHub open issues" src="https://www.shieldcn.dev/github/open-issues/debug-cli/proxydictionary.svg?variant=flat-square&size=sm&mode=light&font=jetbrains-mono"></picture></a>
<a href="https://github.com/debug-cli/proxydictionary/pulls"><picture><source media="(prefers-color-scheme: dark)" srcset="https://www.shieldcn.dev/github/open-prs/debug-cli/proxydictionary.svg?variant=flat-square&size=sm&mode=dark&font=jetbrains-mono"><img alt="GitHub open PRs" src="https://www.shieldcn.dev/github/open-prs/debug-cli/proxydictionary.svg?variant=flat-square&size=sm&mode=light&font=jetbrains-mono"></picture></a>
<a href="https://github.com/debug-cli/proxydictionary/blob/master/LICENSE"><picture><source media="(prefers-color-scheme: dark)" srcset="https://www.shieldcn.dev/github/license/debug-cli/proxydictionary.svg?variant=flat-square&size=sm&mode=dark&font=jetbrains-mono"><img alt="GitHub license" src="https://www.shieldcn.dev/github/license/debug-cli/proxydictionary.svg?variant=flat-square&size=sm&mode=light&font=jetbrains-mono"></picture></a>
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

The site is one HTML file with the catalog built in. It needs no server, no account, and no internet connection once you have the file.

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

As of 2026-11-13 the catalog holds 4,138 entries (4,092 unique URLs) across 31 projects. Interstellar mirrors make up 4,014 of them. Other projects include Koopbin, Nebulo OS, Lucide, Dominum UBG, DogeUB, Lunar, and a general Website Unblockers list.

Each entry has a URL, the project it runs, the project's own version when known, and a short note. Projects with a public source repo link to it.

Links are collected, not tested. Mirrors go down and get blocked often. If one fails, try the next.

## Adding or fixing a link

Open an issue or a pull request with:

- The URL
- The project it runs (Interstellar, DogeUB, and so on)
- Where you found it
- The date you last saw it load

Contributors and AI agents: read [AGENTS.md](AGENTS.md) before editing the catalog. It covers the data format, how to edit one link's metadata, and how versions and the changelog work.

## Repository

| Path | What it is |
| --- | --- |
| `index.html` | The site and the catalog. Vercel serves it at `/`. |
| `proxydictionary.html` | Older copy of the site. Use `index.html`. |
| `install.bat` | Windows installer for an offline copy |
| `icons/` | UI icons |
| `vercel.json` | Static hosting config |

## Changelog

See [CHANGELOG.md](CHANGELOG.md).

## License

[MIT](LICENSE). Each listed site belongs to its own operator and has its own terms.

## Disclaimer

proxydict lists publicly posted web addresses. It does not host, run, or endorse any of them. Many networks forbid proxies. Follow the rules of the network you use.
