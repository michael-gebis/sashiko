// Description: **Mitsudomoe** — Triple Swirl (三つ巴)
// Mitsudomoe (Triple Swirl / 三つ巴) Sashiko Template
// Three comma "tomoe" swirls pinwheeling inside a ring, on a grid. Each swirl is
// an open spiral line (encloses nothing); the ring is bridged so the disc stays
// attached.

use <sashiko_lib.scad>
include <sashiko_config.scad>

spacing   = 26;   // motif-to-motif spacing — pattern scale (mm)
R         = 11;   // ring radius (mm)
hub       = 1.8;  // swirl start radius near the centre (mm)
rim_gap   = 2.2;  // gap between swirl end and the ring (mm)
sweep     = 210;  // how far each swirl winds (deg)
bridge_w  = 1.4;  // solid tab in the ring (mm)

r = groove_w / 2;

// One comma swirl: an Archimedean spiral arc from the hub outward.
module comma(cx, cy, phi) {
    N = 16;
    pts = [for (k = [0:N]) let (t = k/N, ang = phi + t*sweep,
                                rad = hub + t*(R - rim_gap - hub))
              [cx + rad*cos(ang), cy + rad*sin(ang)]];
    for (k = [0:N-1]) slot_dash(pts[k], pts[k+1], r);
}

module domoe(cx, cy) {
    bridged_circle([cx, cy], R, r, bridge_w, [60, 180, 300]);
    for (k = [0:2]) comma(cx, cy, 120*k);
}

n_x = ceil(plate_w / spacing) + 1;
n_y = ceil(plate_h / spacing) + 1;

sashiko_plate(plate_w, plate_h, plate_t, border, chamfer)
union()
    for (i = [0 : n_x])
        for (j = [0 : n_y])
            domoe(i*spacing, j*spacing);
