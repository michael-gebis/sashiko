// Description: **Hanabishi** — Flower Diamond (花菱)
// Hanabishi (Flower Diamond / 花菱) Sashiko Template
// A stylised four-petal bloom on a square grid: four small lozenge petals around
// a small centre lozenge. All corner-gapped, so every petal stays attached.

use <sashiko_lib.scad>
include <sashiko_config.scad>

cell      = 19;   // flower-to-flower spacing — pattern scale (mm)
corner_gap= 1.2;  // solid left uncut at each lozenge corner (mm)

r = groove_w / 2;

module seg(p1, p2) { corner_seg(p1, p2, r, corner_gap); }

module lozenge(cx, cy, a, b) {
    seg([cx, cy+b], [cx+a, cy]); seg([cx+a, cy], [cx, cy-b]);
    seg([cx, cy-b], [cx-a, cy]); seg([cx-a, cy], [cx, cy+b]);
}

module flower(cx, cy) {
    pd  = cell*0.28;  // petal offset from centre
    pet = cell*0.17;  // petal half-size (square on point — 90° corners stay open)
    lozenge(cx, cy+pd, pet, pet);   // north petal
    lozenge(cx, cy-pd, pet, pet);   // south petal
    lozenge(cx+pd, cy, pet, pet);   // east petal
    lozenge(cx-pd, cy, pet, pet);   // west petal
    lozenge(cx, cy, cell*0.12, cell*0.12);   // centre
}

n_x = ceil(plate_w / cell) + 1;
n_y = ceil(plate_h / cell) + 1;

sashiko_plate(plate_w, plate_h, plate_t, border, chamfer, reg)
union()
    for (i = [0 : n_x])
        for (j = [0 : n_y])
            flower(i*cell, j*cell);
