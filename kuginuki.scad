// Description: **Kuginuki** — Nail-puller (釘抜き)
// Kuginuki (Nail-puller / 釘抜き) Sashiko Template
// A grid of square "washer" frames (a square ring), spaced apart so they read as
// the linked nail-puller crest. Outer and inner squares are corner-gapped, so the
// frame and its centre stay attached — no bridges.

use <sashiko_lib.scad>
include <sashiko_config.scad>

cell      = 16;   // frame-to-frame spacing — pattern scale (mm)
outer     = 6;    // outer half-size (mm)
inner     = 3.5;  // inner half-size (mm); outer-inner is the frame width
corner_gap= 1.3;  // solid left uncut at each corner (mm)

r = groove_w / 2;

module seg(p1, p2) {
    L = norm([p2[0]-p1[0], p2[1]-p1[1]]);
    d = [(p2[0]-p1[0])/L, (p2[1]-p1[1])/L];
    if (L > 2*corner_gap + 0.1)
        slot_dash([p1[0]+d[0]*corner_gap, p1[1]+d[1]*corner_gap],
                  [p2[0]-d[0]*corner_gap, p2[1]-d[1]*corner_gap], r);
}

module box(cx, cy, h) {
    seg([cx-h, cy-h], [cx+h, cy-h]); seg([cx+h, cy-h], [cx+h, cy+h]);
    seg([cx+h, cy+h], [cx-h, cy+h]); seg([cx-h, cy+h], [cx-h, cy-h]);
}

n_x = ceil(plate_w / cell) + 2;
n_y = ceil(plate_h / cell) + 2;

sashiko_plate(plate_w, plate_h, plate_t, border, chamfer)
union()
    for (i = [-1 : n_x])
        for (j = [-1 : n_y]) {
            box(i*cell, j*cell, outer);   // frame outer edge
            box(i*cell, j*cell, inner);   // frame inner edge (the hole)
        }
