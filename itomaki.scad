// Description: **Itomaki** — Thread Spools (糸巻き)
// Itomaki (Thread Spools / 糸巻き) Sashiko Template
// Angular thread spools — flange bars top and bottom joined by waisted diagonal
// sides — alternating upright/sideways on a checkerboard. Every vertex is
// corner-gapped (wider at the shallow 63° flange corners, narrower at the wide
// 127° waist), so each spool's interior stays attached through six gaps.

use <sashiko_lib.scad>
include <sashiko_config.scad>

cell   = 16;    // spool-to-spool spacing — pattern scale (mm)
fl_w   = 13;    // flange width (mm)
sp_h   = 8;     // spool height, flange to flange (mm)
waist  = 9;     // width across the waist (mm)
gap_f  = 1.7;   // corner gap at the flange corners (63° needs ~1.7)
gap_w  = 1.0;   // corner gap at the waist vertices (127° needs only ~1.0)

r = groove_w / 2;

// One spool centred on the origin: two flanges + four waisted diagonals.
module spool() {
    corner_seg([-fl_w/2,  sp_h/2], [ fl_w/2,  sp_h/2], r, gap_f);  // top flange
    corner_seg([-fl_w/2, -sp_h/2], [ fl_w/2, -sp_h/2], r, gap_f);  // bottom flange
    for (sx = [-1, 1]) for (sy = [-1, 1])
        corner_seg2([sx*fl_w/2, sy*sp_h/2], [sx*waist/2, 0], r, gap_f, gap_w);
}

n = ceil(plate_w / cell) + 1;

sashiko_plate(plate_w, plate_h, plate_t, border, chamfer, reg)
union()
    for (i = [0 : n])
        for (j = [0 : n])
            translate([i*cell, j*cell])
                rotate((i + j) % 2 == 0 ? 0 : 90)
                    spool();
