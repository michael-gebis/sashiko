// Description: **Kikkō-hanabishi** — Shell + Flower (亀甲花菱)
// Kikkō-hanabishi (Tortoise Shell + Flower Diamond / 亀甲花菱) Sashiko Template
// The kikko honeycomb with a hanabishi four-petal flower set inside each hexagon.
// Hexagon edges and the flower petals are all corner-gapped, so the plate stays
// one piece.

use <sashiko_lib.scad>
include <sashiko_config.scad>

hex_r     = 15;   // hexagon circumradius — pattern scale (mm)
corner_gap= 1.3;  // solid left uncut at hex vertices and petal corners (mm)

col_sp = hex_r * sqrt(3);
row_sp = hex_r * 1.5;
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

module lozenge(cx, cy, h) {
    seg([cx, cy+h], [cx+h, cy]); seg([cx+h, cy], [cx, cy-h]);
    seg([cx, cy-h], [cx-h, cy]); seg([cx-h, cy], [cx, cy+h]);
}

// Hanabishi: four square-on-point petals around a small centre.
module flower(cx, cy) {
    pd = hex_r*0.40;  pet = hex_r*0.25;
    lozenge(cx, cy+pd, pet); lozenge(cx, cy-pd, pet);
    lozenge(cx+pd, cy, pet); lozenge(cx-pd, cy, pet);
    lozenge(cx, cy, hex_r*0.15);
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
            hexagon(cx, cy);
            flower(cx, cy);
        }
    }
