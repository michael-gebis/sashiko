// Description: **Ichimatsu** — Checkerboard (市松)
// Ichimatsu (Checkerboard / 市松) Sashiko Template
// The checkerboard drawn as outlined squares on the "filled" cells only (you mark
// the checks, not the colour blocks). Each square is corner-gapped, so its
// interior stays attached and diagonal neighbours join at the shared corners.

use <sashiko_lib.scad>
include <sashiko_config.scad>

cell      = 16;   // check size = grid pitch — pattern scale (mm)
sq_frac   = 0.88; // outlined square side ÷ cell (<1 so checks stay distinct, not a grid)
corner_gap= 1.4;  // solid left uncut at each corner (mm)

r = groove_w / 2;

module seg(p1, p2) { corner_seg(p1, p2, r, corner_gap); }

module box(cx, cy, h) {
    seg([cx-h, cy-h], [cx+h, cy-h]); seg([cx+h, cy-h], [cx+h, cy+h]);
    seg([cx+h, cy+h], [cx-h, cy+h]); seg([cx-h, cy+h], [cx-h, cy-h]);
}

n_x = ceil(plate_w / cell) + 2;
n_y = ceil(plate_h / cell) + 2;

sashiko_plate(plate_w, plate_h, plate_t, border, chamfer, reg)
union()
    for (i = [-1 : n_x])
        for (j = [-1 : n_y])
            if ((i + j) % 2 == 0)
                box((i+0.5)*cell, (j+0.5)*cell, sq_frac*cell/2);
