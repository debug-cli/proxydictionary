#!/usr/bin/env python3
"""Migrate index.html to the Astryx design language + external catalog + splash loader.

Edits:
  1. <html> gets data-astryx-theme="neutral".
  2. Astryx stylesheet links inserted after </style>, in the required order.
  3. Hand-written dark/light token blocks replaced with light-dark() values.
  4. Inline const data = {...} removed; data/catalog.js loaded via <script src>.
  5. Inline splashes array becomes an inline fallback; loadSplashes() fetches
     assets/splashes/splashes.txt over HTTP and keeps the fallback for file://.
  6. toggleTheme drives color-scheme so light-dark() tokens switch with it.
  7. render() skips bad entries, logs them, and shows dateAdded on each card.
"""
import re
import sys

REPO = "/home/user/proxydictionary"


def fail(msg):
    sys.stderr.write("ERROR: " + msg + "\n")
    sys.exit(1)


def main():
    path = f"{REPO}/index.html"
    with open(path, encoding="utf-8") as f:
        s = f.read()
    orig = s

    # 1. html tag
    count = s.count('<html lang="en" data-theme="dark">')
    if count != 1:
        fail(f"html tag not unique: {count}")
    s = s.replace(
        '<html lang="en" data-theme="dark">',
        '<html lang="en" data-theme="dark" data-astryx-theme="neutral">',
    )

    # 2. Astryx link tags after </style>, required order
    count = s.count("</style>")
    if count != 1:
        fail(f"</style> not unique: {count}")
    links = (
        "</style>\n"
        '    <link rel="stylesheet" href="assets/astryx/reset.css">\n'
        '    <link rel="stylesheet" href="assets/astryx/astryx.css">\n'
        '    <link rel="stylesheet" href="assets/astryx/theme-neutral.css">\n'
        '    <link rel="stylesheet" href="assets/astryx/fonts.css">\n'
    )
    s = s.replace("</style>\n", links, 1)

    # 3. Replace the hand-written dark/light token blocks with light-dark()
    start = s.index("        :root {")
    end = s.index("        * { box-sizing: border-box; }")
    new_block = (
        "        :root {\n"
        "            --bg: light-dark(#0d1117, #fdfdfd);\n"
        "            --sidebar-bg: light-dark(#161b22, #f8f9fa);\n"
        "            --sidebar-border: light-dark(#30363d, #eee);\n"
        "            --text: light-dark(#c9d1d9, #333);\n"
        "            --text-muted: light-dark(#8b949e, #888);\n"
        "            --link: light-dark(#58a6ff, #007bff);\n"
        "            --entry-bg: light-dark(#161b22, #fff);\n"
        "            --entry-border: light-dark(#30363d, #f0f0f0);\n"
        "            --code-bg: light-dark(#0d1117, #f4f4f4);\n"
        "            --btn-bg: light-dark(#21262d, #fff);\n"
        "            --btn-border: light-dark(#30363d, #d0d7de);\n"
        "            --active-bg: light-dark(#1f6feb33, #eef6ff);\n"
        "            --splash: light-dark(#ffcf00, #d4a017);\n"
        "        }\n"
    )
    s = s[:start] + new_block + s[end:]

    # 4. Load catalog from data/catalog.js via <script src>, before the inline script
    count = s.count("<script>")
    if count != 1:
        fail(f"<script> tag not unique: {count}")
    s = s.replace(
        "<script>",
        '    <script src="data/catalog.js"></script>\n    <script>',
        1,
    )

    # 5. Remove the inline const data = {...} line
    m = re.search(r"^        const data = \{.*?\};\n", s, re.DOTALL | re.MULTILINE)
    if not m:
        fail("inline const data block not found")
    s = s[:m.start()] + s[m.end():]

    # 6. Replace inline splashes array with fallback + loader
    m = re.search(r"^        const splashes = \[.*?\];\n", s, re.DOTALL | re.MULTILINE)
    if not m:
        fail("inline const splashes block not found")
    fallback = (
        '        const splashes = [\n'
        '            "One HTML file, zero excuses.",\n'
        '            "Blocked? Try the next one.",\n'
        '            "Filters gonna filter. Mirrors gonna mirror.",\n'
        '            "No build step. No account. No sign-up.",\n'
        '            "Works from a USB stick. Seriously.",\n'
        '            "4,138 links and still no login screen.",\n'
        '            "Open it on a locked laptop. That is the point.",\n'
        '            "Vanilla JS. No bundle. No build step.",\n'
        '            "If mirror #4 dies, mirror #4,014 waits.",\n'
        '            "Dark mode for late-night bypassing.",\n'
        '            "Copy the URL, paste it, breathe.",\n'
        '        ];\n'
        '        async function loadSplashes() {\n'
        '            const el = document.getElementById("splash");\n'
        '            if (!el) return;\n'
        '            if (location.protocol === "http:" || location.protocol === "https:") {\n'
        '                try {\n'
        '                    const res = await fetch("assets/splashes/splashes.txt");\n'
        '                    if (res.ok) {\n'
        '                        const text = await res.text();\n'
        '                        const lines = text.split("\\n").map(l => l.trim())\n'
        '                            .filter(l => l && !l.startsWith("#"));\n'
        '                        if (lines.length > 0) {\n'
        '                            el.textContent = lines[Math.floor(Math.random() * lines.length)];\n'
        '                            return;\n'
        '                        }\n'
        '                    }\n'
        '                } catch (err) {\n'
        '                    console.log("[proxydict] splash fetch failed, using fallback list", err);\n'
        '                }\n'
        '            }\n'
        '            el.textContent = splashes[Math.floor(Math.random() * splashes.length)];\n'
        '        }\n'
        '        loadSplashes();\n'
    )
    s = s[:m.start()] + fallback + s[m.end():]

    # 7. Drop the old one-shot splash assignment (loadSplashes() owns it now)
    old_splash = "        document.getElementById('splash').innerText = splashes[Math.floor(Math.random() * splashes.length)];\n"
    count = s.count(old_splash)
    if count != 1:
        fail(f"splash assignment not unique: {count}")
    s = s.replace(old_splash, "")

    # 8. Theme toggle drives color-scheme so light-dark() switches with it
    old_toggle = (
        "        function toggleTheme() {\n"
        "            const t = document.documentElement.getAttribute('data-theme') === 'dark' ? 'light' : 'dark';\n"
        "            document.documentElement.setAttribute('data-theme', t);\n"
        "            localStorage.setItem('theme', t);\n"
        "        }\n"
        "        if (localStorage.getItem('theme') === 'light') document.documentElement.setAttribute('data-theme', 'light');\n"
    )
    new_toggle = (
        "        const html = document.documentElement;\n"
        "        function toggleTheme() {\n"
        "            const t = html.getAttribute('data-theme') === 'dark' ? 'light' : 'dark';\n"
        "            html.setAttribute('data-theme', t);\n"
        "            html.style.colorScheme = t;\n"
        "            localStorage.setItem('theme', t);\n"
        "        }\n"
        "        if (localStorage.getItem('theme') === 'light') {\n"
        "            html.setAttribute('data-theme', 'light');\n"
        "            html.style.colorScheme = 'light';\n"
        "        } else {\n"
        "            html.setAttribute('data-theme', 'dark');\n"
        "            html.style.colorScheme = 'dark';\n"
        "        }\n"
    )
    count = s.count(old_toggle)
    if count != 1:
        fail(f"toggleTheme block not unique: {count}")
    s = s.replace(old_toggle, new_toggle)

    # 9. Defensive render + dateAdded on the card
    old_render_start = s.index("        function render() {")
    old_render_end = s.index("        function showCategory(cat, el) {")
    new_render = (
        "        function render() {\n"
        "            if (typeof data === 'undefined') {\n"
        '                console.error("[proxydict] catalog data did not load; sidebar stays empty");\n'
        "                return;\n"
        "            }\n"
        "            const sidebar = document.getElementById('sidebar-list');\n"
        "            const container = document.getElementById('category-container');\n"
        "            const categories = Object.keys(data).sort();\n"
        "\n"
        "            const activeCat = document.querySelector('.sidebar-item.active')?.innerText;\n"
        "\n"
        "            sidebar.innerHTML = '';\n"
        "            container.innerHTML = '';\n"
        "\n"
        "            categories.forEach(cat => {\n"
        "                const project = data[cat];\n"
        "                if (!project || typeof project !== 'object') {\n"
        '                    console.error("[proxydict] skipping bad project section", cat);\n'
        "                    return;\n"
        "                }\n"
        "                const item = document.createElement('div');\n"
        "                item.className = 'sidebar-item' + (cat === activeCat ? ' active' : '');\n"
        "                item.innerText = cat;\n"
        "                item.onclick = () => showCategory(cat, item);\n"
        "                sidebar.appendChild(item);\n"
        "\n"
        "                const section = document.createElement('div');\n"
        "                const safeId = 'cat-' + cat.replace(/[^a-z0-9]/gi, '-');\n"
        "                section.id = safeId;\n"
        "                section.className = 'category-section' + (cat === activeCat ? ' active' : '');\n"
        "\n"
        "                const gh = githubMap[cat] || null;\n"
        "                const ghNote = gh ? `GitHub: <a href=\"${gh}\" target=\"_blank\">${gh}</a>` : 'GitHub: N/A';\n"
        "\n"
        "                let html = `\n"
        "                    <div class=\"header-row\">\n"
        "                        <div>\n"
        "                            <h1>${cat}</h1>\n"
        "                            <div class=\"section-github\">${ghNote}</div>\n"
        "                        </div>\n"
        "                    </div>`;\n"
        "\n"
        "                const versions = Object.keys(project).sort((a, b) => (a === \"Unknown\" ? -1 : b === \"Unknown\" ? 1 : a.localeCompare(b)));\n"
        "\n"
        "                versions.forEach(ver => {\n"
        "                    const entries = project[ver];\n"
        "                    if (!Array.isArray(entries)) {\n"
        '                        console.error("[proxydict] skipping bad version", cat, ver, entries);\n'
        "                        return;\n"
        "                    }\n"
        "                    if (ver !== \"Unknown\") html += `<h3 style=\"margin-top:30px; color:var(--text-muted); font-size:12px; border-bottom:1px dashed var(--sidebar-border); padding-bottom:5px;\">VERSION: ${ver}</h3>`;\n"
        "                    entries.forEach(e => {\n"
        "                        try {\n"
        "                            if (!e || typeof e.url !== 'string' || typeof e.notes !== 'string') {\n"
        "                                throw new Error('entry missing url or notes');\n"
        "                            }\n"
        "                            html += `\n"
        "                                <div class=\"entry\">\n"
        "                                    <div class=\"url-row\">\n"
        "                                        <a href=\"${e.url}\" target=\"_blank\" class=\"url-link\">${e.url}</a>\n"
        "                                        <button class=\"copy-btn\" onclick=\"copy('${e.url}')\">COPY</button>\n"
        "                                    </div>\n"
        "                                    <div class=\"meta-line\">\n"
        "                                        <span>[VER: ${ver === \"Unknown\" ? \"N/A\" : ver}]</span>\n"
        "                                        <span>[IDENT: ${e.notes}]</span>\n"
        "                                        <span>[ADDED: ${e.dateAdded === undefined ? 'unknown' : e.dateAdded}]</span>\n"
        "                                    </div>\n"
        "                                </div>`;\n"
        "                        } catch (err) {\n"
        '                            console.error("[proxydict] skipping bad entry in", cat, ver, e, err);\n'
        "                        }\n"
        "                    });\n"
        "                });\n"
        "                section.innerHTML = html;\n"
        "                container.appendChild(section);\n"
        "            });\n"
        "        }\n"
        "\n"
        "        function showCategory(cat, el) {\n"
        "            document.getElementById('welcome').style.display = 'none';\n"
        "            document.querySelectorAll('.category-section').forEach(s => s.classList.remove('active'));\n"
        "            document.querySelectorAll('.sidebar-item').forEach(i => i.classList.remove('active'));\n"
        "            const safeId = 'cat-' + cat.replace(/[^a-z0-9]/gi, '-');\n"
        "            const section = document.getElementById(safeId);\n"
        "            if (!section) return;\n"
        "            section.classList.add('active');\n"
        "            el.classList.add('active');\n"
        "        }\n"
    )
    s = s[:old_render_start] + new_render + s[old_render_end:]

    # 10. Map spacing/radius/duration rules to Astryx tokens (with fallbacks)
    token_swaps = [
        ("color: var(--text); transition: 0.2s; ",
         "color: var(--text); transition: var(--duration-medium, 0.2s); "),
        ("border-radius: 8px; background: var(--entry-bg);",
         "border-radius: var(--radius-element, 8px); background: var(--entry-bg);"),
        ("border-bottom: 1px solid var(--sidebar-border); transition: 0.1s; overflow: hidden;",
         "border-bottom: 1px solid var(--sidebar-border); transition: var(--duration-fast, 0.1s); overflow: hidden;"),
        ("border: 1px solid transparent; transition: 0.2s; font-family: inherit; }",
         "border: 1px solid transparent; transition: var(--duration-medium, 0.2s); font-family: inherit; }"),
    ]
    for old, new in token_swaps:
        count = s.count(old)
        if count != 1:
            fail(f"token swap not unique ({count}): {old[:60]}")
        s = s.replace(old, new, 1)

    with open(path, "w", encoding="utf-8") as f:
        f.write(s)

    if s == orig:
        fail("no changes were made to index.html")
    print("index.html migrated")


if __name__ == "__main__":
    main()
