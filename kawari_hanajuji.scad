// Description: **Kawari Hanajūji** — Variant Cross Flower (変わり花十字)
// Kawari Hanajūji (Variant Cross Flower / 変わり花十字) Sashiko Template
// The cross-flower (juji_hanazashi) with a small diagonal "x" added in each cell
// centre — the diagonal-stitch variant. All open dashes, no bridges.

use <sashiko_lib.scad>
include <sashiko_config.scad>

cell      = 13;   // cross-to-cross spacing — pattern scale (mm)
arm_frac  = 0.82; // cross arm diameter as a fraction of the pitch
cross_frac= 0.34; // size of the centre "x" as a fraction of the pitch

s = arm_frac * cell / 2;     // cross arm half-length
x = cross_frac * cell / 2;   // centre-x half-extent
d = x / sqrt(2);
r = groove_w / 2;

module plus(cx, cy) {
    slot_dash([cx - s, cy], [cx + s, cy], r);
    slot_dash([cx, cy - s], [cx, cy + s], r);
}

module ex(cx, cy) {
    slot_dash([cx - d, cy - d], [cx + d, cy + d], r);
    slot_dash([cx - d, cy + d], [cx + d, cy - d], r);
}

n_x = ceil(plate_w / cell) + 1;
n_y = ceil(plate_h / cell) + 1;

sashiko_plate(plate_w, plate_h, plate_t, border, chamfer, reg)
union() {
    for (i = [0 : n_x]) for (j = [0 : n_y]) plus(i*cell, j*cell);
    for (i = [0 : n_x]) for (j = [0 : n_y]) ex((i+0.5)*cell, (j+0.5)*cell);
}
