// Description: **Kagome** — Woven Basket (籠目)
// Kagome (Woven Basket / 籠目) Sashiko Template
// Trihexagonal lattice: flat-top hexagons that touch corner-to-corner, with the
// triangular gaps between them forming the other half of the weave. Cut
// full-thickness.

use <sashiko_lib.scad>
include <sashiko_config.scad>

hex_r     = 11;   // hexagon circumradius = triangle edge — pattern scale (mm)
corner_gap= 1.5;  // solid left uncut at each lattice vertex (mm)

c      = 2 * hex_r;          // hex centres touch corner-to-corner at 2*circumradius
row_sp = c * sqrt(3) / 2;    // triangular lattice of hex centres
r = groove_w / 2;

// One edge, drawn short of both ends. Two hexagons (and two triangles) meet at
// every lattice vertex, so leaving the vertices solid joins them while the
// woven outlines stay continuous. Only the hexagons are drawn — each triangular
// gap is bounded by one edge from each of its three neighbouring hexagons.
module seg(p1, p2) { corner_seg(p1, p2, r, corner_gap); }

// Flat-top hexagon (vertices at 0,60,...,300) so its left/right corners point
// straight at the neighbouring hexagons.
module hexagon(cx, cy) { hex_outline([cx, cy], hex_r, r, corner_gap, 0); }

n_cols = ceil(plate_w / c) + 3;
n_rows = ceil(plate_h / row_sp) + 3;

sashiko_plate(plate_w, plate_h, plate_t, border, chamfer, reg)
    for (row = [0 : n_rows]) {
        row_off = (row % 2) * (c / 2);
        for (col = [0 : n_cols])
            hexagon((col - 1)*c + row_off, (row - 1)*row_sp);
    }
