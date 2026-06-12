// Description: **Hōgan** — Stitcher's Guide Grid (方眼)
// Hōgan (Stitcher's Guide Grid / 方眼) Sashiko Template
// Not a motif: a plain dot grid on the standard 5 mm hitomezashi pitch. Real
// one-stitch sashiko is counted on a marked grid, so this is the plate you
// reach for before stitching your own pattern. Dots are isolated holes — no
// bridges needed. Only whole dots inside the window are cut.

use <sashiko_lib.scad>
include <sashiko_config.scad>

pitch = 5;    // grid spacing (mm) — the standard hitomezashi count
dot   = 1.0;  // dot radius (mm); fits a fine fabric pen

lo = border + dot + 0.5;   // keep dots whole, clear of the window edge

sashiko_plate(plate_w, plate_h, plate_t, border, chamfer, reg)
union()
    for (x = [pitch : pitch : plate_w - pitch])
        for (y = [pitch : pitch : plate_h - pitch])
            if (x >= lo && x <= plate_w - lo && y >= lo && y <= plate_h - lo)
                translate([x, y]) circle(r = dot, $fn = 24);
