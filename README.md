_Welcome to the home of..._

```
                                ___     __ 
   ___  _______ __ ____ __  ___/ (_)___/ /_
  / _ \/ __/ _ \\ \ / // / / _  / / __/ __/
 / .__/_/  \___/_\_\\_, /  \_,_/_/\__/\__/ 
/_/                /___/                   
```

> **A monolithic client-side proxy reconnaissance and dispatch console.**  
> Zero external dependencies. In-browser category index. localStorage-backed operator pinning. One-click URL exfil to clipboard. Air-gapped safe. 5k+ mirrors.

A hardened, single-file HTML payload that aggregates and indexes thousands of proxy / web-unblocker endpoints. Designed for rapid recon in filtered or high-containment environments. Pull updates, or deploy locally to any static host.

**Live mirror:** https://proxydict.vercel.app  (deployed via Vercel — the canonical up-to-date view of the dictionary)

## Why This Exists

Most proxy lists rot, get blocked, or live behind yet another gate. This drops a complete, self-contained index straight into your browser. No servers. No tracking. No build step. Just a single do[...]

- Sidebar-driven category navigation with live filter
- ★ "Saved" categories (pinned for repeat ops) persisted via localStorage + export/import JSON
- Per-entry one-click copy (URL + notes)
- Dark / light theme with persistence
- Random hacker-style splash tags on load
- Fully static. Works offline once loaded. Updates via simple `git pull`

## Quickstart (Noobs & Pros)

### Prerequisites: winget + curl

**winget** (Windows Package Manager) comes with modern Windows 10/11.

**Check if you have it:**

```powershell
winget --version
```

**If "winget is not recognized":**

1. Open the **Microsoft Store**
2. Search for "**App Installer**" (published by Microsoft)
3. Install / Update it
4. Restart PowerShell or CMD
5. Run `winget --version` again

**Install curl (if missing):**

```powershell
winget install --id curl.curl -e --source winget
```

Restart your terminal after installing curl.

---

### Bootstrap using curl (Recommended)

**This tool is mainly recommended for USB drives.**  
It lets you put a full offline copy of the Proxy Dictionary on a portable USB stick that you can take anywhere.  
**No data will ever be wiped or deleted** — it only adds a new folder.

**Important note before running:**

This downloads and runs a script from the internet. The command might look suspicious to you or to your antivirus software. This project is completely open source — you are encouraged to paste t[...]

**Simple test commands (the installer now fixes line endings automatically):**

Download:

```cmd
curl -L -o install.bat https://raw.githubusercontent.com/debug-cli/proxydictionary/master/install.bat
```

Run:

```cmd
install.bat
```

Or as one combined command:

```powershell
cd $env:TEMP; curl -L -o install.bat https://raw.githubusercontent.com/debug-cli/proxydictionary/master/install.bat; .\install.bat
```

The script will:

- Show a simple numbered menu to select any drive (mainly for USB drives)
- List the Windows system drive first, then any plugged-in drives with details (free space, type)
- Check for git (auto-attempts install via winget if missing)
- Clone the repo into a **new** folder called `proxydictionary`
- Give you the exact path to open `index.html`

**This installer is mainly recommended for USB drives.**  
You can plug in a USB stick, use the numbered menu to select it, and take the full Proxy Dictionary with you anywhere for offline use.  
**Data will NOT be wiped or deleted from anything.** The script only creates a new folder and never touches your existing files.

After it finishes you will see a big success banner and the **update command reminder** (git pull).

**Note:** If you are not putting this on a USB drive, it is usually easier to just use the live website (https://proxydict.vercel.app) or manually run git commands in any folder on your computer. [...]

### Manual (git users) — recommended if NOT using a USB

If you are installing to a regular hard drive or SSD (not a USB), it is often simpler to skip the installer entirely and use git directly, or just visit the website (no drive selection menu needed[...]

```powershell
# choose any convenient folder (example: D:\ or your Documents folder)
cd D:\
git clone https://github.com/debug-cli/proxydictionary.git
cd proxydictionary
# open index.html or proxydictionary.html in any browser
```

**Tip:** For non-USB use, the easiest option is usually the live website:  
https://proxydict.vercel.app

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
├── index.html.bak          # Backup of previous index.html
├── proxydictionary.html    # Original filename copy
├── install.bat             # One-run installer for Windows
├── vercel.json             # Static hosting config
├── icons/                  # UI icon assets
├── .gitignore
└── README.md
```

## FAQ

**Q: The install command looks suspicious or gets blocked by my antivirus. Is it safe?**  
A: Yes. Commands that download and run files are common for legitimate tools (like installing Git or other software). This entire project is public and open source. You can paste the raw install.[...]

**Q: My antivirus software or Windows Defender blocks the batch file or the download.**  
A: Right-click the file and choose "Run as administrator" sometimes helps. You can also temporarily pause real-time protection for the download folder. As an alternative, you can manually clone t[...]

**Q: What if git is not installed and winget fails?**  
A: Run `winget install --id Git.Git -e --source winget` manually (may need admin terminal). Then re-run the installer or just `git clone`.

**Q: How do I select a drive?**  
A: The installer shows a simple numbered menu. It automatically lists:
- Your Windows system drive (C:\ or D:\ etc.)
- Any plugged-in drives (with free space and type)

Just type the number and press Enter. No manual drive letter typing.

It is mainly for USBs. 

**Safety:** It will ONLY create a new folder called `proxydictionary`. It will NEVER delete, wipe, or modify any existing files or data.

If you are not using a USB, you can skip the installer and just use the website (https://proxydict.vercel.app) or clone with git manually.

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
