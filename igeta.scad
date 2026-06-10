// Description: **Igeta** — Well Curb (井桁)
// Igeta (Well Curb / 井桁) Sashiko Template
// Double-line square lattice — the 井 "well frame" repeated. Paired lines spaced
// `well` apart run in both directions; a corner gap at every crossing leaves a
// solid node there, so all the small well-squares and the larger cells between
// them stay attached to the plate.

use <sashiko_lib.scad>
include <sashiko_config.scad>

cell      = 18;   // node-to-node spacing (well centres) — pattern scale (mm)
well      = 6;    // well opening (gap between the paired lines) (mm)
corner_gap= 1.4;  // solid left uncut at each line crossing (mm)

r = groove_w / 2;

// One segment, drawn short of both ends so each crossing stays a solid node.
module seg(p1, p2) {
    L = norm([p2[0]-p1[0], p2[1]-p1[1]]);
    d = [(p2[0]-p1[0])/L, (p2[1]-p1[1])/L];
    if (L > 2*corner_gap + 0.1)
        slot_dash([p1[0]+d[0]*corner_gap, p1[1]+d[1]*corner_gap],
                  [p2[0]-d[0]*corner_gap, p2[1]-d[1]*corner_gap], r);
}

ncx = ceil(plate_w / cell) + 2;
ncy = ceil(plate_h / cell) + 2;
Xs = [for (k = [-1 : ncx]) each [k*cell - well/2, k*cell + well/2]];
Ys = [for (k = [-1 : ncy]) each [k*cell - well/2, k*cell + well/2]];

sashiko_plate(plate_w, plate_h, plate_t, border, chamfer)
union() {
    for (X = Xs) for (idx = [0 : len(Ys)-2]) seg([X, Ys[idx]], [X, Ys[idx+1]]);
    for (Y = Ys) for (idx = [0 : len(Xs)-2]) seg([Xs[idx], Y], [Xs[idx+1], Y]);
}
