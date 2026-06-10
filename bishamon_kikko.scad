// Description: **Bishamon Kikkō** — Bishamon Shell (毘沙門亀甲)
// Bishamon Kikkō (毘沙門亀甲) Sashiko Template
// Layered tortoiseshell: the kikko honeycomb with a concentric inner hexagon in
// every cell (the denser, "armoured" tortoiseshell named for Bishamon's armour).
// Both rings use the corner-gap trick, so the plate stays one piece.

use <sashiko_lib.scad>
include <sashiko_config.scad>

hex_r     = 14;   // outer hexagon circumradius — pattern scale (mm)
inner_frac= 0.55; // inner hexagon as a fraction of the outer
corner_gap= 1.4;  // solid left uncut at each hex vertex (mm)

col_sp = hex_r * sqrt(3);   // pointy-top honeycomb spacing
row_sp = hex_r * 1.5;
r = groove_w / 2;

module seg(p1, p2) {
    L = norm([p2[0]-p1[0], p2[1]-p1[1]]);
    d = [(p2[0]-p1[0])/L, (p2[1]-p1[1])/L];
    if (L > 2*corner_gap + 0.1)
        slot_dash([p1[0]+d[0]*corner_gap, p1[1]+d[1]*corner_gap],
                  [p2[0]-d[0]*corner_gap, p2[1]-d[1]*corner_gap], r);
}

module hexagon(cx, cy, R) {
    V = [for (i = [0:5]) [cx + R*cos(90 + 60*i), cy + R*sin(90 + 60*i)]];
    for (i = [0:5]) seg(V[i], V[(i+1)%6]);
}

n_cols = ceil(plate_w / col_sp) + 3;
n_rows = ceil(plate_h / row_sp) + 3;

sashiko_plate(plate_w, plate_h, plate_t, border, chamfer)
union()
    for (row = [0 : n_rows]) {
        row_off = (row % 2) * (col_sp / 2);
        for (col = [0 : n_cols]) {
            cx = (col - 1)*col_sp + row_off;
            cy = (row - 1)*row_sp;
            hexagon(cx, cy, hex_r);
            hexagon(cx, cy, hex_r * inner_frac);
        }
    }
