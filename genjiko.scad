// Description: **Genjikō** — Genji Incense Symbols (源氏香)
// Genjikō (Genji Incense Symbols / 源氏香) Sashiko Template
// Each motif is five vertical bars with horizontal links across the top joining
// some of them (the incense-comparison symbols from The Tale of Genji). A few
// different symbols are tiled. All open "combs", so nothing is enclosed.

use <sashiko_lib.scad>
include <sashiko_config.scad>

bar_h     = 15;   // bar height — pattern scale (mm)
bar_sp    = 4;    // spacing between the five bars (mm)
gap       = 8;    // gap between motifs (mm)

r = groove_w / 2;
px = 4*bar_sp + gap;
py = bar_h + gap;

// Symbols: each is a list of groups; each group lists the (adjacent) bars its top
// link joins. Bars not in any multi-group stand alone.
symbols = [ [[0,1],[2,3,4]], [[0,1,2],[3,4]], [[0,1,2,3,4]], [[0,1],[2,3]] ];

module genji(ox, oy, sym) {
    for (k = [0:4]) slot_dash([ox + k*bar_sp, oy], [ox + k*bar_sp, oy + bar_h], r);
    for (g = sym)
        for (t = [0 : len(g)-2])
            slot_dash([ox + g[t]*bar_sp, oy + bar_h], [ox + g[t+1]*bar_sp, oy + bar_h], r);
}

sashiko_plate(plate_w, plate_h, plate_t, border, chamfer, reg)
union()
    for (i = [0 : ceil(plate_w / px) + 1])
        for (j = [0 : ceil(plate_h / py) + 1])
            genji(i*px, j*py, symbols[(i + 2*j) % len(symbols)]);
