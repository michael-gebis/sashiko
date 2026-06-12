// Description: **Dan-tsunagi** — Linked Steps (段つなぎ)
// Dan-tsunagi (Linked Steps / 段つなぎ) Sashiko Template
// Staircase lines climbing the plate diagonally, repeated every two steps so
// the flights nest into each other. Each staircase is one continuous open
// polyline (the H and V slots merge at the corners), so no bridges are needed.

use <sashiko_lib.scad>
include <sashiko_config.scad>

step = 8;          // tread size (mm) — pattern scale

pitch = 2 * step;  // vertical spacing between staircases
r = groove_w / 2;

// One staircase starting at (0, y0), climbing right and up across the plate.
module staircase(y0) {
    for (k = [-1 : ceil((plate_w + plate_h) / step)]) {
        slot_dash([k*step,     y0 + k*step], [(k+1)*step, y0 + k*step],     r);
        slot_dash([(k+1)*step, y0 + k*step], [(k+1)*step, y0 + (k+1)*step], r);
    }
}

sashiko_plate(plate_w, plate_h, plate_t, border, chamfer, reg)
union()
    for (n = [-ceil(plate_w / pitch) - 1 : ceil(plate_h / pitch) + 1])
        staircase(n * pitch);
