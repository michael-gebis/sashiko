// Description: **Masu** — Measuring Boxes (枡刺し)
// Masu / Masuzashi (Measuring Boxes / 枡刺し) Sashiko Template
// Nested concentric squares on a grid — the matsukawabishi idea with squares
// instead of lozenges. Both rings corner-gapped (four squares meet at each
// vertex), so every box stays attached.

use <sashiko_lib.scad>
include <sashiko_config.scad>

cell      = 18;   // box size = grid pitch — pattern scale (mm)
inner_frac= 0.5;  // inner box size as a fraction of the outer
corner_gap= 1.4;  // solid left uncut at each corner (mm)

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
            box(i*cell, j*cell, cell/2);              // outer box (edge-to-edge)
            box(i*cell, j*cell, cell/2 * inner_frac); // inner box
        }
