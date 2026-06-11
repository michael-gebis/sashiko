// Description: **Yamagata** — Mountains (山形)
// Yamagata (Mountains / 山形) Sashiko Template
// Hitomezashi rows of zigzag "mountains". Each row is one continuous open
// zigzag, so nothing is enclosed and no bridges are needed.

use <sashiko_lib.scad>
include <sashiko_config.scad>

period    = 16;   // mountain width (one peak) — pattern scale (mm)
amp       = 7;    // mountain height (mm)
row_sp    = 13;   // vertical spacing between rows (mm)

r = groove_w / 2;

module zigzag(y0) {
    n = ceil(plate_w / (period/2)) + 2;
    pts = [for (k = [0 : n]) [k*(period/2), y0 + (k % 2 == 0 ? 0 : amp)]];
    for (k = [0 : len(pts)-2]) slot_dash(pts[k], pts[k+1], r);
}

sashiko_plate(plate_w, plate_h, plate_t, border, chamfer, reg)
union()
    for (row = [0 : ceil(plate_h / row_sp) + 1])
        zigzag(row * row_sp);
