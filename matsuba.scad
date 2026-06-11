// Description: **Matsuba** — Pine Needles (松葉)
// Matsuba (Pine Needles / 松葉) Sashiko Template
// Scattered pine-needle pairs — little open "V" dashes on an offset grid, each
// rotated a different way so the field reads as fallen needles. Open, no bridges.

use <sashiko_lib.scad>
include <sashiko_config.scad>

cell      = 11;   // needle-to-needle spacing — pattern scale (mm)
needle    = 7;    // needle length (mm)
spread    = 16;   // half-angle of the V (deg)

r = groove_w / 2;

module pine(cx, cy, rot) {
    slot_dash([cx, cy], [cx + needle*cos(rot - spread), cy + needle*sin(rot - spread)], r);
    slot_dash([cx, cy], [cx + needle*cos(rot + spread), cy + needle*sin(rot + spread)], r);
}

n_x = ceil(plate_w / cell) + 1;
n_y = ceil(plate_h / cell) + 1;

sashiko_plate(plate_w, plate_h, plate_t, border, chamfer, reg)
union()
    for (j = [0 : n_y])
        for (i = [0 : n_x])
            pine(i*cell + (j % 2)*(cell/2), j*cell, (i*47 + j*89) % 360);
