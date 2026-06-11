// Description: **Ryūsui** — Running Water (流水)
// Ryūsui (Running Water / 流水) Sashiko Template
// Flowing horizontal water: bands of parallel gently-meandering lines, adjacent
// bands phase-shifted so the stream reads as moving. Open lines, so no bridges.

use <sashiko_lib.scad>
include <sashiko_config.scad>

period    = 34;   // wavelength of the flow — pattern scale (mm)
amp       = 5;    // meander amplitude (mm)
lines     = 3;    // parallel lines per stream band
line_gap  = 3;    // spacing between the parallel lines (mm)
band_sp   = 19;   // spacing between bands (mm)

r = groove_w / 2;

// One stream band: `lines` parallel wavy lines, phase-shifted by `ph` degrees.
module stream(y0, ph) {
    dx = period / 20;
    n  = ceil(plate_w / dx) + 2;
    for (m = [0 : lines-1]) {
        yo  = y0 + m*line_gap;
        pts = [for (k = [0:n]) [k*dx, yo + amp*sin(360*(k*dx)/period + ph)]];
        for (k = [0 : len(pts)-2]) slot_dash(pts[k], pts[k+1], r);
    }
}

sashiko_plate(plate_w, plate_h, plate_t, border, chamfer, reg)
union()
    for (b = [0 : ceil(plate_h / band_sp) + 1])
        stream(b*band_sp, b*120);
