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

// Straight slot p1->p2 pulled in by `gap` at each end, leaving a solid corner of
// width ~gap where several meet (the corner-gap trick used by the polygon
// tilings — hishi, kikko, masu, …).
module corner_seg(p1, p2, r, gap) {
    L = norm([p2[0]-p1[0], p2[1]-p1[1]]);
    d = [(p2[0]-p1[0])/L, (p2[1]-p1[1])/L];
    if (L > 2*gap + 0.1)
        slot_dash([p1[0]+d[0]*gap, p1[1]+d[1]*gap],
                  [p2[0]-d[0]*gap, p2[1]-d[1]*gap], r);
}

// Regular hexagon outline of corner-gapped edges. a0 = first-vertex angle:
// 90 = pointy-top (default), 0 = flat-top.
module hex_outline(c, R, r, gap, a0 = 90) {
    V = [for (i = [0:5]) [c[0] + R*cos(a0 + 60*i), c[1] + R*sin(a0 + 60*i)]];
    for (i = [0:5]) corner_seg(V[i], V[(i+1) % 6], r, gap);
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
//
// reg (off by default) cuts a datum hole at each corner of the pattern window.
// Mark those four dots, then reposition the plate so its leading holes sit on the
// previous placement's dots: that steps the plate by exactly the window size
// (w-2*border, h-2*border) and butts the patterns at the boundary — seamless when
// the pattern's repeat divides that pitch.
module sashiko_plate(w, h, t, border, chamfer = 0, reg = false, reg_d = 1.5, eps = 0.1) {
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
        if (reg)
            translate([0, 0, -eps])
            linear_extrude(t + 2*eps)
            for (x = [border, w - border], y = [border, h - border])
                translate([x, y]) circle(r = reg_d/2, $fn = 24);
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
