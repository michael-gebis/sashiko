// Description: **Kanze-mizu** — Swirling Water (観世水)
// Kanze-mizu (Swirling Water / 観世水) Sashiko Template
// Whirlpools of concentric arcs, each ring's opening rotated a little so the set
// reads as a spiral. Every arc is open (encloses nothing) and motifs don't
// overlap, so no bridges are needed.

use <sashiko_lib.scad>
include <sashiko_config.scad>

spacing   = 21;   // whirlpool spacing — pattern scale (mm)
r1        = 3;    // innermost arc radius (mm)
ring_gap  = 2.4;  // radial spacing between arcs (mm)
rings     = 3;    // arcs per whirlpool
sweep     = 290;  // arc sweep (deg; <360 leaves the swirl open)
twist     = 34;   // opening rotation per ring (deg) — the spiral

r = groove_w / 2;

module whirl(cx, cy, dir) {
    for (k = [0 : rings-1]) {
        R  = r1 + k*ring_gap;
        a1 = dir * k * twist;
        arc_run([cx, cy], R, r, a1, a1 + dir*sweep);
    }
}

n_x = ceil(plate_w / spacing) + 2;
n_y = ceil(plate_h / (spacing*0.9)) + 2;

sashiko_plate(plate_w, plate_h, plate_t, border, chamfer)
union()
    for (j = [-1 : n_y])
        for (i = [-1 : n_x])
            whirl(i*spacing + (j % 2)*(spacing/2), j*(spacing*0.9),
                  ((i + j) % 2 == 0) ? 1 : -1);
