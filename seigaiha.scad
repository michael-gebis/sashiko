// Description: **Seigaiha** — Blue Sea Waves (青海波)
// Seigaiha (Blue Sea Waves / 青海波) Sashiko Template
// Overlapping concentric arcs (fish-scale waves), cut full-thickness.

use <sashiko_lib.scad>
include <sashiko_config.scad>

R         = 14;   // outer radius of a scale (mm)
n_arcs    = 3;    // concentric arcs per scale
bridge_sp = 16;   // target spacing between bridges along an arc (mm)

// Scales sit edge-to-edge in a row (col_pitch = 2R) and each row nests a half-
// scale into the row below (offset R, rising by R). This keeps overlaps to the
// row-to-row crossings only — dense same-row overlap (col_pitch = R) instead
// encloses hundreds of tiny background cells that won't stay attached.
col_pitch = 2 * R;    // horizontal centre spacing
row_pitch = R;        // vertical centre spacing

r = groove_w / 2;

// One scale = n_arcs concentric upper semicircles (0..180 deg).
module scale(cx, cy) {
    for (k = [1 : n_arcs])
        bridged_arc([cx, cy], R * k / n_arcs, r, 0, 180, bridge_w, bridge_sp);
}

n_cols = ceil(plate_w / col_pitch) + 3;
n_rows = ceil(plate_h / row_pitch) + 3;

sashiko_plate(plate_w, plate_h, plate_t, border, chamfer, reg)
    for (row = [0 : n_rows])
        for (col = [0 : n_cols])
            scale((col - 1)*col_pitch + (row % 2)*(col_pitch/2),
                  (row - 1)*row_pitch);
