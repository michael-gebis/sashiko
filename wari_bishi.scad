// Description: **Wari-bishi** — Split Diamond (割菱)
// Wari-bishi (Split Diamond / 割菱) Sashiko Template
// The hishi diamond lattice, each diamond split into four smaller diamonds by
// spokes from the centre to the four edge midpoints. Diamond corners and the
// spoke ends are all corner-gapped, so every sub-diamond stays attached.

use <sashiko_lib.scad>
include <sashiko_config.scad>

dia_w     = 20;   // diamond full width (mm)
dia_h     = 28;   // diamond full height (mm)
corner_gap= 1.4;  // solid left uncut at corners, centre and spoke ends (mm)

a = dia_w / 2;  b = dia_h / 2;
r = groove_w / 2;

module seg(p1, p2) {
    L = norm([p2[0]-p1[0], p2[1]-p1[1]]);
    d = [(p2[0]-p1[0])/L, (p2[1]-p1[1])/L];
    if (L > 2*corner_gap + 0.1)
        slot_dash([p1[0]+d[0]*corner_gap, p1[1]+d[1]*corner_gap],
                  [p2[0]-d[0]*corner_gap, p2[1]-d[1]*corner_gap], r);
}

module diamond(cx, cy) {
    T = [cx, cy+b]; R = [cx+a, cy]; B = [cx, cy-b]; L = [cx-a, cy];
    seg(T, R); seg(R, B); seg(B, L); seg(L, T);            // outline
    seg([cx, cy], [cx+a/2, cy+b/2]); seg([cx, cy], [cx+a/2, cy-b/2]);   // spokes to
    seg([cx, cy], [cx-a/2, cy-b/2]); seg([cx, cy], [cx-a/2, cy+b/2]);   // edge midpoints
}

n_i = ceil(plate_w / a) + 2;
n_j = ceil(plate_h / b) + 2;

sashiko_plate(plate_w, plate_h, plate_t, border, chamfer)
union()
    for (i = [-1 : n_i])
        for (j = [-1 : n_j])
            if ((i + j) % 2 == 0) diamond(i*a, j*b);
