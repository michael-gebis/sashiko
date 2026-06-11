// Description: **Jūji** — Cross Stitch (十字)
// Jūji (Cross Stitch / 十字) Sashiko Template
// Hitomezashi field of simple + crosses on a square grid. Open segments that
// enclose nothing, so no bridges are needed (cf. komezashi, kikko_plus).

use <sashiko_lib.scad>
include <sashiko_config.scad>

cell      = 10;   // grid pitch between crosses — pattern scale (mm)
arm_frac  = 0.6;  // cross diameter as a fraction of the pitch (<1 keeps them apart)

s = arm_frac * cell / 2;   // half-length of each arm
r = groove_w / 2;

// A "+" centred at (cx,cy) — two crossing open dashes, no enclosed region.
module cross(cx, cy) {
    slot_dash([cx - s, cy], [cx + s, cy], r);
    slot_dash([cx, cy - s], [cx, cy + s], r);
}

n_x = ceil(plate_w / cell) + 1;
n_y = ceil(plate_h / cell) + 1;

sashiko_plate(plate_w, plate_h, plate_t, border, chamfer, reg)
    for (i = [0 : n_x])
        for (j = [0 : n_y])
            cross(i*cell, j*cell);
