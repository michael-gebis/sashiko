#!/usr/bin/env bash
# build_gallery.sh — render the sashiko gallery.
#
# For every template (every *.scad except the shared library/config) this renders
# a top-down PNG (gallery/<name>.png) and an angled 3D PNG (gallery/<name>_3d.png),
# then assembles gallery/_contact_sheet.png from the top-downs. Patterns are
# discovered automatically, so adding a new <name>.scad needs no edit here.
#
#   ./build_gallery.sh                 # rebuild every preview + the contact sheet
#   ./build_gallery.sh kanze_mizu ryusui   # re-render just these, then rebuild the sheet
#
# The gallery/INDEX.md table is generated separately by gen_index.py (make index),
# so it is not touched here.
set -euo pipefail
cd "$(dirname "$0")"
mkdir -p gallery

COMMON="--render --imgsize=1000,1000 --colorscheme=Tomorrow"
TOP="--projection=ortho --camera=50,50,0,0,0,0,150"            # top-down (white slots)
ISO="--projection=perspective --camera=50,50,1.5,58,0,22,300"  # angled (shows thickness)

# Every template, alphabetical, minus the shared files.
mapfile -t all < <(for f in *.scad; do
  case "$f" in sashiko_lib.scad|sashiko_config.scad) ;; *) echo "${f%.scad}";; esac
done)

# Render all of them, or only the names passed as arguments.
render=("$@"); [ "${#render[@]}" -eq 0 ] && render=("${all[@]}")
echo "Rendering ${#render[@]} template(s)..."
for p in "${render[@]}"; do
  openscad $COMMON $TOP -o "gallery/$p.png"      "$p.scad" 2>/dev/null
  openscad $COMMON $ISO -o "gallery/${p}_3d.png" "$p.scad" 2>/dev/null
  echo "  $p"
done

echo "Assembling contact sheet (${#all[@]} patterns)..."
inputs=(); for p in "${all[@]}"; do inputs+=("gallery/$p.png"); done
montage -label '%t' "${inputs[@]}" -tile 8x -geometry 175x175+4+7 \
  -background white -fill black -pointsize 13 \
  -title "Sashiko Stitch-Guide Templates (${#all[@]})" gallery/_contact_sheet.png

echo "Done -> gallery/ (+ _contact_sheet.png)"
