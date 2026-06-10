// Description: **Wachigai** — Linked Rings (輪違い)
// Wachigai (Linked Rings / 輪違い) Sashiko Template
// Overlapping rings on a hexagonal packing, so each ring interlocks with six
// neighbours (chain-mail look, distinct from shippō's square grid). Each ring is
// bridged toward all six neighbours — i.e. at every overlap — so the ring
// interiors and the gaps between them all stay tied to the plate.

use <sashiko_lib.scad>
include <sashiko_config.scad>

spacing   = 20;   // ring centre-to-centre spacing — pattern scale (mm)
ring_frac = 0.58; // radius as a fraction of spacing (>0.5 so rings overlap)
bridge_w  = 1.4;  // solid tab left in each ring (mm)

R  = ring_frac * spacing;
sy = spacing * sqrt(3) / 2;   // row spacing of the hex packing
r  = groove_w / 2;

n_x = ceil(plate_w / spacing) + 2;
n_y = ceil(plate_h / sy) + 2;

sashiko_plate(plate_w, plate_h, plate_t, border, chamfer)
    for (j = [-1 : n_y])
        for (i = [-1 : n_x])
            bridged_circle([i*spacing + (j % 2)*(spacing/2), j*sy],
                           R, r, bridge_w, [0, 60, 120, 180, 240, 300]);
