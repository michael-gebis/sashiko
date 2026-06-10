// Description: **Same-komon** — Sharkskin (鮫小紋)
// Same-komon (Sharkskin / 鮫小紋) Sashiko Template
// The fine "sharkskin" texture: tiny dots arranged in nested quarter-fans
// radiating from each grid corner. Dots are holes — they enclose nothing, so no
// bridges are needed.

use <sashiko_lib.scad>
include <sashiko_config.scad>

cell      = 14;   // fan-to-fan spacing — pattern scale (mm)
dot_r     = 0.9;  // dot radius (mm)

r = groove_w / 2;
radii  = [0.30, 0.55, 0.80];        // arc radii as fractions of cell
angles = [9, 27, 45, 63, 81];       // dot angles along each quarter-arc (deg)

// A quarter-fan of dots with its origin at the lower-left corner (ox,oy).
module fan(ox, oy) {
    for (f = radii)
        for (a = angles)
            translate([ox + f*cell*cos(a), oy + f*cell*sin(a)])
                circle(r = dot_r, $fn = 12);
}

n_x = ceil(plate_w / cell) + 1;
n_y = ceil(plate_h / cell) + 1;

sashiko_plate(plate_w, plate_h, plate_t, border, chamfer)
union()
    for (i = [0 : n_x])
        for (j = [0 : n_y])
            fan(i*cell, j*cell);
