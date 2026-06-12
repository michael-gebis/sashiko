// Description: **Tumbling Blocks** — Isometric Cubes
// Tumbling Blocks / Rhombille (Isometric Cubes) Sashiko Template
// The kikko honeycomb with each hexagon split by a Y into three rhombi — the
// three visible faces of a cube. Hexagon edges and the three spokes are all
// corner-gapped (at the vertices and at the hexagon centre), so every rhombus
// stays attached.

use <sashiko_lib.scad>
include <sashiko_config.scad>

hex_r     = 14;   // hexagon circumradius (= cube size) — pattern scale (mm)
corner_gap= 1.8;  // solid left uncut at vertices and the hex centre (mm; the Y
                  // meets the rim at 60°, and 60° corners need >=1.8)

col_sp = hex_r * sqrt(3);
row_sp = hex_r * 1.5;
r = groove_w / 2;

module seg(p1, p2) { corner_seg(p1, p2, r, corner_gap); }

module cube(cx, cy) {
    V = [for (i = [0:5]) [cx + hex_r*cos(90 + 60*i), cy + hex_r*sin(90 + 60*i)]];
    for (i = [0:5]) seg(V[i], V[(i+1)%6]);          // hexagon outline
    for (i = [0:2]) seg([cx, cy], V[2*i]);          // Y to alternating vertices
}

n_cols = ceil(plate_w / col_sp) + 3;
n_rows = ceil(plate_h / row_sp) + 3;

sashiko_plate(plate_w, plate_h, plate_t, border, chamfer, reg)
union()
    for (row = [0 : n_rows]) {
        row_off = (row % 2) * (col_sp / 2);
        for (col = [0 : n_cols])
            cube((col - 1)*col_sp + row_off, (row - 1)*row_sp);
    }
