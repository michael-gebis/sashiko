// Description: **Hirayama-michi** — Mountain Paths (平山道)
// Hirayama-michi (Mountain Paths / 平山道) Sashiko Template
// The hitomezashi "road over flat hills": rows of flat-topped trapezoid waves —
// flat, climb, flat, descend. Each row is one continuous open polyline (slots
// merge at the corners), so no bridges are needed.

use <sashiko_lib.scad>
include <sashiko_config.scad>

rise = 6;   // hill height = slope run (45°) (mm)
flat = 6;   // flat length on top and bottom (mm)
py   = 9;   // row spacing (mm)

p = 2*flat + 2*rise;   // wave period
r = groove_w / 2;

module road(y0) {
    for (k = [-1 : ceil(plate_w / p)]) {
        x = k * p;
        slot_dash([x,               y0],        [x + flat,            y0],        r);
        slot_dash([x + flat,        y0],        [x + flat + rise,     y0 + rise], r);
        slot_dash([x + flat + rise, y0 + rise], [x + 2*flat + rise,   y0 + rise], r);
        slot_dash([x + 2*flat + rise, y0 + rise], [x + p,             y0],        r);
    }
}

sashiko_plate(plate_w, plate_h, plate_t, border, chamfer, reg)
union()
    for (j = [-1 : ceil(plate_h / py) + 1])
        road(j * py);
