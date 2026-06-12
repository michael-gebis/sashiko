// Description: **Zenizashi** — Coin Stitch (銭刺し)
// Zenizashi (Coin Stitch / 銭刺し) Sashiko Template
// A grid of old coins: a circle with the square hole of a mon piece. The ring
// is a bridged circle (tabs on the diagonals, away from the square's sides) and
// the square is corner-gapped, so both the rim and the hole's interior stay
// attached.

use <sashiko_lib.scad>
include <sashiko_config.scad>

pitch = 16;   // coin-to-coin spacing — pattern scale (mm)
Rc    = 6;    // coin radius (mm)
sq    = 5;    // square hole side (mm)
gap   = 1.4;  // corner gap on the square (90° corners)

r = groove_w / 2;

module coin(cx, cy) {
    bridged_circle([cx, cy], Rc, r, bridge_w, [45, 135, 225, 315]);
    corner_seg([cx - sq/2, cy - sq/2], [cx + sq/2, cy - sq/2], r, gap);
    corner_seg([cx + sq/2, cy - sq/2], [cx + sq/2, cy + sq/2], r, gap);
    corner_seg([cx + sq/2, cy + sq/2], [cx - sq/2, cy + sq/2], r, gap);
    corner_seg([cx - sq/2, cy + sq/2], [cx - sq/2, cy - sq/2], r, gap);
}

n = ceil(plate_w / pitch) + 1;

sashiko_plate(plate_w, plate_h, plate_t, border, chamfer, reg)
union()
    for (i = [0 : n])
        for (j = [0 : n])
            coin(i*pitch, j*pitch);
