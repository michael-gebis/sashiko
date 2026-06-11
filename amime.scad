// Description: **Amime** — Fishnet (網目)
// Amime (Fishnet / 網目) Sashiko Template
// A diamond mesh whose edges are bowed into arcs, giving the rounded cells of a
// net. Each edge is drawn by both diamonds that share it, bowing opposite ways,
// so neighbouring cells read as the net's interlaced loops. Four cells meet at
// each vertex; corner gaps there keep the whole plate one piece.

use <sashiko_lib.scad>
include <sashiko_config.scad>

mesh_w    = 22;   // mesh cell full width — pattern scale (mm)
mesh_h    = 22;   // mesh cell full height (mm)
sag       = 4.5;  // how far each edge bows out (mm)
corner_gap= 1.4;  // solid left uncut at each vertex (mm)

a = mesh_w / 2;  b = mesh_h / 2;
r = groove_w / 2;

// Arc from A to B, bowing away from centre C, drawn short of both ends.
module bowed(ax, ay, bx, by, cx, cy) {
    L  = norm([bx-ax, by-ay]);
    px = -(by-ay)/L;  py = (bx-ax)/L;             // unit perpendicular to AB
    s  = ((ax+bx)/2 - cx)*px + ((ay+by)/2 - cy)*py >= 0 ? 1 : -1;
    nx = px*s;  ny = py*s;                        // outward (away from C)
    N  = 8;  tg = corner_gap / L;
    pts = [for (k = [0:N]) let (t = tg + (1 - 2*tg) * k/N)
              [ax + (bx-ax)*t + nx*sag*sin(180*t),
               ay + (by-ay)*t + ny*sag*sin(180*t)]];
    for (k = [0 : len(pts)-2]) slot_dash(pts[k], pts[k+1], r);
}

// Each cell draws only its two UPPER edges (bowed outward); the lower two are
// drawn as the upper edges of the cells below. That way every edge is drawn
// exactly once, so neighbouring arcs don't trap slivers between them.
module netcell(cx, cy) {
    bowed(cx-a, cy, cx, cy+b, cx, cy);   // upper-left edge  (L -> T)
    bowed(cx, cy+b, cx+a, cy, cx, cy);   // upper-right edge (T -> R)
}

n_i = ceil(plate_w / a) + 2;
n_j = ceil(plate_h / b) + 2;

sashiko_plate(plate_w, plate_h, plate_t, border, chamfer, reg)
    for (i = [-1 : n_i])
        for (j = [-1 : n_j])
            if ((i + j) % 2 == 0)
                netcell(i*a, j*b);
