// Description: **Tasuki** — Sash-cord Lattice (襷)
// Tasuki (Sash Cord Lattice / 襷) Sashiko Template
// Crossing diagonal lines — a square lattice turned 45°. Each node draws its two
// upward diagonals (so every edge is drawn once); four edges meet at each node,
// corner-gapped, so the diamond cells stay attached.

use <sashiko_lib.scad>
include <sashiko_config.scad>

cell      = 16;   // node spacing — pattern scale (mm)
corner_gap= 1.4;  // solid left uncut at each crossing (mm)

r = groove_w / 2;

module seg(p1, p2) { corner_seg(p1, p2, r, corner_gap); }

n_x = ceil(plate_w / cell) + 2;
n_y = ceil(plate_h / cell) + 2;

sashiko_plate(plate_w, plate_h, plate_t, border, chamfer, reg)
union()
    for (i = [-1 : n_x])
        for (j = [-1 : n_y]) {
            seg([i*cell, j*cell], [(i+1)*cell, (j+1)*cell]);   // up-right diagonal
            seg([i*cell, j*cell], [(i-1)*cell, (j+1)*cell]);   // up-left diagonal
        }
