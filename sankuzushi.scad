// Description: **Sankuzushi** — Triple Basket Weave (三崩し)
// Sankuzushi (Triple Basket Weave / 三崩し) Sashiko Template
// Groups of three parallel dashes alternating horizontal/vertical on a
// checkerboard — the classic counting-rods basket weave. All open lines, so no
// bridges are needed; dash ends stop 0.8 mm short of the neighbouring trio.

use <sashiko_lib.scad>
include <sashiko_config.scad>

cell = 12;   // weave cell size — pattern scale (mm); dash spacing is cell/3

r = groove_w / 2;

module trio_h(cx, cy) {
    for (k = [-1 : 1])
        slot_dash([cx - cell/2, cy + k*cell/3], [cx + cell/2, cy + k*cell/3], r);
}
module trio_v(cx, cy) {
    for (k = [-1 : 1])
        slot_dash([cx + k*cell/3, cy - cell/2], [cx + k*cell/3, cy + cell/2], r);
}

n = ceil(plate_w / cell) + 2;

sashiko_plate(plate_w, plate_h, plate_t, border, chamfer, reg)
union()
    for (i = [-1 : n])
        for (j = [-1 : n])
            if ((i + j) % 2 == 0) trio_h((i+0.5)*cell, (j+0.5)*cell);
            else                  trio_v((i+0.5)*cell, (j+0.5)*cell);
