// Description: **Mokkō** — Melon Crest (木瓜)
// Mokkō (Melon Crest / 木瓜) Sashiko Template
// The four-lobed melon/quince crest: four arcs bulging outward between four cusps
// (on the diagonals), with a concentric inner mokkō. The cusps are corner-gapped
// so each crest's interior stays attached; motifs don't overlap.

use <sashiko_lib.scad>
include <sashiko_config.scad>

spacing   = 21;   // crest spacing — pattern scale (mm)
rc        = 6;    // cusp radius — where the lobes meet (mm)
bulge     = 3.5;  // how far each lobe bulges past the cusps (mm)
inner_frac= 0.55; // inner mokkō size as a fraction of the outer
corner_gap= 1.2;  // solid left uncut at each cusp (mm)

r = groove_w / 2;

// Arc from A to B bowing outward from centre C by `sag`, drawn short of both ends.
module lobe(ax, ay, bx, by, cx, cy, sag) {
    L  = norm([bx-ax, by-ay]);
    px = -(by-ay)/L;  py = (bx-ax)/L;
    s  = ((ax+bx)/2 - cx)*px + ((ay+by)/2 - cy)*py >= 0 ? 1 : -1;
    nx = px*s;  ny = py*s;
    N  = 9;  tg = corner_gap / L;
    pts = [for (k = [0:N]) let (t = tg + (1 - 2*tg) * k/N)
              [ax + (bx-ax)*t + nx*sag*sin(180*t),
               ay + (by-ay)*t + ny*sag*sin(180*t)]];
    for (k = [0 : len(pts)-2]) slot_dash(pts[k], pts[k+1], r);
}

module mokko(cx, cy, rcv, sag) {
    C = [for (d = [45, 135, 225, 315]) [cx + rcv*cos(d), cy + rcv*sin(d)]];
    for (k = [0:3])
        lobe(C[k][0], C[k][1], C[(k+1)%4][0], C[(k+1)%4][1], cx, cy, sag);
}

n_x = ceil(plate_w / spacing) + 1;
n_y = ceil(plate_h / spacing) + 1;

sashiko_plate(plate_w, plate_h, plate_t, border, chamfer, reg)
union()
    for (i = [0 : n_x])
        for (j = [0 : n_y]) {
            mokko(i*spacing, j*spacing, rc, bulge);
            mokko(i*spacing, j*spacing, rc*inner_frac, bulge*inner_frac);
        }
