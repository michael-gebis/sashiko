// Description: **Sugiaya** — Herringbone (杉綾)
// Sugiaya (Cedar Twill / Herringbone / 杉綾) Sashiko Template
// Horizontal bands of parallel diagonal dashes whose slope flips each band, so
// the dashes meet in chevrons at the band edges (the herringbone weave). All
// open dashes — nothing enclosed, no bridges.

use <sashiko_lib.scad>
include <sashiko_config.scad>

band      = 11;   // band height = dash run — pattern scale (mm)
line_sp   = 5;    // horizontal spacing of the dashes (mm)

r = groove_w / 2;

// One band [yb, yb+band] filled with slope-`s` (+1 / -1) diagonal dashes.
module twill_band(yb, s) {
    n = ceil((plate_w + band) / line_sp) + 2;
    for (k = [-2 : n]) {
        x0 = k * line_sp;
        slot_dash([x0, yb], [x0 + s*band, yb + band], r);
    }
}

sashiko_plate(plate_w, plate_h, plate_t, border, chamfer, reg)
union()
    for (b = [0 : ceil(plate_h / band) + 1])
        twill_band(b * band, (b % 2 == 0) ? 1 : -1);
