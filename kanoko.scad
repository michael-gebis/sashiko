// Description: **Kanoko** — Fawn Spots (鹿の子)
// Kanoko (Fawn Spots / 鹿の子) Sashiko Template
// The tie-dye "fawn spot": a grid of small open boxes on an offset (brick) grid.
// Each box is corner-gapped so its centre stays attached — no bridges.

use <sashiko_lib.scad>
include <sashiko_config.scad>

cell      = 10;   // spot-to-spot spacing — pattern scale (mm)
spot      = 2.6;  // spot half-size (mm)
corner_gap= 1.0;  // solid left uncut at each spot corner (mm)

r = groove_w / 2;

module seg(p1, p2) {
    L = norm([p2[0]-p1[0], p2[1]-p1[1]]);
    d = [(p2[0]-p1[0])/L, (p2[1]-p1[1])/L];
    if (L > 2*corner_gap + 0.1)
        slot_dash([p1[0]+d[0]*corner_gap, p1[1]+d[1]*corner_gap],
                  [p2[0]-d[0]*corner_gap, p2[1]-d[1]*corner_gap], r);
}

module spot_box(cx, cy) {
    seg([cx-spot, cy-spot], [cx+spot, cy-spot]); seg([cx+spot, cy-spot], [cx+spot, cy+spot]);
    seg([cx+spot, cy+spot], [cx-spot, cy+spot]); seg([cx-spot, cy+spot], [cx-spot, cy-spot]);
}

n_x = ceil(plate_w / cell) + 2;
n_y = ceil(plate_h / cell) + 2;

sashiko_plate(plate_w, plate_h, plate_t, border, chamfer)
union()
    for (j = [-1 : n_y])
        for (i = [-1 : n_x])
            spot_box(i*cell + (j % 2)*(cell/2), j*cell);
