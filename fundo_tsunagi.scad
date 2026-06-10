// Description: **Fundō-tsunagi** — Linked Counterweights (分銅つなぎ)
// Fundō-tsunagi (Linked Counterweights / 分銅つなぎ) Sashiko Template
// A diamond mesh whose edges bow INWARD, so each cell is a concave-sided
// "counterweight". Like amime but pinched rather than puffed: each edge is drawn
// once (as one cell's upper edge) and corner-gapped at the vertices.

use <sashiko_lib.scad>
include <sashiko_config.scad>

mesh_w    = 22;   // cell full width — pattern scale (mm)
mesh_h    = 22;   // cell full height (mm)
sag       = 4;    // how far each edge bows inward (mm)
corner_gap= 1.4;  // solid left uncut at each vertex (mm)

a = mesh_w / 2;  b = mesh_h / 2;
r = groove_w / 2;

// Arc from A to B bowing TOWARD centre C, drawn short of both ends.
module bowed(ax, ay, bx, by, cx, cy) {
    L  = norm([bx-ax, by-ay]);
    px = -(by-ay)/L;  py = (bx-ax)/L;
    s  = ((ax+bx)/2 - cx)*px + ((ay+by)/2 - cy)*py >= 0 ? 1 : -1;
    nx = -px*s;  ny = -py*s;                      // inward (toward C)
    N  = 8;  tg = corner_gap / L;
    pts = [for (k = [0:N]) let (t = tg + (1 - 2*tg) * k/N)
              [ax + (bx-ax)*t + nx*sag*sin(180*t),
               ay + (by-ay)*t + ny*sag*sin(180*t)]];
    for (k = [0 : len(pts)-2]) slot_dash(pts[k], pts[k+1], r);
}

module netcell(cx, cy) {
    bowed(cx-a, cy, cx, cy+b, cx, cy);   // upper-left edge
    bowed(cx, cy+b, cx+a, cy, cx, cy);   // upper-right edge
}

n_i = ceil(plate_w / a) + 2;
n_j = ceil(plate_h / b) + 2;

sashiko_plate(plate_w, plate_h, plate_t, border, chamfer)
union()
    for (i = [-1 : n_i])
        for (j = [-1 : n_j])
            if ((i + j) % 2 == 0)
                netcell(i*a, j*b);
