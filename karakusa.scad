// Description: **Karakusa** — Arabesque Vines (唐草)
// Karakusa (Arabesque Vines / 唐草) Sashiko Template
// Scrolling vines: rows of a sinuous wave with a spiral tendril curling off each
// crest, alternating up/down. Every stroke is an open curve (the spirals never
// close), so nothing is enclosed and no bridges are needed.

use <sashiko_lib.scad>
include <sashiko_config.scad>

period    = 26;   // horizontal wavelength — pattern scale (mm)
amp       = 6;    // wave amplitude (mm)
row_sp    = 17;   // vertical spacing between vine rows (mm)
curl_r    = 4;    // tendril spiral radius (mm)

r = groove_w / 2;

// An open spiral tendril (one turn) centred at (cx,cy). A monotonic spiral never
// self-crosses, so it encloses nothing as long as it doesn't cross the vine —
// hence it is placed clear of the wave (see vine()).
module curl(cx, cy, dir) {
    N = 16;
    pts = [for (k = [0:N]) let (t = k/N, ang = 90 + dir*t*360, rad = 0.6 + t*curl_r)
              [cx + rad*cos(ang), cy + rad*sin(ang)]];
    for (k = [0:N-1]) slot_dash(pts[k], pts[k+1], r);
}

// One vine row: a sine wave across the plate with a tendril at each crest/trough.
module vine(y0) {
    dx = period/16;
    n  = ceil(plate_w / dx) + 2;
    pts = [for (k = [0:n]) let (xx = k*dx) [xx, y0 + amp*sin(360*xx/period)]];
    for (k = [0 : len(pts)-2]) slot_dash(pts[k], pts[k+1], r);
    // tendrils at the crests (sin = +/-1), every half period
    m = ceil(plate_w / (period/2)) + 1;
    for (k = [-1 : m]) {
        cx = k*(period/2) + period/4;
        up = (k % 2 == 0) ? 1 : -1;
        curl(cx, y0 + up*(amp + curl_r + 0.8), up);   // sit the tendril clear of the wave
    }
}

sashiko_plate(plate_w, plate_h, plate_t, border, chamfer, reg)
union()
    for (row = [0 : ceil(plate_h / row_sp) + 1])
        vine(row * row_sp);
