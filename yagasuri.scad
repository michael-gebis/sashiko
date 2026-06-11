// Description: **Yagasuri** — Arrow Feathers (矢絣)
// Yagasuri (Arrow Feathers / 矢絣) Sashiko Template
// The arrow-feather kasuri: columns of stacked chevrons (fletching), neighbouring
// columns offset by half so the feathers interlock — fuller than yabane, with no
// shaft. Open chevrons, so no bridges.

use <sashiko_lib.scad>
include <sashiko_config.scad>

col_w     = 16;   // feather (column) width — pattern scale (mm)
feather_sp= 9;    // vertical spacing of the chevrons (mm)
rise      = 7;    // chevron height (mm)

r = groove_w / 2;

// One column of up-pointing chevrons at centre x = cx, offset vertically by yoff.
module feathers(cx, yoff) {
    n = ceil(plate_h / feather_sp) + 2;
    for (k = [-1 : n]) {
        y = k*feather_sp + yoff;
        slot_dash([cx - col_w/2, y], [cx, y + rise], r);   // left barb
        slot_dash([cx, y + rise], [cx + col_w/2, y], r);   // right barb
    }
}

sashiko_plate(plate_w, plate_h, plate_t, border, chamfer, reg)
union()
    for (c = [0 : ceil(plate_w / col_w) + 1])
        feathers(c * col_w, (c % 2) * (feather_sp/2));
