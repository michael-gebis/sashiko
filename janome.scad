// Description: **Janome** — Snake-eye (蛇の目)
// Janome (Snake-eye / 蛇の目) Sashiko Template
// A grid of bullseyes: two concentric bridged rings around a centre dot. Rings
// are bridged at the cardinals/diagonals so the annulus and centre stay attached;
// motifs don't overlap, so the background ties everything together.

use <sashiko_lib.scad>
include <sashiko_config.scad>

spacing   = 22;   // motif-to-motif spacing — pattern scale (mm)
R_out     = 9;    // outer ring radius (mm)
R_in      = 5;    // inner ring radius (mm)
dot_r     = 1.6;  // centre dot radius (mm)

r = groove_w / 2;

module janome(cx, cy) {
    bridged_circle([cx, cy], R_out, r, bridge_w, [0, 90, 180, 270]);
    bridged_circle([cx, cy], R_in,  r, bridge_w, [45, 135, 225, 315]);
    translate([cx, cy]) circle(r = dot_r, $fn = 16);
}

n_x = ceil(plate_w / spacing) + 1;
n_y = ceil(plate_h / spacing) + 1;

sashiko_plate(plate_w, plate_h, plate_t, border, chamfer, reg)
union()
    for (i = [0 : n_x])
        for (j = [0 : n_y])
            janome(i*spacing, j*spacing);
