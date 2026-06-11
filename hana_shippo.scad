// Description: **Hana-shippō** — Flower Seven Treasures (花七宝)
// Hana-shippō (Flower Seven Treasures / 花七宝) Sashiko Template
// The shippō overlapping-circle lattice with a small open flower (an 8-arm
// asterisk) set in the centre of each circle. The circles are bridged at the
// cardinals (as in shippo); the flowers are open, so they add no bridges.

use <sashiko_lib.scad>
include <sashiko_config.scad>

spacing   = 18;   // circle centre spacing — pattern scale (mm)
flower    = 3.2;  // flower arm half-length (mm)

circle_r = spacing * sqrt(2) / 2;   // 4 circles meet at each grid-square centre
r = groove_w / 2;

module hana(cx, cy) {
    d = flower / sqrt(2);
    slot_dash([cx - flower, cy], [cx + flower, cy], r);
    slot_dash([cx, cy - flower], [cx, cy + flower], r);
    slot_dash([cx - d, cy - d], [cx + d, cy + d], r);
    slot_dash([cx - d, cy + d], [cx + d, cy - d], r);
}

n_x = ceil(plate_w / spacing) + 2;
n_y = ceil(plate_h / spacing) + 2;

sashiko_plate(plate_w, plate_h, plate_t, border, chamfer, reg)
union() {
    for (i = [-1 : n_x]) for (j = [-1 : n_y])
        bridged_circle([i*spacing, j*spacing], circle_r, r, bridge_w, [0, 90, 180, 270]);
    for (i = [-1 : n_x]) for (j = [-1 : n_y])
        hana(i*spacing, j*spacing);
}
