#!/usr/bin/env python3
"""Generate gallery/index.html (the GitHub Pages gallery) from the `// Description:`
line in each <name>.scad. Pairs with `make gallery`, which renders the full images
and thumbnails the page references. A .scad with no Description: line gets a console
WARNING and a placeholder caption.

Set REPO_URL below to your repository.
"""
import glob, re, sys

OUT = "gallery/index.html"
REPO_URL = "https://github.com/michael-gebis/sashiko"
DESC = re.compile(r'^//\s*Description:\s*(.+?)\s*$', re.M)

CARD = '''  <figure class="card">
    <a href="{name}.png"><img src="thumb/{name}.png" alt="{alt}" loading="lazy"></a>
    <figcaption>{cap} <a class="d3" href="{name}_3d.png">3D</a></figcaption>
  </figure>'''

PAGE = '''<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Sashiko Stitch-Guide Templates</title>
<style>
  :root {{ color-scheme: light dark; }}
  body {{ font-family: system-ui, -apple-system, sans-serif; margin: 0; }}
  header {{ padding: 1.6rem 1rem; text-align: center; }}
  header h1 {{ margin: 0 0 .3rem; font-weight: 650; }}
  header p {{ margin: 0; opacity: .65; }}
  a {{ color: inherit; }}
  .grid {{ display: grid; grid-template-columns: repeat(auto-fill, minmax(210px, 1fr));
           gap: 1rem; padding: 1.4rem; max-width: 1500px; margin: 0 auto; }}
  .card {{ margin: 0; border-radius: 10px; overflow: hidden; box-shadow: 0 1px 5px rgba(0,0,0,.18); }}
  .card img {{ width: 100%; display: block; aspect-ratio: 1 / 1; }}
  figcaption {{ padding: .5rem .65rem; font-size: .86rem; background: Canvas; }}
  figcaption .d3 {{ float: right; font-size: .78rem; opacity: .5; text-decoration: none; }}
  footer {{ text-align: center; padding: 1.6rem; opacity: .55; font-size: .85rem; }}
</style>
</head>
<body>
<header>
  <h1>Sashiko Stitch-Guide Templates</h1>
  <p>{n} 3D-printable marking-plate patterns &middot; <a href="{repo}">source &amp; STLs</a></p>
</header>
<main class="grid">
{cards}
</main>
<footer>Generated from the <code>.scad</code> sources &middot; MIT</footer>
</body>
</html>
'''

def main():
    cards, missing = [], []
    for scad in sorted(glob.glob("*.scad")):
        if scad in ("sashiko_lib.scad", "sashiko_config.scad"):
            continue
        name = scad[:-5]
        m = DESC.search(open(scad, encoding="utf-8").read())
        if m:
            cap = re.sub(r'\*\*(.+?)\*\*', r'<strong>\1</strong>', m.group(1))
            alt = re.sub(r'\*\*|\s*—.*', '', m.group(1)).strip() or name
        else:
            cap, alt = f'&#9888; <code>{scad}</code> (missing Description)', name
            missing.append(scad)
        cards.append(CARD.format(name=name, cap=cap, alt=alt))
    open(OUT, "w", encoding="utf-8").write(
        PAGE.format(n=len(cards), repo=REPO_URL, cards="\n".join(cards)))
    if missing:
        sys.stderr.write("WARNING: %d file(s) without a Description: line: %s\n"
                         % (len(missing), ", ".join(missing)))
    print(f"gen_index: {len(cards)} patterns -> {OUT}")


if __name__ == "__main__":
    main()
