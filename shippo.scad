// Description: **Shippō** — Seven Treasures (七宝)
// Shippō (Seven Treasures / 七宝) Sashiko Template
// Flat plate; circles cut full-thickness with bridges at the crossing points.

use <sashiko_lib.scad>
include <sashiko_config.scad>

spacing  = 16;    // centre-to-centre distance between circles (mm)

// r = spacing*√2/2  =>  exactly 4 circles meet at each grid-square centre.
circle_r = spacing * sqrt(2) / 2;

r = groove_w / 2;

// Bridges go at the CARDINAL points (toward each edge-neighbour), i.e. in the
// middle of each lens overlap. That tab directly joins a circle's centre square
// to the petal beyond it. (Bridging at the diagonal tangent points instead
// fails: diagonal circles only touch at a single point, so the "bridge" is a
// point contact, not a solid connection, and every centre square drops out.)
bridge_angles = [0, 90, 180, 270];

module ring(cx, cy)
    bridged_circle([cx, cy], circle_r, r, bridge_w, bridge_angles);

n_cols = ceil(plate_w / spacing) + 3;
n_rows = ceil(plate_h / spacing) + 3;

sashiko_plate(plate_w, plate_h, plate_t, border, chamfer, reg)
    for (row = [0 : n_rows])
        for (col = [0 : n_cols])
            ring((col - 1)*spacing, (row - 1)*spacing);
