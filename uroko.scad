// Description: **Uroko** — Fish Scales (鱗)
// Uroko (Fish Scales / 鱗) Sashiko Template
// Triangular tessellation (alternating up/down triangles). Six triangles meet at
// every vertex, so the corner-gap trick keeps them all joined. Drawing only the
// up-triangles already draws every edge — each down-triangle is bounded by the
// edges of its three up-triangle neighbours.

use <sashiko_lib.scad>
include <sashiko_config.scad>

tri       = 15;   // triangle edge — pattern scale (mm)
corner_gap= 1.5;  // solid left uncut at each vertex (mm)

hgt = tri * sqrt(3) / 2;   // triangle height (row spacing)
r = groove_w / 2;

// One edge, drawn short of both ends (six triangles meet per vertex, so the
// solid vertex joins them while the outlines stay continuous).
module seg(p1, p2) {
    L = norm([p2[0]-p1[0], p2[1]-p1[1]]);
    d = [(p2[0]-p1[0])/L, (p2[1]-p1[1])/L];
    if (L > 2*corner_gap + 0.1)
        slot_dash([p1[0]+d[0]*corner_gap, p1[1]+d[1]*corner_gap],
                  [p2[0]-d[0]*corner_gap, p2[1]-d[1]*corner_gap], r);
}

// Upward-pointing triangle with bottom-left corner at (x0,y0).
module up_tri(x0, y0) {
    V = [[x0, y0], [x0 + tri, y0], [x0 + tri/2, y0 + hgt]];
    seg(V[0], V[1]); seg(V[1], V[2]); seg(V[2], V[0]);
}

n_i = ceil(plate_w / tri) + 2;
n_j = ceil(plate_h / hgt) + 2;

sashiko_plate(plate_w, plate_h, plate_t, border, chamfer)
    for (j = [0 : n_j])
        for (i = [-1 : n_i])
            up_tri(i*tri + (j % 2)*(tri/2), j*hgt);
