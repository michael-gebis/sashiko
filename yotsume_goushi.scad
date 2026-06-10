// Description: **Yotsume-goushi** — Four-eye Lattice (四つ目格子)
// Yotsume-goushi (Four-eye Lattice / 四つ目格子) Sashiko Template
// A plain open square lattice — single lines, corner-gapped at every crossing so
// the square "eyes" all stay attached to the plate.

use <sashiko_lib.scad>
include <sashiko_config.scad>

cell      = 14;   // grid pitch — pattern scale (mm)
corner_gap= 1.4;  // solid left uncut at each crossing (mm)

r = groove_w / 2;

module seg(p1, p2) {
    L = norm([p2[0]-p1[0], p2[1]-p1[1]]);
    d = [(p2[0]-p1[0])/L, (p2[1]-p1[1])/L];
    if (L > 2*corner_gap + 0.1)
        slot_dash([p1[0]+d[0]*corner_gap, p1[1]+d[1]*corner_gap],
                  [p2[0]-d[0]*corner_gap, p2[1]-d[1]*corner_gap], r);
}

ncx = ceil(plate_w / cell) + 2;
ncy = ceil(plate_h / cell) + 2;
Xs = [for (k = [-1 : ncx]) k*cell];
Ys = [for (k = [-1 : ncy]) k*cell];

sashiko_plate(plate_w, plate_h, plate_t, border, chamfer)
union() {
    for (X = Xs) for (idx = [0 : len(Ys)-2]) seg([X, Ys[idx]], [X, Ys[idx+1]]);
    for (Y = Ys) for (idx = [0 : len(Xs)-2]) seg([Xs[idx], Y], [Xs[idx+1], Y]);
}
