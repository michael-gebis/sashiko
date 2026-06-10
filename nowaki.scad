// Description: **Nowaki** — Grasses in the Wind (野分)
// Nowaki (Grasses in the Wind / 野分) Sashiko Template
// Tufts of grass blades all swept the same way, as if bent by wind. Each blade is
// an open curved line, so nothing is enclosed and no bridges are needed.

use <sashiko_lib.scad>
include <sashiko_config.scad>

blade_len = 15;   // blade length — pattern scale (mm; keep < pitch_y)
bend      = 7;    // how far the tip sweeps sideways (mm)
pitch_x   = 17;   // tuft spacing across (mm)
pitch_y   = 18;   // tuft spacing up (mm)

r = groove_w / 2;

// One blade rising from (bx,by), sweeping sideways (dir = +/-1) as it climbs.
module blade(bx, by, len, bn, dir) {
    N = 9;
    pts = [for (k = [0:N]) let (t = k/N) [bx + dir*bn*sin(90*t), by + len*t]];
    for (k = [0 : len(pts)-2]) slot_dash(pts[k], pts[k+1], r);
}

// All blades rise from one root and fan out (different length + sweep), so they
// never cross each other; kept shorter than pitch_y so they don't reach the row
// above. That leaves every blade an isolated open curve — nothing enclosed.
module tuft(cx, cy, dir) {
    blade(cx, cy, blade_len,      bend*0.6, dir);
    blade(cx, cy, blade_len*0.92, bend,     dir);
    blade(cx, cy, blade_len*0.8,  bend*1.4, dir);
    blade(cx, cy, blade_len*0.66, bend*1.9, dir);
}

sashiko_plate(plate_w, plate_h, plate_t, border, chamfer)
union()
    for (j = [-1 : ceil(plate_h / pitch_y) + 1])
        for (i = [-1 : ceil(plate_w / pitch_x) + 1])
            tuft(i*pitch_x + (j % 2)*(pitch_x/2), j*pitch_y, 1);
