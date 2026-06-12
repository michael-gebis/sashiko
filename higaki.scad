// Description: **Higaki** — Cypress Fence (檜垣)
// Higaki (Cypress Fence / 檜垣) Sashiko Template
// Woven cypress-bark fence: columns of three-line planks slanted at 45°,
// alternating direction column to column with a half-plank drop, so the planks
// mesh like braid. All open dashes (inset from the column edges), no bridges.

use <sashiko_lib.scad>
include <sashiko_config.scad>

w    = 12;    // plank span (= column width) — pattern scale (mm)
inset= 1.5;   // dash pull-back from the column boundary (mm)

P = 4*w/3;    // vertical plank pitch (3 lines at w/3 + a double-space break)
r = groove_w / 2;

// One plank: three parallel 45° dashes. d = +1 slants /, d = -1 slants \.
module plank(cx, cy, d) {
    h = w/2 - inset;
    for (k = [-1 : 1])
        slot_dash([cx - h, cy + k*w/3 - d*h], [cx + h, cy + k*w/3 + d*h], r);
}

n_cols = ceil(plate_w / w) + 2;
n_rows = ceil(plate_h / P) + 2;

sashiko_plate(plate_w, plate_h, plate_t, border, chamfer, reg)
union()
    for (i = [-1 : n_cols]) {
        d   = (i % 2 == 0) ? 1 : -1;
        off = (i % 2 == 0) ? 0 : P/2;
        for (j = [-1 : n_rows])
            plank((i + 0.5)*w, j*P + off, d);
    }
