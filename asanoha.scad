// Description: **Asanoha** — Hemp Leaf (麻の葉)
// Asanoha (Hemp Leaf / 麻の葉) Sashiko Template
// Flat plate; pattern cut full-thickness with bridges so it stays in one piece.

use <sashiko_lib.scad>
include <sashiko_config.scad>

hex_r     = 12;    // hexagon circumradius — pattern scale (mm)
bridge_w  = 1.4;   // solid tab left in each slot (mm; ~1.2 min for strength)
bridge_sp = 14;    // target spacing between bridges on long runs (mm)

col_sp = hex_r * sqrt(3);
row_sp = hex_r * 1.5;

r = groove_w / 2;

// one straight slot (2D), auto-bridged
module seg(p1, p2) bridged_line(p1, p2, r, bridge_w, bridge_sp);

// Asanoha unit: a hexagon split into 6 equilateral triangles; in each triangle
// the three corners (centre + two vertices) join to its centroid. The spoke is
// each leaf's mid-rib, the centre->centroid lines divide adjacent leaves, and
// the vertex->centroid lines form the leaf sides.
module asanoha_cell(cx, cy) {
    C = [cx, cy];
    V = [for (i = [0:5]) [cx + hex_r*cos(90 + 60*i),
                          cy + hex_r*sin(90 + 60*i)]];
    for (i = [0:5]) {
        A = V[i];
        B = V[(i + 1) % 6];
        G = [(C[0] + A[0] + B[0]) / 3, (C[1] + A[1] + B[1]) / 3]; // centroid
        seg(C, A);   // spoke / leaf mid-rib
        seg(A, B);   // hexagon edge
        seg(C, G);   // centre  -> centroid (boundary between two leaves)
        seg(A, G);   // vertex  -> centroid (leaf side)
        seg(B, G);   // vertex  -> centroid (leaf side)
    }
}

n_cols = ceil(plate_w / col_sp) + 3;
n_rows = ceil(plate_h / row_sp) + 3;

sashiko_plate(plate_w, plate_h, plate_t, border, chamfer)
    for (row = [0 : n_rows]) {
        row_off = (row % 2) * (col_sp / 2);
        for (col = [0 : n_cols])
            asanoha_cell((col - 1)*col_sp + row_off, (row - 1)*row_sp);
    }
