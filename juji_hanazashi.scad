// Description: **Jūji-hanazashi** — Cross Flower (十字花刺し)
// Jūji-hanazashi (Cross Flower / 十字花刺し) Sashiko Template
// Hitomezashi crosses with long arms, so four crosses around each open cell
// centre cluster into a flower. Open dashes, no bridges.

use <sashiko_lib.scad>
include <sashiko_config.scad>

cell      = 12;   // cross-to-cross spacing — pattern scale (mm)
arm_frac  = 0.85; // arm diameter as a fraction of the pitch (<1 leaves a flower hole)

s = arm_frac * cell / 2;
r = groove_w / 2;

module cross(cx, cy) {
    slot_dash([cx - s, cy], [cx + s, cy], r);
    slot_dash([cx, cy - s], [cx, cy + s], r);
}

n_x = ceil(plate_w / cell) + 1;
n_y = ceil(plate_h / cell) + 1;

sashiko_plate(plate_w, plate_h, plate_t, border, chamfer, reg)
union()
    for (i = [0 : n_x])
        for (j = [0 : n_y])
            cross(i*cell, j*cell);
