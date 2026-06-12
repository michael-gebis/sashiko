// Description: **Mitsuuroko** — Three Scales (三つ鱗)
// Mitsuuroko (Three Scales / 三つ鱗) Sashiko Template
// The Hōjō crest: three small triangles grouped into a larger triangle (a
// triangular gap in the middle), tiled in offset rows. Triangle outlines are
// corner-gapped, so each scale stays attached.

use <sashiko_lib.scad>
include <sashiko_config.scad>

tri       = 9;    // small triangle edge — pattern scale (mm)
gap       = 6;    // gap between crests (mm)
corner_gap= 1.8;  // solid left uncut at each vertex (mm; 60° corners need >=1.8)

hgt = tri * sqrt(3) / 2;
r = groove_w / 2;

module seg(p1, p2) { corner_seg(p1, p2, r, corner_gap); }

module up_tri(x0, y0) {
    V = [[x0, y0], [x0+tri, y0], [x0+tri/2, y0+hgt]];
    seg(V[0], V[1]); seg(V[1], V[2]); seg(V[2], V[0]);
}

// Three triangles forming a larger triangle (they touch at the big edge midpoints).
module crest(gx, gy) {
    up_tri(gx, gy);
    up_tri(gx + tri, gy);
    up_tri(gx + tri/2, gy + hgt);
}

px = 2*tri + gap;
py = 2*hgt + gap;

sashiko_plate(plate_w, plate_h, plate_t, border, chamfer, reg)
union()
    for (j = [-1 : ceil(plate_h / py) + 1])
        for (i = [-1 : ceil(plate_w / px) + 1])
            crest(i*px + (j % 2)*(px/2), j*py);
