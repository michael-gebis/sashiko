// Description: **Mitsumori Kikkō** — Three-grouped Shell (三盛亀甲)
// Mitsumori Kikkō (Three-grouped Tortoise Shell / 三盛亀甲) Sashiko Template
// The literal Bishamon shell: hexagons grouped in interlocking threes (vs. the
// concentric take in bishamon_kikko.scad). Each trio is three hexagons meeting at
// a shared centre; the groups tile with a gap between them. Corner-gapped edges.

use <sashiko_lib.scad>
include <sashiko_config.scad>

hex_r     = 9;    // hexagon circumradius — pattern scale (mm)
corner_gap= 1.3;  // solid left uncut at each vertex (mm)

grp = hex_r * 3.4;           // group-to-group spacing (leaves a gap between trios)
sy  = grp * sqrt(3) / 2;
r = groove_w / 2;

module seg(p1, p2) { corner_seg(p1, p2, r, corner_gap); }

module hexagon(cx, cy) { hex_outline([cx, cy], hex_r, r, corner_gap); }

// Three hexagons whose centres sit hex_r from the group centre, 120° apart —
// they meet at the shared group centre.
module trio(gx, gy) {
    for (k = [0:2])
        hexagon(gx + hex_r*cos(90 + 120*k), gy + hex_r*sin(90 + 120*k));
}

n_x = ceil(plate_w / grp) + 2;
n_y = ceil(plate_h / sy) + 2;

sashiko_plate(plate_w, plate_h, plate_t, border, chamfer, reg)
union()
    for (jrow = [-1 : n_y])
        for (icol = [-1 : n_x])
            trio(icol*grp + (jrow % 2)*(grp/2), jrow*sy);
