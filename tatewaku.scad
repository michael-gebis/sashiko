// Description: **Tatewaku** — Rising Steam (立涌)
// Tatewaku (Rising Steam / 立涌) Sashiko Template
// Vertical wavy lines, anti-phase between neighbours, so the band between each
// pair swells (the steam pillar) and pinches. The lines run the full height as
// open curves — nothing is enclosed, so no bridges are needed.

use <sashiko_lib.scad>
include <sashiko_config.scad>

col_sp    = 18;   // line-to-line spacing — pattern scale (mm)
amp       = 5;    // wave amplitude (mm); pinch gap = col_sp - 2*amp
period    = 28;   // vertical wavelength (mm)

r = groove_w / 2;

// One vertical wavy line at base x = cx; sgn (+/-1) sets the phase.
module wave(cx, sgn) {
    dy = period / 16;
    n  = ceil((plate_h + 2*period) / dy);
    pts = [for (k = [0 : n]) let (y = -period + k*dy)
              [cx + sgn * amp * sin(360 * y / period), y]];
    for (k = [0 : len(pts)-2]) slot_dash(pts[k], pts[k+1], r);
}

sashiko_plate(plate_w, plate_h, plate_t, border, chamfer, reg)
    for (c = [0 : ceil(plate_w / col_sp) + 1])
        wave(c * col_sp, (c % 2 == 0) ? 1 : -1);
