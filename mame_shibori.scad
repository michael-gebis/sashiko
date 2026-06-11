// Description: **Mame-shibori** — Bean Dots (豆絞り)
// Mame-shibori (Bean Dots / 豆絞り) Sashiko Template
// An even field of round dots — the "bean" polka-dot tie-dye, on a hexagonal
// packing. Dots are holes, so no bridges are needed.

use <sashiko_lib.scad>
include <sashiko_config.scad>

spacing   = 9;    // dot spacing — pattern scale (mm)
dot       = 1.8;  // dot radius (mm)

row_sp = spacing * sqrt(3) / 2;
n_x = ceil(plate_w / spacing) + 2;
n_y = ceil(plate_h / row_sp) + 2;

sashiko_plate(plate_w, plate_h, plate_t, border, chamfer, reg)
union()
    for (j = [-1 : n_y])
        for (i = [-1 : n_x])
            translate([i*spacing + (j % 2)*(spacing/2), j*row_sp])
                circle(r = dot, $fn = 24);
