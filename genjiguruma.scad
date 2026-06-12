// Description: **Genjiguruma** — Ox-cart Wheels (源氏車)
// Genjiguruma (Ox-cart Wheels / 源氏車) Sashiko Template
// A grid of cart wheels: a bridged rim with radial spokes. The spokes stop short
// of the centre, so the open hub joins all the sectors and the bridged rim joins
// the interior to the plate. The rim breaks at the DIAGONAL spokes, whose tips
// sit inside the breaks — so the rim arcs are trimmed extra: with the default
// bridge_w the spoke cap punches through the tab leaving only ~0.1 mm straps.
// The gap is derived from `strap`, the solid left either side of each tip.

use <sashiko_lib.scad>
include <sashiko_config.scad>

spacing   = 25;   // wheel-to-wheel spacing — pattern scale (mm)
R         = 10.5; // wheel (rim) radius (mm)
spokes    = 8;    // number of spokes
hub       = 3;    // open hub radius — spokes stop here (mm)
strap     = 0.65; // solid between a diagonal spoke tip and each rim arc end (mm)

r = groove_w / 2;

module wheel(cx, cy) {
    // gap sized so the spoke cap (radius r) in the middle leaves `strap` each side
    bridged_circle([cx, cy], R, r, 2*(strap + r), [45, 135, 225, 315]);
    for (k = [0 : spokes-1]) {
        a = 360/spokes * k;
        slot_dash([cx + hub*cos(a), cy + hub*sin(a)],
                  [cx + R*cos(a),   cy + R*sin(a)], r);
    }
}

n_x = ceil(plate_w / spacing) + 1;
n_y = ceil(plate_h / spacing) + 1;

sashiko_plate(plate_w, plate_h, plate_t, border, chamfer, reg)
union()
    for (i = [0 : n_x])
        for (j = [0 : n_y])
            wheel(i*spacing, j*spacing);
