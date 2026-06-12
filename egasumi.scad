// Description: **Egasumi** — Mist Bands (絵霞)
// Egasumi (Mist Bands / 絵霞) Sashiko Template
// The classical mist symbol: long horizontal bars whose middles step down and
// back up, drifting at staggered offsets row to row. Each band is one open
// polyline, so no bridges are needed — an airy ground between denser motifs.

use <sashiko_lib.scad>
include <sashiko_config.scad>

L1   = 22;   // outer bar length (mm)
L2   = 18;   // dipped middle bar length (mm)
v    = 4;    // step depth (mm)
gx   = 8;    // gap between bands along a row (mm)
py   = 11;   // row spacing (mm)

p = 2*L1 + L2 + gx;   // band period along a row
r = groove_w / 2;

module kasumi(x0, y0) {
    slot_dash([x0,           y0],     [x0 + L1,          y0],     r);
    slot_dash([x0 + L1,      y0],     [x0 + L1,          y0 - v], r);
    slot_dash([x0 + L1,      y0 - v], [x0 + L1 + L2,     y0 - v], r);
    slot_dash([x0 + L1 + L2, y0 - v], [x0 + L1 + L2,     y0],     r);
    slot_dash([x0 + L1 + L2, y0],     [x0 + 2*L1 + L2,   y0],     r);
}

sashiko_plate(plate_w, plate_h, plate_t, border, chamfer, reg)
union()
    for (j = [0 : ceil(plate_h / py) + 1])
        for (m = [-1 : ceil(plate_w / p) + 1])
            kasumi(m*p - (j % 3)*23, j*py);
