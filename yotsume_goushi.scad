// Description: **Yotsume-goushi** — Four-eye Lattice (四つ目格子)
// Yotsume-goushi (Four-eye Lattice / 四つ目格子) Sashiko Template
// A plain open square lattice — single lines, corner-gapped at every crossing so
// the square "eyes" all stay attached to the plate.

use <sashiko_lib.scad>
include <sashiko_config.scad>

cell      = 14;   // grid pitch — pattern scale (mm)
corner_gap= 1.4;  // solid left uncut at each crossing (mm)

r = groove_w / 2;

module seg(p1, p2) { corner_seg(p1, p2, r, corner_gap); }

ncx = ceil(plate_w / cell) + 2;
ncy = ceil(plate_h / cell) + 2;
Xs = [for (k = [-1 : ncx]) k*cell];
Ys = [for (k = [-1 : ncy]) k*cell];

sashiko_plate(plate_w, plate_h, plate_t, border, chamfer, reg)
union() {
    for (X = Xs) for (idx = [0 : len(Ys)-2]) seg([X, Ys[idx]], [X, Ys[idx+1]]);
    for (Y = Ys) for (idx = [0 : len(Xs)-2]) seg([Xs[idx], Y], [Xs[idx+1], Y]);
}
