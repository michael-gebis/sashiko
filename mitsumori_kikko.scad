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

module seg(p1, p2) {
    L = norm([p2[0]-p1[0], p2[1]-p1[1]]);
    d = [(p2[0]-p1[0])/L, (p2[1]-p1[1])/L];
    if (L > 2*corner_gap + 0.1)
        slot_dash([p1[0]+d[0]*corner_gap, p1[1]+d[1]*corner_gap],
                  [p2[0]-d[0]*corner_gap, p2[1]-d[1]*corner_gap], r);
}

module hexagon(cx, cy) {
    V = [for (i = [0:5]) [cx + hex_r*cos(90 + 60*i), cy + hex_r*sin(90 + 60*i)]];
    for (i = [0:5]) seg(V[i], V[(i+1)%6]);
}

// Three hexagons whose centres sit hex_r from the group centre, 120° apart —
// they meet at the shared group centre.
module trio(gx, gy) {
    for (k = [0:2])
        hexagon(gx + hex_r*cos(90 + 120*k), gy + hex_r*sin(90 + 120*k));
}

n_x = ceil(plate_w / grp) + 2;
n_y = ceil(plate_h / sy) + 2;

sashiko_plate(plate_w, plate_h, plate_t, border, chamfer)
union()
    for (jrow = [-1 : n_y])
        for (icol = [-1 : n_x])
            trio(icol*grp + (jrow % 2)*(grp/2), jrow*sy);
