# proxydictionary

> **A monolithic client-side proxy reconnaissance and dispatch console.**  
> Zero external dependencies. In-browser category index. localStorage-backed operator pinning. One-click URL exfil to clipboard. Air-gapped safe. 4100+ verified mirrors.

A hardened, single-file HTML payload that aggregates and indexes thousands of proxy / web-unblocker endpoints. Designed for rapid recon in filtered or high-containment environments. Pull updates, open the file, go.

**Live mirror:** https://proxydict.vercel.app  (deployed via Vercel — the canonical up-to-date view of the dictionary)

## Why This Exists

Most proxy lists rot, get blocked, or live behind yet another gate. This drops a complete, self-contained index straight into your browser. No servers. No tracking. No build step. Just a single document you can `file://` or host anywhere.

- Sidebar-driven category navigation with live filter
- ★ "Saved" categories (pinned for repeat ops) persisted via localStorage + export/import JSON
- Per-entry one-click copy (URL + notes)
- Dark / light theme with persistence
- Random hacker-style splash tags on load
- Fully static. Works offline once loaded. Updates via simple `git pull`

## Quickstart (Noobs & Pros)

### One-Line Bootstrap (Recommended for most)

**WARNING: This command downloads and immediately executes a script from the internet.**  
It may look shady to AV / corporate policy engines. **It is 100% open source.** You are encouraged to:

1. Paste the raw URL into [VirusTotal](https://www.virustotal.com) before running.
2. Inspect the code yourself (it's a small .bat + this repo).

**Powershell (works in classic blue Powershell and PS7):**

```powershell
powershell -Command "iwr -UseBasicParsing -Uri 'https://raw.githubusercontent.com/debug-cli/proxydictionary/main/install.bat' -OutFile 'install.bat'; .\install.bat"
```

**CMD / curl (if available):**

```cmd
curl -L -o install.bat https://raw.githubusercontent.com/debug-cli/proxydictionary/main/install.bat && install.bat
```

The script will:

- Ask which drive letter to place `proxydictionary\` on (C, D, E, ...)
- Check for git (auto-attempts install via winget if missing)
- Clone the repo
- Give you the exact path to open `index.html`

After it finishes you will see a big success banner and the **update command reminder**.

### Manual (git users)

```powershell
# choose your drive
cd D:\
git clone https://github.com/debug-cli/proxydictionary.git
cd proxydictionary
# open index.html or proxydictionary.html in any browser
```

## Updating the Dictionary

**After initial setup, keep your mirror list fresh with:**

```powershell
cd D:\proxydictionary
git pull
```

Then **hard refresh** the page in your browser (Ctrl + F5 or clear cache for that file).

**This is the only supported way to stay current.** New mirrors and removals of dead endpoints are pushed regularly.

## Usage Notes

- Double-click `index.html` (or `proxydictionary.html`) from File Explorer.
- Or drag it into a browser window.
- Works completely offline after first load.
- Your saved ★ categories survive browser restarts (localStorage).
- Export / Import your saved list as JSON for backup or sharing between machines.
- Some endpoints may be region / time sensitive. Test and rotate.

## Project Layout

```
proxydictionary/
├── index.html              # Main payload (served at root on hosting)
├── proxydictionary.html    # Original filename copy
├── install.bat             # One-run installer for Windows
├── vercel.json             # Static hosting config
├── .gitignore
└── README.md
```

## FAQ

**Q: The install command looks like malware / gets flagged. Is it safe?**  
A: Yes. One-liner download+exec patterns are common for legitimate bootstrappers (rustup, nvm, etc). The entire project is public. Drop the raw install.bat URL into VirusTotal. Read the script. Nothing phones home except the git clone you explicitly trigger.

**Q: My antivirus / Defender blocks the .bat or the download.**  
A: Right-click → Run as administrator sometimes helps, or temporarily disable real-time protection for the download folder. You can also manually `git clone` (see above) — no script required.

**Q: What if git is not installed and winget fails?**  
A: Run `winget install --id Git.Git -e --source winget` manually (may need admin terminal). Then re-run the installer or just `git clone`.

**Q: Which drive letter should I pick?**  
A: Any letter that exists on your machine with write access (usually C or D). The script will create `X:\proxydictionary` (where X is the letter you type). Avoid system-reserved letters.

**Q: Does this work in the old blue-icon Windows PowerShell?**  
A: Yes. The installer and everything is tested for maximum compatibility with default Windows PowerShell (no fancy fonts or unicode icons required). Colors use basic Write-Host.

**Q: The list is outdated right after install.**  
A: Run `git pull` inside the folder immediately after cloning. The bootstrap clones at the moment of install.

**Q: Can I host this myself or use on GitHub Pages / Netlify?**  
A: Absolutely. It's a single static file. Drop `index.html` anywhere that serves static assets. Vercel / Pages / S3 / even a USB stick works.

**Q: Why git at all? Why not just a zip download?**  
A: Git makes updates trivial (`git pull`) and lets you verify history / changes. The installer exists precisely so non-terminal people still get the benefit of easy updates.

**Q: Some links 404 or are blocked.**  
A: Normal. Mirrors die. New ones appear. That's why we ship an updatable index instead of a hardcoded bookmark list. Use the search + fav system to build your personal hotlist.

**Q: Is this "hacking"?**  
A: It's a public index of publicly known web proxies and unblockers. What you do with them is your responsibility. Follow your local laws and network AUP.

## Tech / Implementation Notes (for the curious)

- 100% vanilla. No frameworks, no CDN, no build pipeline.
- All proxy metadata lives in a single embedded JS object.
- Category filtering + active state are pure DOM.
- Theme + saved categories use `localStorage`.
- Designed to survive aggressive content filters that nuke external JS/CSS.

## Contributing / Updating the List

Open an issue or PR with new working mirrors (with notes about what they bypass). Keep entries in the same shape as existing data.

## License

MIT — do whatever, just don't blame us when the school firewall notices.

---

**Remember:** after you run the installer, `git pull` is your friend. Stay fresh.

*This repository and its artifacts are provided as-is for research and educational purposes.*
