// Description: **Wachigai (woven)** — Interlaced Rings (輪違い)
// Wachigai, woven (Interlaced Rings / 輪違い) Sashiko Template
// True over-under linked rings: a square grid of circles, each overlapping its
// four orthogonal neighbours. At every overlap a ring is drawn THROUGH on its
// leading (+α) side and BROKEN on its trailing (−α) side, so the rings appear to
// weave. The four breaks per ring double as the bridges that keep the plate one
// piece (cf. the flat wachigai.scad, which just overlaps rings).

use <sashiko_lib.scad>
include <sashiko_config.scad>

spacing   = 22;   // ring centre spacing — pattern scale (mm)
ring_frac = 0.62; // radius ÷ spacing (>0.5 so rings overlap the four neighbours)
gap_deg   = 7;    // half-width of each over-under break (deg; <6 starts dropping rings)

R = ring_frac * spacing;
r = groove_w / 2;
alpha = acos(spacing / (2*R));    // half-angle subtended by each crossing pair

// Ring broken at its four "under" crossings (cardinal − α), drawn through the
// four "over" crossings (cardinal + α).
module ring(cx, cy) {
    b = [90 - alpha, 180 - alpha, 270 - alpha, 360 - alpha];   // under-crossing angles
    for (k = [0:3])
        arc_run([cx, cy], R, r,
                b[k] + gap_deg,
                b[(k+1) % 4] + (k == 3 ? 360 : 0) - gap_deg);
}

n_x = ceil(plate_w / spacing) + 2;
n_y = ceil(plate_h / spacing) + 2;

sashiko_plate(plate_w, plate_h, plate_t, border, chamfer, reg)
union()
    for (i = [-1 : n_x])
        for (j = [-1 : n_y])
            ring(i*spacing, j*spacing);
