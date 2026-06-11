// Description: **Hanmaru-tsunagi** — Linked Semicircles (半丸つなぎ)
// Hanmaru-tsunagi (Linked Semicircles / 半丸つなぎ) Sashiko Template
// Rows of linked semicircle scallops, alternate rows offset by half so they
// interlace. Open arcs (no chords), so nothing is enclosed and no bridges are
// needed.

use <sashiko_lib.scad>
include <sashiko_config.scad>

R         = 9;    // semicircle radius — pattern scale (mm)
row_sp    = 11;   // vertical spacing between rows (mm; keep > R for clean scallops)

r = groove_w / 2;

// One row of linked upper-semicircles along baseline y0.
module scallops(y0, xoff) {
    n = ceil(plate_w / (2*R)) + 2;
    for (k = [-1 : n])
        arc_run([k*2*R + xoff, y0], R, r, 0, 180);
}

sashiko_plate(plate_w, plate_h, plate_t, border, chamfer, reg)
union()
    for (row = [0 : ceil(plate_h / row_sp) + 1])
        scallops(row * row_sp, (row % 2) * R);
