#!/usr/bin/env python3
"""Min-wall audit: measure each template's thinnest solid wall from its
top-down gallery render.

The plates are uniform extrusions, so the top-down orthographic PNG *is* the 2D
solid geometry, already rasterized: background-coloured pixels are cuts (or
outside the plate), everything else is solid. We segment that mask, calibrate
mm/px from the plate's known 100 mm footprint, then binary-search the smallest
width w whose morphological opening (erode + dilate by a disc of radius w/2)
removes a significant piece of solid — i.e. a wall, neck, or wedge thinner
than w. Plain 90-degree corners shed only ~0.21*(w/2)^2 of area under opening,
so an area filter of area_factor*(w/2)^2 separates real thin features from
corner rounding.

`Volumes: 2` (make verify) proves the plate is one connected solid; this audit
covers the other half of printability: nothing in that solid is too thin.

Accuracy is pixel-bound: about +/-2 px (~+/-0.2 mm at the gallery's 1000 px
renders). Render larger images for finer numbers. Reported coordinates are
plate mm, origin at the plate's bottom-left corner.

Needs numpy and ImageMagick's `convert` (both already build dependencies).

Usage:
  python3 audit_minwall.py gallery/*.png                  # report, worst first
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

PLATE_MM = 100.0          # plate footprint; calibrates mm/px per image
BG_DIST = 60              # min L1 RGB distance from background to count as solid
MIN_AREA_PX = 4.0         # ignore removed blobs smaller than this (AA specks)


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


def thin_parts(solid, w_px, area_factor):
    """Solid pixels removed by opening with a disc of radius w_px/2, as
    8-connected components above the significance threshold.
    Returns [(area_px, row, col), ...] largest first."""
    rpx = w_px / 2.0
    K = disc(rpx)
    eroded = conv2(solid, K) > K.sum() - 0.5
    opened = conv2(eroded, K) > 0.5
    removed = solid & ~opened
    min_area = max(area_factor * rpx * rpx, MIN_AREA_PX)
    pts = np.argwhere(removed)
    if len(pts) == 0:
        return []
    todo = set(map(tuple, pts))
    comps = []
    while todo:
        stack = [todo.pop()]
        comp = []
        while stack:
            p = stack.pop()
            comp.append(p)
            r0, c0 = p
            for dr in (-1, 0, 1):
                for dc in (-1, 0, 1):
                    q = (r0 + dr, c0 + dc)
                    if q in todo:
                        todo.remove(q)
                        stack.append(q)
        if len(comp) >= min_area:
            a = np.array(comp)
            comps.append((len(comp), a[:, 0].mean(), a[:, 1].mean()))
    comps.sort(reverse=True)
    return comps


def audit(path, w_max, area_factor):
    """-> dict with min_wall_mm, bound ('le'|'exact'|'ge'), spots [[x,y],..]."""
    solid = read_solid_mask(path)
    rows = np.flatnonzero(solid.any(axis=1))
    cols = np.flatnonzero(solid.any(axis=0))
    r0, r1, c0, c1 = rows[0], rows[-1], cols[0], cols[-1]
    px = PLATE_MM / ((c1 - c0 + r1 - r0) / 2 + 1)   # mm per pixel
    pad = int(math.ceil(w_max / 2 / px)) + 2
    sub = solid[max(r0 - pad, 0):r1 + pad + 1, max(c0 - pad, 0):c1 + pad + 1]
    sr0, sc0 = max(r0 - pad, 0), max(c0 - pad, 0)

    def spots_mm(comps):
        # image row 0 is the plate's top edge (+y), so flip y
        return [[round((sc0 + cc - c0) * px, 1), round((r1 - (sr0 + cr)) * px, 1)]
                for _, cr, cc in comps[:2]]

    w_min = max(2 * px, 0.1)                        # below ~2 px is unmeasurable
    hi_parts = thin_parts(sub, w_max / px, area_factor)
    if not hi_parts:
        return {"min_wall_mm": round(w_max, 2), "bound": "ge", "spots": []}
    lo_parts = thin_parts(sub, w_min / px, area_factor)
    if lo_parts:
        return {"min_wall_mm": round(w_min, 2), "bound": "le",
                "spots": spots_mm(lo_parts)}
    lo, hi = w_min, w_max
    while hi - lo > px:                             # can't resolve below 1 px
        mid = (lo + hi) / 2
        parts = thin_parts(sub, mid / px, area_factor)
        if parts:
            hi, hi_parts = mid, parts
        else:
            lo = mid
    return {"min_wall_mm": round(hi, 2), "bound": "exact",
            "spots": spots_mm(hi_parts)}


def fmt(res):
    v = f"{res['min_wall_mm']:.2f}"
    return {"le": "<= " + v, "ge": ">= " + v}.get(res["bound"], "   " + v)


def main():
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    ap.add_argument("pngs", nargs="+", help="top-down renders (gallery/<name>.png)")
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
    print(f"{'pattern':<{width}}min wall   worst spots (x, y) mm")
    for name in sorted(results, key=lambda n: results[n]["min_wall_mm"]):
        r = results[name]
        spots = "  ".join(f"({x:5.1f},{y:5.1f})" for x, y in r["spots"])
        print(f"{name:<{width}}{fmt(r)} mm  {spots}")

    if args.json:
        with open(args.json, "w") as fh:
            json.dump(results, fh, indent=1, sort_keys=True)
    if args.write_baseline:
        base = {n: r["min_wall_mm"] for n, r in sorted(results.items())}
        with open(args.write_baseline, "w") as fh:
            json.dump(base, fh, indent=1, sort_keys=True)
        print(f"\nbaseline written: {args.write_baseline}")
    if args.check:
        if not os.path.exists(args.check):
            sys.exit(f"baseline {args.check} not found - run `make audit-baseline`")
        with open(args.check) as fh:
            base = json.load(fh)
        tol = 0.15                          # ~1.5 px of raster jitter
        bad = [n for n, r in results.items()
               if r["min_wall_mm"] < base.get(n, 0) - tol]
        new = [n for n in results if n not in base]
        if new:
            sys.exit(f"\nFAIL: no baseline for: {', '.join(sorted(new))} "
                     f"- run `make audit-baseline` and commit it")
        if bad:
            for n in sorted(bad):
                print(f"\nFAIL {n}: min wall {results[n]['min_wall_mm']} mm, "
                      f"baseline {base[n]} mm")
            sys.exit(1)
        print(f"\nOK - no pattern thinner than its baseline (tolerance {tol} mm)")


if __name__ == "__main__":
    main()
