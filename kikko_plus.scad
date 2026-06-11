// Description: **Kikkō Plus** — Tortoise Shell + plus (亀甲)
// Kikkō Plus — Tortoise Shell (亀甲) with a small plus in each cell.
// Hexagon honeycomb (see kikko.scad) plus a "+" centred in every hexagon.

use <sashiko_lib.scad>
include <sashiko_config.scad>

hex_r     = 13;   // hexagon circumradius — pattern scale (mm)
corner_gap= 1.5;  // solid left uncut at each hex vertex (mm)
plus_frac = 0.25; // plus span as a fraction of hex width (flat-to-flat)

col_sp = hex_r * sqrt(3);          // pointy-top honeycomb spacing
row_sp = hex_r * 1.5;
r = groove_w / 2;
plus_arm = plus_frac * (hex_r * sqrt(3)) / 2;   // half-length of each plus arm

// One hex edge, drawn short of both ends (3 hexagons meet per vertex, so the
// solid vertex joins them while the outline stays continuous).
module seg(p1, p2) { corner_seg(p1, p2, r, corner_gap); }

module hexagon(cx, cy) { hex_outline([cx, cy], hex_r, r, corner_gap); }

// A "+" centred at (cx,cy). Two crossing open segments enclose nothing, so no
// bridges are needed and the cell stays connected around the arm tips.
module plus(cx, cy) {
    slot_dash([cx - plus_arm, cy], [cx + plus_arm, cy], r);  // horizontal
    slot_dash([cx, cy - plus_arm], [cx, cy + plus_arm], r);  // vertical
}

n_cols = ceil(plate_w / col_sp) + 3;
n_rows = ceil(plate_h / row_sp) + 3;

sashiko_plate(plate_w, plate_h, plate_t, border, chamfer, reg)
    for (row = [0 : n_rows]) {
        row_off = (row % 2) * (col_sp / 2);
        for (col = [0 : n_cols]) {
            cx = (col - 1)*col_sp + row_off;
            cy = (row - 1)*row_sp;
            hexagon(cx, cy);
            plus(cx, cy);
        }
    }
