// sashiko_lib.scad
// Shared geometry helpers for sashiko stitch-guide templates.
//
// The slot pattern is built entirely in 2D and extruded ONCE at the end (see
// sashiko_plate). This is far faster than unioning thousands of 3D solids.
//
// Slots are cut FULL-THICKNESS so a marking pen/chalk reaches the fabric, and
// are interrupted by small solid "bridges" so the enclosed regions of a
// continuous-line pattern stay attached to the plate instead of dropping out.

// --- low level (2D) -------------------------------------------------------

// 2D rounded slot dash (a "stadium") between two points.
module slot_dash(p1, p2, r) {
    hull() {
        translate(p1) circle(r = r, $fn = 8);
        translate(p2) circle(r = r, $fn = 8);
    }
}

// --- straight slot with periodic bridges ---------------------------------

// Straight slot p1->p2. Always leaves >=1 bridge (so the faces on either side
// stay connected); long runs get extra bridges at ~bridge_sp spacing.
// Dash ends are pulled in by the cap radius r so the *solid* tab left behind
// is bridge_w wide (not bridge_w - 2r).
module bridged_line(p1, p2, r, bridge_w, bridge_sp) {
    L = norm([p2[0] - p1[0], p2[1] - p1[1]]);
    if (L > 0.001) {
        dir = [(p2[0] - p1[0]) / L, (p2[1] - p1[1]) / L];
        hw  = bridge_w / 2 + r;                  // half-gap incl. cap radius
        nb  = max(1, floor(L / bridge_sp));      // bridge count
        cuts   = [for (k = [1 : nb]) k * L / (nb + 1)];
        bounds = concat([0],
                        [for (c = cuts) each [c - hw, c + hw]],
                        [L]);
        for (i = [0 : len(bounds)/2 - 1]) {
            a = bounds[2*i];
            b = bounds[2*i + 1];
            if (b - a > 0.05)
                slot_dash([p1[0] + dir[0]*a, p1[1] + dir[1]*a],
                          [p1[0] + dir[0]*b, p1[1] + dir[1]*b], r);
        }
    }
}

// --- circular slot with bridges at given angles --------------------------

// Smooth thick arc from angle a1 to a2 (degrees) on circle (centre c, radius R).
module arc_run(c, R, r, a1, a2) {
    span  = a2 - a1;
    steps = max(1, ceil(abs(span) / 6));
    for (i = [0 : steps - 1]) {
        t1 = a1 + span * i       / steps;
        t2 = a1 + span * (i + 1) / steps;
        slot_dash([c[0] + R*cos(t1), c[1] + R*sin(t1)],
                  [c[0] + R*cos(t2), c[1] + R*sin(t2)], r);
    }
}

// Open arc slot (a1->a2 degrees) with periodic bridges along its length.
// Unlike bridged_line it allows zero bridges on short arcs (an open arc does
// not enclose a region on its own).
module bridged_arc(c, R, r, a1, a2, bridge_w, bridge_sp) {
    L  = R * abs(a2 - a1) * PI / 180;
    nb = floor(L / bridge_sp);
    ha = (bridge_w / 2 + r) / R * 180 / PI;      // half gap in degrees
    cuts   = nb < 1 ? [] : [for (k = [1 : nb]) a1 + (a2 - a1) * k / (nb + 1)];
    bounds = concat([a1], [for (cg = cuts) each [cg - ha, cg + ha]], [a2]);
    for (i = [0 : len(bounds)/2 - 1]) {
        b1 = bounds[2*i];
        b2 = bounds[2*i + 1];
        if (b2 - b1 > 0.1) arc_run(c, R, r, b1, b2);
    }
}

// Full circle slot, broken by a bridge centred on each angle in bridge_angles.
module bridged_circle(c, R, r, bridge_w, bridge_angles) {
    half = (bridge_w / 2 + r) / R * 180 / PI;   // half gap (deg), incl. caps
    n = len(bridge_angles);
    for (k = [0 : n - 1]) {
        a1 = bridge_angles[k];
        a2 = bridge_angles[(k + 1) % n] + (k == n - 1 ? 360 : 0);
        arc_run(c, R, r, a1 + half, a2 - half);
    }
}

// --- plate assembly -------------------------------------------------------

// Solid plate with the 2D pattern (children) cut through it, clipped to an
// inner border. The pattern is intersected with the inner rectangle and
// extruded a single time for speed.
//
// chamfer (mm, 0 = off) bevels the four OUTER top edges at 45°. It only touches
// the solid border (border > chamfer), never the slots, which are still cut
// full-thickness afterwards. Keep chamfer < t (ideally <= t/2).
module sashiko_plate(w, h, t, border, chamfer = 0, eps = 0.1) {
    difference() {
        if (chamfer > 0) chamfered_box(w, h, t, chamfer);
        else             cube([w, h, t]);
        translate([0, 0, -eps])
        linear_extrude(t + 2*eps)
        intersection() {
            translate([border, border])
                square([w - 2*border, h - 2*border]);
            children();
        }
    }
}

// A box whose four top outer edges are chamfered at 45° (c tall, c wide): full
// box up to t-c, then a frustum that insets by c over the last c of height.
module chamfered_box(w, h, t, c) {
    union() {
        cube([w, h, t - c]);
        hull() {
            translate([0, 0, t - c]) linear_extrude(0.01) square([w, h]);
            translate([c, c, t - 0.01]) linear_extrude(0.01) square([w - 2*c, h - 2*c]);
        }
    }
}
