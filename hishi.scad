// Description: **Hishi** — Diamond (菱)
// Hishi (Diamond / 菱) Sashiko Template
// Edge-to-edge diamond (rhombus) lattice, cut full-thickness.

use <sashiko_lib.scad>
include <sashiko_config.scad>

dia_w     = 16;   // diamond full width  (mm)
dia_h     = 24;   // diamond full height (mm) — taller than wide is traditional
corner_gap= 1.5;  // solid left uncut at each diamond corner (mm)

a = dia_w / 2;    // half width  (horizontal half-diagonal)
b = dia_h / 2;    // half height (vertical half-diagonal)
r = groove_w / 2;

// One diamond edge, drawn slightly short of both corners. Four diamonds meet
// at every corner, so leaving the corners solid joins them all while the edges
// stay continuous (mid-edge bridges instead break the outline into X shapes).
module seg(p1, p2) { corner_seg(p1, p2, r, corner_gap); }

// Diamonds with half-diagonals (a, b) tile edge-to-edge when centred on every
// (i*a, j*b) with i+j even — each diamond's vertices land on its neighbours'.
module diamond(cx, cy) {
    T = [cx,     cy + b];
    Rt= [cx + a, cy    ];
    B = [cx,     cy - b];
    L = [cx - a, cy    ];
    seg(T, Rt); seg(Rt, B); seg(B, L); seg(L, T);
}

n_i = ceil(plate_w / a) + 2;
n_j = ceil(plate_h / b) + 2;

sashiko_plate(plate_w, plate_h, plate_t, border, chamfer, reg)
    for (i = [0 : n_i])
        for (j = [0 : n_j])
            if ((i + j) % 2 == 0)
                diamond((i - 1)*a, (j - 1)*b);
