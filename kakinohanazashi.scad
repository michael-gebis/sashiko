// Description: **Kakinohanazashi** — Persimmon Flower (柿の花刺し)
// Kakinohanazashi (Persimmon Flower / 柿の花刺し) Sashiko Template
// Hitomezashi flowers: a small "+" inside a diamond of four dashes, on a square
// grid. The diamond is drawn with corner gaps (so it never closes a region) and
// the plus is open, so the whole plate stays one piece without bridges.

use <sashiko_lib.scad>
include <sashiko_config.scad>

cell      = 14;   // flower-to-flower spacing — pattern scale (mm)
petal     = 4.5;  // diamond half-diagonal (mm)
plus_arm  = 2.4;  // central plus arm length (mm; keep < petal so it stays clear)
corner_gap= 1.4;  // solid left uncut at each diamond corner (mm)

r = groove_w / 2;

// One diamond edge, drawn short of both ends so the flower centre stays attached.
module seg(p1, p2) { corner_seg(p1, p2, r, corner_gap); }

module flower(cx, cy) {
    slot_dash([cx - plus_arm, cy], [cx + plus_arm, cy], r);   // plus, horizontal
    slot_dash([cx, cy - plus_arm], [cx, cy + plus_arm], r);   // plus, vertical
    T = [cx, cy + petal]; R = [cx + petal, cy];
    B = [cx, cy - petal]; L = [cx - petal, cy];
    seg(T, R); seg(R, B); seg(B, L); seg(L, T);               // diamond petals
}

n_x = ceil(plate_w / cell) + 1;
n_y = ceil(plate_h / cell) + 1;

sashiko_plate(plate_w, plate_h, plate_t, border, chamfer, reg)
    for (i = [0 : n_x])
        for (j = [0 : n_y])
            flower(i*cell, j*cell);
