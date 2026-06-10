// Description: **Raimon** — Thunder (雷文)
// Raimon (Thunder / 雷文) Sashiko Template
// A field of squared spirals (the "thunder"/leiwen key). Each spiral is a single
// open line, so it encloses nothing and needs no bridges; neighbours are rotated
// in quarter turns for the classic interlocking-key look.

use <sashiko_lib.scad>
include <sashiko_config.scad>

unit      = 3;    // spiral arm spacing — pattern scale (mm)
pitch     = 22;   // spiral centre-to-centre spacing (mm)

r = groove_w / 2;

// Squared spiral as grid points (in units), ~1.75 turns inward, open at both ends.
SP = [[-3,3],[-3,-3],[3,-3],[3,3],[-1,3],[-1,-1],[1,-1],[1,1]];

module spiral0() {
    pts = [for (q = SP) [q[0]*unit, q[1]*unit]];
    for (k = [0 : len(pts)-2]) slot_dash(pts[k], pts[k+1], r);
}

module spiral(cx, cy, rot) {
    translate([cx, cy]) rotate([0, 0, rot]) spiral0();
}

n_x = ceil(plate_w / pitch) + 1;
n_y = ceil(plate_h / pitch) + 1;

sashiko_plate(plate_w, plate_h, plate_t, border, chamfer)
    for (i = [0 : n_x])
        for (j = [0 : n_y])
            spiral(i*pitch, j*pitch, 90 * ((i + 2*j) % 4));
