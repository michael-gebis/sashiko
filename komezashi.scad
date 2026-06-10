// Description: **Komezashi** — Rice Stitch (米刺し)
// Komezashi (Rice Stitch / 米刺し) Sashiko Template
// A hitomezashi ("one stitch") field of 米 rice motifs on a square grid. Each
// motif is four open dashes crossing at a point, so it encloses nothing and
// needs no bridges (cf. the plus in kikko_plus). Cut full-thickness.

use <sashiko_lib.scad>
include <sashiko_config.scad>

cell      = 11;   // grid pitch between rice motifs — pattern scale (mm)
arm_frac  = 0.62; // motif diameter as a fraction of the pitch (<1 keeps motifs apart)

s = arm_frac * cell / 2;   // half-length of the horizontal/vertical arms
d = s / sqrt(2);           // half-extent of the diagonal arms (same arm length)
r = groove_w / 2;

// One 米: horizontal, vertical and the two diagonals, all crossing at (cx,cy).
// Every segment is open, so nothing detaches and no bridges are required.
module rice(cx, cy) {
    slot_dash([cx - s, cy], [cx + s, cy], r);          // horizontal
    slot_dash([cx, cy - s], [cx, cy + s], r);          // vertical
    slot_dash([cx - d, cy - d], [cx + d, cy + d], r);  // diagonal /
    slot_dash([cx - d, cy + d], [cx + d, cy - d], r);  // diagonal \
}

n_x = ceil(plate_w / cell) + 1;
n_y = ceil(plate_h / cell) + 1;

sashiko_plate(plate_w, plate_h, plate_t, border, chamfer)
    for (i = [0 : n_x])
        for (j = [0 : n_y])
            rice(i*cell, j*cell);
