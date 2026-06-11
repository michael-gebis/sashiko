// Description: **Matsukawabishi** — Pine-bark Diamond (松皮菱)
// Matsukawabishi (Pine-bark Diamond / 松皮菱) Sashiko Template
// The hishi diamond lattice (lozenges edge-to-edge) with a smaller lozenge drawn
// concentrically inside each, giving the layered "pine-bark" look. Both rings use
// the corner-gap trick so the whole plate stays one piece.

use <sashiko_lib.scad>
include <sashiko_config.scad>

dia_w     = 18;   // large diamond full width (mm)
dia_h     = 26;   // large diamond full height (mm)
small_frac= 0.5;  // small diamond size as a fraction of the large — pattern scale
corner_gap= 1.4;  // solid left uncut at each diamond corner (mm)

aL = dia_w / 2;  bL = dia_h / 2;          // large half-diagonals
aS = aL * small_frac;  bS = bL * small_frac;   // small half-diagonals
r = groove_w / 2;

module seg(p1, p2) { corner_seg(p1, p2, r, corner_gap); }

module diamond(cx, cy, a, b) {
    seg([cx, cy+b], [cx+a, cy]); seg([cx+a, cy], [cx, cy-b]);
    seg([cx, cy-b], [cx-a, cy]); seg([cx-a, cy], [cx, cy+b]);
}

n_i = ceil(plate_w / aL) + 2;
n_j = ceil(plate_h / bL) + 2;

sashiko_plate(plate_w, plate_h, plate_t, border, chamfer, reg)
union()
    for (i = [-1 : n_i])
        for (j = [-1 : n_j])
            if ((i + j) % 2 == 0) {
                diamond(i*aL, j*bL, aL, bL);   // outer lozenge (fills the lattice)
                diamond(i*aL, j*bL, aS, bS);   // inner lozenge (the bark layer)
            }
