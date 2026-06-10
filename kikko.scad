// Description: **Kikkō** — Tortoise Shell (亀甲)
// Kikkō (Tortoise Shell / 亀甲) Sashiko Template
// Regular hexagon honeycomb, cut full-thickness.

use <sashiko_lib.scad>
include <sashiko_config.scad>

hex_r     = 13;   // hexagon circumradius — pattern scale (mm)
corner_gap= 1.5;  // solid left uncut at each hex vertex (mm)

col_sp = hex_r * sqrt(3);   // pointy-top honeycomb spacing
row_sp = hex_r * 1.5;
r = groove_w / 2;

// One hex edge, drawn short of both ends. Three hexagons meet at every vertex,
// so leaving the vertices solid joins them while the outlines stay continuous.
module seg(p1, p2) {
    L = norm([p2[0]-p1[0], p2[1]-p1[1]]);
    d = [(p2[0]-p1[0])/L, (p2[1]-p1[1])/L];
    if (L > 2*corner_gap + 0.1)
        slot_dash([p1[0]+d[0]*corner_gap, p1[1]+d[1]*corner_gap],
                  [p2[0]-d[0]*corner_gap, p2[1]-d[1]*corner_gap], r);
}

module hexagon(cx, cy) {
    V = [for (i = [0:5]) [cx + hex_r*cos(90 + 60*i),
                          cy + hex_r*sin(90 + 60*i)]];
    for (i = [0:5]) seg(V[i], V[(i+1)%6]);
}

n_cols = ceil(plate_w / col_sp) + 3;
n_rows = ceil(plate_h / row_sp) + 3;

sashiko_plate(plate_w, plate_h, plate_t, border, chamfer)
    for (row = [0 : n_rows]) {
        row_off = (row % 2) * (col_sp / 2);
        for (col = [0 : n_cols])
            hexagon((col - 1)*col_sp + row_off, (row - 1)*row_sp);
    }
