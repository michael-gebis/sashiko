#!/usr/bin/env python3
"""Regenerate the pattern table in gallery/INDEX.md from the `// Description:`
line in each <name>.scad.  Run via `make index` (also part of `make gallery`).

Each row is built as  <Description><br>[link] | <flat png> | <3D png> ,  where the
link and images are templated from the filename and only the descriptive text
comes from the comment (regex: ^//\\s*Description:\\s*(.+)$).

A .scad with no Description: line emits a console WARNING and a visible
placeholder row, so the gap shows up in both the build log and the index.
"""
import glob, re, sys

START, END = "<!-- patterns:start", "<!-- patterns:end"
DESC = re.compile(r'^//\s*Description:\s*(.+?)\s*$', re.M)
INDEX = "gallery/INDEX.md"


def main():
    rows = ["| Pattern | Flat (slots) | 3D (thickness) |", "|---|---|---|"]
    missing = []
    for scad in sorted(glob.glob("*.scad")):
        if scad in ("sashiko_lib.scad", "sashiko_config.scad"):
            continue
        name = scad[:-5]
        m = DESC.search(open(scad, encoding="utf-8").read())
        if m:
            desc = m.group(1)
        else:
            desc = f"⚠️ `{scad}` — **(missing Description)**"
            missing.append(scad)
        rows.append(f'| {desc}<br>[`{scad}`](../{scad}) '
                    f'| <img src="{name}.png" width="320"> '
                    f'| <img src="{name}_3d.png" width="320"> |')

    doc = open(INDEX, encoding="utf-8").read()
    s, e = doc.find(START), doc.find(END)
    if s < 0 or e < 0:
        sys.exit(f"gen_index: markers {START!r}/{END!r} not found in {INDEX}")
    head = doc[: doc.find("-->", s) + 3]
    open(INDEX, "w", encoding="utf-8").write(head + "\n" + "\n".join(rows) + "\n" + doc[e:])

    if missing:
        sys.stderr.write("WARNING: %d file(s) without a Description: line — "
                         "placeholder used: %s\n" % (len(missing), ", ".join(missing)))
    print("gen_index: %d patterns -> %s%s"
          % (len(rows) - 2, INDEX, " (%d placeholder)" % len(missing) if missing else ""))


if __name__ == "__main__":
    main()
