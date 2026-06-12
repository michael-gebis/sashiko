// Description: **Inazuma** — Lightning (稲妻)
// Inazuma (Lightning / 稲妻) Sashiko Template
// Lightning bolts as stepped chevrons: a staircase that climbs three treads,
// descends three, and repeats — nested rows make the zigzag bands. (Raimon is
// the same vocabulary coiled into spirals.) Continuous open polylines, no
// bridges.

use <sashiko_lib.scad>
include <sashiko_config.scad>

s  = 5;    // tread size (mm)
n  = 3;    // treads per leg — bolt amplitude is n*s
py = 10;   // row spacing (mm)

p = 2*n*s;   // bolt period
r = groove_w / 2;

module bolt(y0) {
    for (m = [-1 : ceil(plate_w / p)]) {
        x0 = m * p;
        for (k = [0 : n-1]) {   // climbing leg
            slot_dash([x0 + k*s,     y0 + k*s], [x0 + (k+1)*s, y0 + k*s],     r);
            slot_dash([x0 + (k+1)*s, y0 + k*s], [x0 + (k+1)*s, y0 + (k+1)*s], r);
        }
        for (k = [0 : n-1]) {   // descending leg
            slot_dash([x0 + (n+k)*s,   y0 + (n-k)*s], [x0 + (n+k+1)*s, y0 + (n-k)*s],   r);
            slot_dash([x0 + (n+k+1)*s, y0 + (n-k)*s], [x0 + (n+k+1)*s, y0 + (n-k-1)*s], r);
        }
    }
}

sashiko_plate(plate_w, plate_h, plate_t, border, chamfer, reg)
union()
    for (j = [-2 : ceil(plate_h / py) + 2])
        bolt(j * py);
