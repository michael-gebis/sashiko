// Description: **Yabane** — Arrow Feathers (矢羽根)
// Yabane (Arrow Feathers / 矢羽根) Sashiko Template
// Columns of fletching: a vertical shaft with a chevron of barbs rising from it
// at regular intervals. Shaft + barbs are open segments (nothing enclosed), so
// no bridges are needed.

use <sashiko_lib.scad>
include <sashiko_config.scad>

col_sp    = 12;   // shaft-to-shaft spacing — pattern scale (mm)
barb_sp   = 11;   // vertical spacing of barbs along a shaft (mm)
barb_w    = 5;    // barb horizontal reach (mm; keep < col_sp/2 so columns stay apart)
barb_h    = 6;    // barb vertical rise (mm)

r = groove_w / 2;

// One feather column at x = cx, barbs rising (chevron points up).
module feather(cx) {
    slot_dash([cx, -barb_sp], [cx, plate_h + barb_sp], r);          // shaft
    for (k = [-1 : ceil(plate_h / barb_sp) + 1]) {
        y = k * barb_sp;
        slot_dash([cx, y], [cx - barb_w, y + barb_h], r);           // up-left barb
        slot_dash([cx, y], [cx + barb_w, y + barb_h], r);           // up-right barb
    }
}

sashiko_plate(plate_w, plate_h, plate_t, border, chamfer, reg)
    for (c = [0 : ceil(plate_w / col_sp)])
        feather(c * col_sp);
