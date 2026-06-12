// Description: **Ōgi-tsunagi** — Linked Fans (扇つなぎ)
// Ōgi-tsunagi (Linked Fans / 扇つなぎ) Sashiko Template
// Folding fans in offset rows: an outer arc, a small pivot arc, two radial
// edges and three ribs. The outline is corner-gapped at all four arc/edge
// junctions and the ribs float clear of both arcs (cf. genjiguruma: a rib tip
// landing on an arc break leaves only hairline straps), so nothing is enclosed
// and no bridges are needed.

use <sashiko_lib.scad>
include <sashiko_config.scad>

Ro    = 13;    // outer arc radius — pattern scale (mm)
Ri    = 3.8;   // pivot arc radius (mm)
a0    = 20;    // fan edge angle above horizontal (deg); fan spans 180 - 2*a0
gap   = 1.4;   // solid corner left at each arc/edge junction (mm)
clear = 2;     // rib clearance from each arc (mm)
px    = 27;    // fan-to-fan spacing along a row (mm)
py    = 16;    // row spacing (mm)

r = groove_w / 2;
to  = gap / Ro * 180 / PI;   // outer-arc corner trim (deg)
ti  = gap / Ri * 180 / PI;   // pivot-arc corner trim (deg)

module fan(cx, cy) {
    arc_run([cx, cy], Ro, r, a0 + to, 180 - a0 - to);          // outer arc
    arc_run([cx, cy], Ri, r, a0 + ti, 180 - a0 - ti);          // pivot arc
    for (a = [a0, 180 - a0])                                   // the two edges
        corner_seg([cx + Ri*cos(a), cy + Ri*sin(a)],
                   [cx + Ro*cos(a), cy + Ro*sin(a)], r, gap);
    for (a = [55, 90, 125])                                    // floating ribs
        slot_dash([cx + (Ri + clear)*cos(a), cy + (Ri + clear)*sin(a)],
                  [cx + (Ro - clear)*cos(a), cy + (Ro - clear)*sin(a)], r);
}

n_x = ceil(plate_w / px) + 1;
n_y = ceil(plate_h / py) + 1;

sashiko_plate(plate_w, plate_h, plate_t, border, chamfer, reg)
union()
    for (j = [-1 : n_y])
        for (i = [-1 : n_x])
            fan(i*px + (j % 2)*(px/2), j*py);
