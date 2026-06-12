// Description: **Sorobandama** — Abacus Beads (算盤玉)
// Sorobandama (Abacus Beads / 算盤玉) Sashiko Template
// Columns of small diamonds stacked point-to-point, like beads strung on the
// rods of an abacus. Each bead is corner-gapped, sized per vertex angle: the
// pointy 77° tips get 1.5 mm, the wide 103° sides 1.2 mm; stacked tips share
// one solid plug, hishi-style.

use <sashiko_lib.scad>
include <sashiko_config.scad>

bead_w = 8;    // bead width (mm)
bead_h = 10;   // bead height (mm) — beads stack at this pitch
px     = 14;   // column (rod) spacing — pattern scale (mm)
gap_t  = 1.5;  // corner gap at the pointed top/bottom vertices (77°)
gap_s  = 1.2;  // corner gap at the wide side vertices (103°)

r = groove_w / 2;

module bead(cx, cy) {
    T = [cx, cy + bead_h/2];
    B = [cx, cy - bead_h/2];
    for (sx = [-1, 1]) {
        corner_seg2(T, [cx + sx*bead_w/2, cy], r, gap_t, gap_s);
        corner_seg2(B, [cx + sx*bead_w/2, cy], r, gap_t, gap_s);
    }
}

n_x = ceil(plate_w / px) + 1;
n_y = ceil(plate_h / bead_h) + 1;

sashiko_plate(plate_w, plate_h, plate_t, border, chamfer, reg)
union()
    for (i = [0 : n_x])
        for (j = [-1 : n_y])
            bead(i*px, j*bead_h);
