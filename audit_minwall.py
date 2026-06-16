#!/usr/bin/env python3
"""Min-wall audit: measure each template's thinnest solid features from a
full-plate top-down render.

The plates are uniform extrusions, so a top-down orthographic PNG *is* the 2D
solid geometry, already rasterized: background-coloured pixels are cuts (or
outside the plate), everything else is solid. We segment that mask, calibrate
mm/px from the plate's known 120 mm footprint, and report two widths:

* **min wall** — the smallest w whose morphological opening (erode + dilate by
  a disc of radius w/2) removes a significant piece of solid: a wall, neck, or
  wedge thinner than w *and too far from thicker bulk to be supported by it*.
  Plain 90-degree corners shed only ~0.21*(w/2)^2 under opening, so an area
  filter of area_factor*(w/2)^2 separates real thin features from corner
  rounding.
* **min link** — the smallest w whose *erosion alone* (by w/2) splits the
  solid into more than one piece: the width of the thinnest load-bearing
  connection. This catches short necks that min wall deliberately treats as
  supported — e.g. a slot cap landing on a bridge tab and leaving hairline
  straps. For a healthy bridged pattern this is roughly the bridge width.

`Volumes: 2` (make verify) proves the plate is one connected solid; this audit
covers the other half of printability: nothing in that solid is too thin, and
nothing hangs on a hairline.

Accuracy is pixel-bound: about +/-2 px (~+/-0.1 mm at the 2000 px audit
renders). Render larger for finer numbers. Reported coordinates are plate mm,
origin at the plate's bottom-left corner; `link@(x,y)` marks the first piece
to detach.

Needs numpy and ImageMagick's `convert` (both already build dependencies).

Usage:
  python3 audit_minwall.py build/audit/*.png              # report, worst first
  python3 audit_minwall.py ... --json build/minwall.json
  python3 audit_minwall.py ... --check minwall_baseline.json   # CI gate
  python3 audit_minwall.py ... --write-baseline minwall_baseline.json
"""
import argparse
import json
import math
import os
import subprocess
import sys

import numpy as np

PLATE_MM = 120.0          # plate footprint (must match plate_w/h in sashiko_config.scad)
BG_DIST = 60              # min L1 RGB distance from background to count as solid
MIN_AREA_PX = 4.0         # ignore removed blobs smaller than this (AA specks)
MIN_PIECE_PX = 25         # ignore detached crumbs smaller than this (erosion litter)


def read_solid_mask(path):
    """PNG -> bool array, True where solid plate. ImageMagick does the decode."""
    ppm = subprocess.run(["convert", path, "ppm:-"],
                         capture_output=True, check=True).stdout
    if ppm[:2] != b"P6":
        raise ValueError(f"{path}: expected P6 ppm from convert")
    # header = magic, width, height, maxval; '#' comments allowed
    vals, pos = [], 2
    while len(vals) < 3:
        while ppm[pos] in b" \t\r\n":
            pos += 1
        if ppm[pos:pos + 1] == b"#":
            pos = ppm.index(b"\n", pos) + 1
            continue
        end = pos
        while ppm[end] not in b" \t\r\n":
            end += 1
        vals.append(int(ppm[pos:end]))
        pos = end
    pos += 1                                   # single whitespace before data
    w, h, maxval = vals
    if maxval != 255:
        raise ValueError(f"{path}: unsupported maxval {maxval}")
    img = np.frombuffer(ppm, np.uint8, count=w * h * 3, offset=pos)
    img = img.reshape(h, w, 3).astype(np.int16)
    c = 8                                      # corners are outside the plate
    corners = np.concatenate([img[:c, :c], img[:c, -c:],
                              img[-c:, :c], img[-c:, -c:]], axis=0)
    bg = np.median(corners.reshape(-1, 3), axis=0)
    return np.abs(img - bg).sum(axis=2) > BG_DIST


def disc(rpx):
    R = int(math.ceil(rpx))
    yy, xx = np.mgrid[-R:R + 1, -R:R + 1]
    return (xx * xx + yy * yy <= rpx * rpx + 1e-9).astype(np.float64)


def conv2(mask, K):
    """Same-size 2D convolution via FFT (counts of True under the kernel)."""
    H, W = mask.shape
    kh, kw = K.shape
    fh, fw = H + kh - 1, W + kw - 1
    F = np.fft.rfft2(mask.astype(np.float64), (fh, fw)) * np.fft.rfft2(K, (fh, fw))
    out = np.fft.irfft2(F, (fh, fw))
    return out[kh // 2:kh // 2 + H, kw // 2:kw // 2 + W]


def erode(mask, rpx):
    K = disc(rpx)
    return conv2(mask, K) > K.sum() - 0.5


def components(mask, min_px):
    """8-connected components via row-run union-find.
    Returns [(size_px, centroid_row, centroid_col), ...] largest first."""
    parent, size, sum_r, sum_c = [], [], [], []

    def find(a):
        while parent[a] != a:
            parent[a] = parent[parent[a]]
            a = parent[a]
        return a

    prev = []                                  # [(s, e, root), ...] sorted
    for rno, row in enumerate(mask):
        idx = np.flatnonzero(np.diff(np.concatenate(
            ([0], row.view(np.int8), [0]))))
        runs = []
        j = 0
        for s, e in zip(idx[::2].tolist(), idx[1::2].tolist()):
            rid = len(parent)
            parent.append(rid)
            size.append(e - s)
            sum_r.append(rno * (e - s))
            sum_c.append((s + e - 1) * (e - s) / 2)
            while j and prev[j - 1][1] >= s:   # rewind: prior run may also touch
                j -= 1
            while j < len(prev) and prev[j][0] <= e:   # 8-conn: ps <= e, s <= pe
                if prev[j][1] >= s:
                    ra, rb = find(rid), find(prev[j][2])
                    if ra != rb:
                        parent[ra] = rb
                        size[rb] += size[ra]
                        sum_r[rb] += sum_r[ra]
                        sum_c[rb] += sum_c[ra]
                j += 1
            runs.append((s, e, rid))
        prev, j = runs, 0
    roots = {}
    for rid in range(len(parent)):
        if find(rid) == rid and size[rid] >= min_px:
            roots[rid] = (size[rid], sum_r[rid] / size[rid], sum_c[rid] / size[rid])
    return sorted(roots.values(), reverse=True)


def thin_parts(solid, w_px, area_factor):
    """Solid pixels removed by opening with a disc of radius w_px/2, as
    components above the significance threshold. Largest first."""
    rpx = w_px / 2.0
    eroded = erode(solid, rpx)
    opened = conv2(eroded, disc(rpx)) > 0.5
    removed = solid & ~opened
    min_area = max(area_factor * rpx * rpx, MIN_AREA_PX)
    return components(removed, min_area)


def bsearch(w_min, w_max, px, probe):
    """Smallest w in [w_min, w_max] where probe(w) is truthy, to 1 px.
    -> (w, bound, probe_result)."""
    hi_res = probe(w_max)
    if not hi_res:
        return w_max, "ge", []
    lo_res = probe(w_min)
    if lo_res:
        return w_min, "le", lo_res
    lo, hi = w_min, w_max
    while hi - lo > px:
        mid = (lo + hi) / 2
        res = probe(mid)
        if res:
            hi, hi_res = mid, res
        else:
            lo = mid
    return hi, "exact", hi_res


def audit(path, w_max, area_factor):
    solid = read_solid_mask(path)
    rows = np.flatnonzero(solid.any(axis=1))
    cols = np.flatnonzero(solid.any(axis=0))
    r0, r1, c0, c1 = rows[0], rows[-1], cols[0], cols[-1]
    px = PLATE_MM / ((c1 - c0 + r1 - r0) / 2 + 1)   # mm per pixel
    pad = int(math.ceil(w_max / 2 / px)) + 2
    sub = solid[max(r0 - pad, 0):r1 + pad + 1, max(c0 - pad, 0):c1 + pad + 1]
    sr0, sc0 = max(r0 - pad, 0), max(c0 - pad, 0)

    def to_mm(comps, n):
        # image row 0 is the plate's top edge (+y), so flip y
        return [[round((sc0 + cc - c0) * px, 1), round((r1 - (sr0 + cr)) * px, 1)]
                for _, cr, cc in comps[:n]]

    w_min = max(2 * px, 0.1)                        # below ~2 px is unmeasurable

    wall, bound, parts = bsearch(
        w_min, w_max, px, lambda w: thin_parts(sub, w / px, area_factor))

    def splits(w):
        comps = components(erode(sub, w / 2 / px), MIN_PIECE_PX)
        return comps[1:] if len(comps) > 1 else []   # detached pieces, if any

    base = components(sub, MIN_PIECE_PX)
    if len(base) > 1:                       # detached before any erosion: a
        link, lbound, islands = 0.0, "le", base[1:]  # sub-pixel connection
    else:
        link, lbound, islands = bsearch(w_min, w_max, px, splits)

    return {"min_wall_mm": round(wall, 2), "bound": bound,
            "spots": to_mm(parts, 2),
            "min_link_mm": round(link, 2), "link_bound": lbound,
            "link_spot": to_mm(islands, 1)}


def fmt(value, bound):
    v = f"{value:.2f}"
    return {"le": "<= " + v, "ge": ">= " + v}.get(bound, "   " + v)


def main():
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    ap.add_argument("pngs", nargs="+", help="full-plate top-down renders")
    ap.add_argument("--max", type=float, default=2.0,
                    help="stop searching above this width, mm (default 2.0)")
    ap.add_argument("--area-factor", type=float, default=1.0,
                    help="significance filter, in units of (w/2)^2 (default 1.0)")
    ap.add_argument("--json", help="write results to this file")
    ap.add_argument("--check", metavar="BASELINE",
                    help="fail if any pattern is thinner than its baseline")
    ap.add_argument("--write-baseline", metavar="BASELINE",
                    help="write current values as the new baseline")
    args = ap.parse_args()

    files = [f for f in args.pngs
             if not f.endswith("_3d.png") and os.sep + "thumb" + os.sep not in f]
    results = {}
    for f in sorted(files):
        name = os.path.splitext(os.path.basename(f))[0]
        results[name] = audit(f, args.max, args.area_factor)

    width = max(map(len, results)) + 2
    print(f"{'pattern':<{width}}min wall   min link   worst spots (x, y) mm")
    key = lambda n: min(results[n]["min_wall_mm"], results[n]["min_link_mm"])
    for name in sorted(results, key=key):
        r = results[name]
        spots = "  ".join(f"({x:5.1f},{y:5.1f})" for x, y in r["spots"])
        if r["link_bound"] != "ge" and r["link_spot"]:
            spots += "  link@({:.1f},{:.1f})".format(*r["link_spot"][0])
        print(f"{name:<{width}}{fmt(r['min_wall_mm'], r['bound'])} mm "
              f"{fmt(r['min_link_mm'], r['link_bound'])} mm  {spots}")

    if args.json:
        with open(args.json, "w") as fh:
            json.dump(results, fh, indent=1, sort_keys=True)
    if args.write_baseline:
        base = {n: {"min_wall_mm": r["min_wall_mm"],
                    "min_link_mm": r["min_link_mm"]}
                for n, r in sorted(results.items())}
        with open(args.write_baseline, "w") as fh:
            json.dump(base, fh, indent=1, sort_keys=True)
        print(f"\nbaseline written: {args.write_baseline}")
    if args.check:
        if not os.path.exists(args.check):
            sys.exit(f"baseline {args.check} not found - run `make audit-baseline`")
        with open(args.check) as fh:
            base = json.load(fh)
        tol = 0.15                          # ~1.5 px of raster jitter
        bad, new = [], []
        for n, r in results.items():
            if n not in base:
                new.append(n)
                continue
            for m in ("min_wall_mm", "min_link_mm"):
                if r[m] < base[n][m] - tol:
                    bad.append(f"FAIL {n}: {m} {r[m]} mm, baseline {base[n][m]} mm")
        if new:
            sys.exit(f"\nFAIL: no baseline for: {', '.join(sorted(new))} "
                     f"- run `make audit-baseline` and commit it")
        if bad:
            print()
            print("\n".join(sorted(bad)))
            sys.exit(1)
        print(f"\nOK - no pattern thinner than its baseline (tolerance {tol} mm)")


if __name__ == "__main__":
    main()
