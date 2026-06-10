// Description: **Umebachi** — Plum Blossom (梅鉢)
// Umebachi (Plum Blossom / 梅鉢) Sashiko Template
// The plum-blossom crest: five petal dots in a ring around a centre dot. Dots are
// round holes — they enclose nothing, so no bridges are needed.

use <sashiko_lib.scad>
include <sashiko_config.scad>

spacing   = 17;   // flower-to-flower spacing — pattern scale (mm)
ring      = 4.5;  // centre-to-petal distance (mm)
petal     = 2.2;  // petal dot radius (mm)
center    = 1.5;  // centre dot radius (mm)

module umebachi(cx, cy) {
    translate([cx, cy]) circle(r = center, $fn = 24);
    for (k = [0:4]) {
        a = 90 + 72*k;
        translate([cx + ring*cos(a), cy + ring*sin(a)]) circle(r = petal, $fn = 24);
    }
}

n_x = ceil(plate_w / spacing) + 1;
n_y = ceil(plate_h / spacing) + 1;

sashiko_plate(plate_w, plate_h, plate_t, border, chamfer)
union()
    for (j = [0 : n_y])
        for (i = [0 : n_x])
            umebachi(i*spacing + (j % 2)*(spacing/2), j*spacing);
