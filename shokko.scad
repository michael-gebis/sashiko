// Description: **Shokkō** — Shokkō (蜀江)
// Shokkō (蜀江) Sashiko Template
// Truncated-square tiling: regular octagons on a square grid, with small squares
// filling the diagonal gaps. Cut full-thickness.

use <sashiko_lib.scad>
include <sashiko_config.scad>

oct_w     = 22;   // octagon width flat-to-flat = grid spacing — pattern scale (mm)
corner_gap= 1.4;  // solid left uncut at each tiling vertex (mm)

e  = oct_w / (1 + sqrt(2));   // octagon edge length (also the small-square edge)
Rc = e / (2 * sin(22.5));     // octagon circumradius
r  = groove_w / 2;

// One edge, drawn short of both ends. A square and two octagons meet at every
// vertex (three edges), so leaving the vertices solid joins them. Only the
// octagons are drawn; each small square is the gap bounded by the diagonal
// edges of its four surrounding octagons.
module seg(p1, p2) {
    L = norm([p2[0]-p1[0], p2[1]-p1[1]]);
    d = [(p2[0]-p1[0])/L, (p2[1]-p1[1])/L];
    if (L > 2*corner_gap + 0.1)
        slot_dash([p1[0]+d[0]*corner_gap, p1[1]+d[1]*corner_gap],
                  [p2[0]-d[0]*corner_gap, p2[1]-d[1]*corner_gap], r);
}

// Regular octagon with axis-aligned edges (vertices at 22.5, 67.5, ...). Its
// vertical/horizontal edges butt against the neighbouring octagons; its diagonal
// edges bound the small squares.
module octagon(cx, cy) {
    V = [for (i = [0:7]) [cx + Rc*cos(22.5 + 45*i),
                          cy + Rc*sin(22.5 + 45*i)]];
    for (i = [0:7]) seg(V[i], V[(i+1)%8]);
}

n_x = ceil(plate_w / oct_w) + 2;
n_y = ceil(plate_h / oct_w) + 2;

sashiko_plate(plate_w, plate_h, plate_t, border, chamfer)
    for (i = [0 : n_x])
        for (j = [0 : n_y])
            octagon((i - 1)*oct_w, (j - 1)*oct_w);
