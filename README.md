# Sashiko OpenSCAD Templates

3D-printable flat stitch-guide templates for Japanese sashiko embroidery. Each
template is a flat plate with the pattern cut **all the way through** as thin
slots. You lay the plate on fabric and mark through the slots with a chalk
pencil / fabric pen, then stitch along the marks.

**[Browse the gallery →](https://michael-gebis.github.io/sashiko/)** — top-down and
3D renders of all 55 templates, published from the `.scad` sources to GitHub Pages.

## How it works (and why)

A marking template only works if the marker can reach the cloth, so the slots
are cut **full-thickness**, not engraved into the top face. But a continuous-line
sashiko pattern cut fully through would fall apart — every enclosed region
(circle interiors, leaf centers) would drop out. To prevent that, each slot is
interrupted by small solid **bridges** that keep every region tied to the plate.

All geometry is built in **2D and extruded once** at the end. This renders in a
few seconds; an earlier version that unioned thousands of 3D `hull`s timed out
at >5 minutes.

Verify a template is printable by rendering (F6) and checking the console:
**`Volumes: 2`** means one connected solid (good). A larger number means that
many loose pieces — lower `bridge_sp` or check bridge placement.

## Shared library — `sashiko_lib.scad`

| Module | Purpose |
|--------|---------|
| `slot_dash(p1,p2,r)` | 2D rounded slot segment (a "stadium") |
| `corner_seg(p1,p2,r,gap)` | slot pulled in by `gap` at each end, leaving a solid corner where cells meet |
| `bridged_line(p1,p2,r,bridge_w,bridge_sp)` | straight slot, ≥1 bridge, more on long runs |
| `bridged_arc(c,R,r,a1,a2,bridge_w,bridge_sp)` | open arc slot with periodic bridges |
| `bridged_circle(c,R,r,bridge_w,bridge_angles)` | circular slot, bridge centred on each given angle |
| `hex_outline(c,R,r,gap,a0)` | regular hexagon of corner-gapped edges (`a0`: 90 = pointy-top, 0 = flat-top) |
| `sashiko_plate(w,h,t,border,chamfer,reg)` | extrudes the 2D pattern (children) through a bordered plate; optional edge chamfer + registration holes |

### Keeping a pattern in one piece

Different tilings detach differently. Whichever you use, verify with `Volumes: 2`:
- **Straight closed cells (asanoha):** `bridged_line` forces ≥1 bridge per segment.
- **Polygon tilings (hishi, kikkō, masu):** leave the **corners** uncut — `corner_seg`
  stops each slot short of the vertex, where several cells meet, so a solid corner joins
  them all while the edges stay continuous (`hex_outline` applies this to hexagons).
  Size `corner_gap` to the **sharpest angle θ** between slots at the vertex: the solid
  neck between two slot caps is `2·gap·sin(θ/2) − groove_w`, so gap 1.4 suits 90°
  vertices but 60° vertices need 1.8 — too small a gap leaves hairline necks
  (`make audit` reports them as *min link*).
- **Curve/overlap patterns (shippō, seigaiha):** bridge placement matters more than count.
  Bridge where overlaps are *deep* (shippō cardinals), not where curves merely *touch*
  (tangent points give point contacts, not joins). Reduce overlap (seigaiha `col_pitch = 2R`)
  rather than fighting hundreds of tiny cells with dense bridges.
- **Patterns that enclose nothing (dots, open curves — umebachi, tatewaku):** need no
  bridges at all; the slots are cut straight through.

Bridge width accounts for the rounded slot caps, so the *solid* tab left behind
is actually `bridge_w` wide.

## Design conventions

The plate-level parameters live in **`sashiko_config.scad`**, which every
template `include`s (use `include`, not `use`, so the variables come through) —
edit one value there and it changes every template at once. Everything else
(`bridge_sp` and each pattern's scale and `corner_gap`) stays in the individual
template files.

| Parameter | Value | Where | Notes |
|-----------|-------|-------|-------|
| `plate_w/h` | 100 mm | config | Template size |
| `plate_t` | 1.6 mm | config | Plate thickness (slots cut through all of it) |
| `groove_w` | 1.2 mm | config | Slot width |
| `border` | 6 mm | config | Solid margin around plate edge |
| `chamfer` | 0.5 mm | config | 45° bevel on the four outer top edges (0 = off; keep ≤ t/2) |
| `reg` | off | config | Datum holes at the pattern-window corners, for tiling (see below) |
| `bridge_w` | 1.4 mm | config | Solid tab left in each slot (~1.2 mm min for strength) |
| `bridge_sp` | 14 mm | template | Target spacing between bridges on long lines |

### Registration & tiling

`reg = true` in the config cuts a small datum hole at each corner of the pattern
window (the marked area) on every plate. To cover a piece larger than one plate:
mark the pattern **and** the four datum dots, then reposition the plate so its
leading holes sit on the previous placement's dots. That steps the plate by
exactly the window size — `plate_w − 2·border` across, `plate_h − 2·border` down
(88 mm with the defaults) — and butts the two patterns at the boundary.

The join is **seamless only if the pattern's repeat divides that pitch**, so pick
a scale that does (e.g. `cell = 8 / 11 / 16 / 22 mm`). Otherwise placements are
still evenly aligned, just with a small step at each seam. `reg` is off by default.

## Files

### `asanoha.scad` — Hemp Leaf (麻の葉)

Pointy-top hexagonal grid; each hexagon splits into 6 equilateral triangles and
each triangle's three corners (center + two vertices) join to its **centroid**.
The spoke is each leaf's mid-rib, center→centroid lines divide adjacent leaves,
and vertex→centroid lines form the leaf sides.

**Key parameter:** `hex_r` (circumradius, default 12 mm). At 12 mm with 1.2 mm
slots the motif is fairly dense and the 12 lines converging at each center
nearly merge — bump `hex_r` to ~15–16 mm for a more open look.

Tiling: column spacing `hex_r·√3`, row spacing `hex_r·1.5`, odd rows offset by
half a column.

### `shippo.scad` — Seven Treasures (七宝)

Overlapping circles on a square grid. `circle_r = spacing·√2/2` makes exactly 4
circles meet at each grid-square center.

**Bridges go at the cardinal points `[0,90,180,270]`** (toward each edge
neighbor, i.e. mid-overlap), which directly join each circle's center square to
the petals around it. Bridging at the diagonal tangent points instead *fails*:
diagonal circles only touch at a single point, so the "bridge" is a point
contact, not a solid join, and every center square drops out (seen as
`Volumes: 27` = 26 loose pieces).

**Key parameter:** `spacing` (center-to-center distance, default 16 mm).

### `seigaiha.scad` — Blue Sea Waves (青海波)

Overlapping concentric semicircle arcs (fish scales). Scales sit edge-to-edge in
a row (`col_pitch = 2R`) and each row nests a half-scale into the one below,
rising by `R`. This keeps overlaps to row-to-row crossings only — the denser
`col_pitch = R` layout encloses hundreds of tiny background cells that won't
stay attached.

**Key parameters:** `R` (scale radius, 14 mm), `n_arcs` (arcs per scale, 3).

### `hishi.scad` — Diamond (菱)

Edge-to-edge rhombus lattice (centers at every `(i·a, j·b)` with `i+j` even).
Edges stop short of the corners (`corner_gap`) so the four diamonds meeting at
each vertex stay joined while the outlines read as continuous diamonds.

**Key parameters:** `dia_w` (16 mm), `dia_h` (24 mm; taller is traditional).

### `kikko.scad` — Tortoise Shell (亀甲)

Regular hexagon honeycomb (pointy-top), reusing the asanoha hex grid but drawing
only the cell outlines. Three hexagons meet at each vertex, so the same
corner-gap trick as hishi keeps everything joined.

**Key parameter:** `hex_r` (circumradius, default 13 mm).

### `kikko_plus.scad` — Tortoise Shell with center plus

Same honeycomb as `kikko.scad` with a small "+" centred in every hexagon. The
plus is two crossing open segments (encloses nothing, needs no bridges).

**Key parameter:** `plus_frac` (plus span as a fraction of hex width, default 0.25).

### `kagome.scad` — Woven Basket (籠目)

Trihexagonal lattice. Flat-top hexagons sit on a triangular grid of centers
spaced `2·hex_r`, so neighbours touch corner-to-corner and the gaps between them
are equilateral triangles of the same edge length. Only the hexagons are drawn —
each triangle is bounded by one edge from each of its three neighbours — and the
corner-gap trick (two hexagons meet at every vertex) keeps it all joined.

**Key parameter:** `hex_r` (circumradius = triangle edge, default 11 mm).

### `shokko.scad` — Shokkō (蜀江)

Truncated-square tiling: regular octagons on a square grid with a small square in
each diagonal gap. Octagon spacing is the flat-to-flat width `oct_w`; neighbours
share their axis-aligned edges, and each diagonal edge bounds a square. Only the
octagons are drawn (the squares are the gaps), and the corner-gap trick applies —
a square and two octagons meet at every vertex.

**Key parameter:** `oct_w` (octagon flat-to-flat width = grid spacing, default 22 mm).

### `komezashi.scad` — Rice Stitch (米刺し)

A hitomezashi (one-stitch) field of 米 motifs: at each grid point four open dashes
(horizontal, vertical, both diagonals) cross at a single point. Like the
kikko_plus "+", the motif encloses nothing, so it needs no bridges. Keep
`arm_frac < 1` so neighbouring motifs stay separate.

**Key parameters:** `cell` (grid pitch, default 11 mm), `arm_frac` (motif diameter
÷ pitch, default 0.62).

### `sayagata.scad` — Sayagata (紗綾形)

Interlocking 卍 (*manji-tsunagi*). The trick the earlier attempts missed: the
manji centers don't sit on an axis-aligned grid (that fuses into a plain
cross-grid) but on a **square lattice rotated ~18°**, generated by `v1 =
(3,1)·unit` and its 90° rotation, so neighbouring hooks meet *perpendicularly*
and weave.

A lone 卍 is a tree (a "+" with four dangling L-hooks) and encloses nothing — so
every closed loop in the pattern comes from two neighbours' hooks meeting
end-to-end, each trapping a solid island (the un-bridged plate renders
`Volumes: 138`). Drawing each hook a hair short of its meeting point (`hook_gap`,
the same corner-gap idea kikko uses at its vertices) breaks every loop and
returns the plate to `Volumes: 2`.

**Key parameters:** `unit` (stroke spacing = pattern scale, default 3 mm),
`hook_gap` (solid tab left at each hook join, default 1.4 mm).

### `igeta.scad` — Well Curb (井桁)

Double-line square lattice — the 井 "well frame" repeated. Paired lines `well`
apart run both ways; a corner gap at every crossing leaves a solid node, so all
the small wells and the larger cells between them stay attached.

**Key parameters:** `cell` (node spacing, default 18 mm), `well` (opening, 6 mm).

### `uroko.scad` — Fish Scales (鱗)

Triangular tessellation. Drawing only the up-triangles already draws every edge
(each down-triangle is bounded by its three neighbours); six triangles meet at a
vertex, so the corner-gap trick keeps it joined.

**Key parameter:** `tri` (triangle edge, default 15 mm).

### `matsukawabishi.scad` — Pine-bark Diamond (松皮菱)

The hishi diamond lattice with a smaller concentric lozenge inside each, for the
layered "pine-bark" look. Both rings corner-gapped.

**Key parameters:** `dia_w`/`dia_h` (18/26 mm), `small_frac` (inner size, 0.5).

### `bishamon_kikko.scad` — Bishamon Tortoise Shell (毘沙門亀甲)

The kikko honeycomb with a concentric inner hexagon in each cell — the denser,
"armoured" tortoiseshell. Both rings corner-gapped.

**Key parameters:** `hex_r` (14 mm), `inner_frac` (inner size, 0.55).

### `yabane.scad` — Arrow Feathers (矢羽根)

Columns of fletching: a vertical shaft with chevron barbs rising at intervals.
Shaft and barbs are open segments, so nothing is enclosed and no bridges are
needed.

**Key parameters:** `col_sp` (shaft spacing, 12 mm), `barb_sp` (11 mm), `barb_w`/`barb_h`.

### `juji.scad` — Cross Stitch (十字)

Hitomezashi grid of plain "+" crosses (no diagonals, unlike komezashi). Open
segments, no bridges.

**Key parameters:** `cell` (grid pitch, 10 mm), `arm_frac` (0.6).

### `kakinohanazashi.scad` — Persimmon Flower (柿の花刺し)

Hitomezashi flowers: a "+" inside a corner-gapped diamond, so the flower centre
stays attached without bridges; the four diamond dashes read as petals.

**Key parameters:** `cell` (flower spacing, 14 mm), `petal` (4.5 mm), `plus_arm`.

### `wachigai.scad` — Linked Rings (輪違い)

Overlapping rings on a **hexagonal** packing (chain-mail look, distinct from
shippō's square grid). Each ring is bridged toward all six neighbours — i.e. at
every overlap — so the ring interiors and the gaps stay tied to the plate.

**Key parameters:** `spacing` (20 mm), `ring_frac` (0.58; keep ≤ 0.60, beyond
which loose cells reappear).

### `tatewaku.scad` — Rising Steam (立涌)

Vertical wavy lines, anti-phase between neighbours, so the band between each pair
swells (the steam pillar) and pinches. Full-height open curves — nothing is
enclosed, so no bridges are needed (the bulges never close into a lens).

**Key parameters:** `col_sp` (18 mm), `amp` (5 mm), `period` (28 mm).

### `amime.scad` — Fishnet (網目)

A diamond mesh with edges bowed into arcs. Each edge is drawn **once** (as the
upper edge of one cell, never re-drawn by the neighbour) so opposite arcs don't
trap a sliver between them; corner-gapped at the vertices like hishi.

**Key parameters:** `mesh_w`/`mesh_h` (22 mm), `sag` (edge bow, 4.5 mm).

### `raimon.scad` — Thunder (雷文)

A field of squared spirals (the leiwen "thunder" key), rotated in quarter-turns
for the interlocking look. A spiral is a single **open** line, so it encloses
nothing and needs no bridges.

**Key parameters:** `unit` (arm spacing, 3 mm), `pitch` (spiral spacing, 22 mm).

### `masu.scad` — Measuring Boxes (枡刺し)

Nested concentric squares on a grid — the matsukawabishi idea with squares. Both
rings corner-gapped (four squares meet at each vertex).

**Key parameters:** `cell` (box size, 18 mm), `inner_frac` (0.5).

### `tasuki.scad` — Sash-cord Lattice (襷)

Crossing diagonals — a square lattice turned 45°. Each node draws its two upward
diagonals (so every edge is drawn once); corner-gapped at the crossings.

**Key parameter:** `cell` (node spacing, 16 mm).

### `kuginuki.scad` — Nail-puller (釘抜き)

A grid of square "washer" frames (a square ring), spaced apart so they read as
the linked nail-puller crest. Outer and inner squares corner-gapped.

**Key parameters:** `cell` (16 mm), `outer`/`inner` (frame radii).

### `hanabishi.scad` — Flower Diamond (花菱)

A four-petal bloom per cell: four square-on-point lozenge petals around a centre
(90° corners, so the corner gaps stay open).

**Key parameter:** `cell` (flower spacing, 19 mm).

### `mitsumori_kikko.scad` — Three-grouped Tortoise Shell (三盛亀甲)

The *literal* Bishamon shell — hexagons grouped in interlocking threes, vs. the
concentric `bishamon_kikko`. *First pass; the grouping could be tightened.*

**Key parameters:** `hex_r` (9 mm), `grp` (group spacing).

### `tumbling_blocks.scad` — Isometric Cubes / Rhombille

The kikko honeycomb with each hexagon split by a Y into three rhombi — a field of
cubes. Edges and spokes corner-gapped at the vertices and the hex centre.

**Key parameter:** `hex_r` (cube size, 14 mm).

### `juji_hanazashi.scad` — Cross Flower (十字花刺し)

Hitomezashi crosses with long arms, so four crosses around each open cell cluster
into a flower. Open dashes, no bridges.

**Key parameters:** `cell` (12 mm), `arm_frac` (0.85).

### `kawari_hanajuji.scad` — Variant Cross Flower (変わり花十字)

The cross-flower with a small diagonal "x" added in each cell centre (the
diagonal-stitch variant). Open dashes.

**Key parameters:** `cell` (13 mm), `arm_frac`, `cross_frac`.

### `yamagata.scad` — Mountains (山形)

Hitomezashi rows of zigzag mountains; each row is one continuous open zigzag.

**Key parameters:** `period` (16 mm), `amp` (7 mm), `row_sp` (13 mm).

### `sugiaya.scad` — Cedar Twill / Herringbone (杉綾)

Horizontal bands of parallel diagonal dashes whose slope flips each band, meeting
in chevrons at the band edges. Open dashes.

**Key parameters:** `band` (11 mm), `line_sp` (5 mm).

### `kanoko.scad` — Fawn Spots (鹿の子)

The tie-dye fawn spot: a brick grid of small corner-gapped boxes.

**Key parameters:** `cell` (10 mm), `spot` (2.6 mm).

### `hanmaru_tsunagi.scad` — Linked Semicircles (半丸つなぎ)

Rows of linked semicircle scallops, alternate rows offset to interlace. Open arcs
(no chords), so no bridges.

**Key parameters:** `R` (9 mm), `row_sp` (11 mm).

### `same_komon.scad` — Sharkskin (鮫小紋)

The fine "sharkskin" texture: tiny dot-holes in nested quarter-fans radiating
from each grid corner. Dots enclose nothing, so no bridges.

**Key parameters:** `cell` (14 mm), `dot_r` (0.9 mm).

### `genjiguruma.scad` — Ox-cart Wheels (源氏車)

A grid of wheels — a bridged rim with radial spokes that stop short of an open
hub, so the sectors all connect through the hub and out through the rim bridges.
The rim bridges sit halfway *between* spokes: a spoke tip reaching the rim at a
bridge angle punches through the tab and leaves only ~0.1 mm straps.

**Key parameters:** `spacing` (25 mm), `R` (10.5 mm), `spokes` (8).

### `mitsudomoe.scad` — Triple Swirl (三つ巴)

Three comma swirls pinwheeling inside a bridged ring; each swirl is an open
spiral. *First-pass take on the tomoe.*

**Key parameters:** `spacing` (26 mm), `R` (11 mm), `sweep` (210°).

### `yagasuri.scad` — Arrow Feathers (矢絣)

The arrow-feather kasuri: columns of interlocking chevrons, no shaft (fuller than
yabane). Open chevrons.

**Key parameters:** `col_w` (16 mm), `feather_sp` (9 mm).

### `karakusa.scad` — Arabesque Vines (唐草)

Rows of a sinuous wave with an open spiral tendril curling off each crest. The
tendrils sit clear of the wave so nothing closes — no bridges.

**Key parameters:** `period` (26 mm), `amp` (6 mm), `curl_r` (4 mm).

### `yotsume_goushi.scad` — Four-eye Lattice (四つ目格子)

A plain open square lattice — single lines, corner-gapped at every crossing so the
square "eyes" stay attached.

**Key parameter:** `cell` (grid pitch, 14 mm).

### `wari_bishi.scad` — Split Diamond (割菱)

The hishi lattice with each diamond split into four sub-diamonds by spokes to the
edge midpoints; corner-gapped at the vertices, centre and spoke ends.

**Key parameters:** `dia_w`/`dia_h` (20/28 mm).

### `mitsuuroko.scad` — Three Scales (三つ鱗)

The Hōjō crest: three triangles grouped into a larger triangle (with a triangular
gap in the middle), tiled in offset rows; corner-gapped.

**Key parameters:** `tri` (9 mm), `gap` (6 mm).

### `kikko_hanabishi.scad` — Tortoise Shell + Flower (亀甲花菱)

The kikko honeycomb with a hanabishi four-petal flower set inside each hexagon.
Hexagon edges and petals all corner-gapped.

**Key parameter:** `hex_r` (15 mm).

### `janome.scad` — Snake-eye (蛇の目)

A grid of bullseyes — two concentric bridged rings around a centre dot; motifs
don't overlap, so the background ties everything together.

**Key parameters:** `spacing` (22 mm), `R_out`/`R_in`, `dot_r`.

### `genjiko.scad` — Genji Incense Symbols (源氏香)

Motifs of five vertical bars with horizontal top links joining some of them (a few
different symbols tiled). Open "combs", so no bridges.

**Key parameters:** `bar_h` (15 mm), `bar_sp` (4 mm).

### `hana_shippo.scad` — Flower Seven Treasures (花七宝)

The shippō overlapping-circle lattice (bridged at the cardinals) with a small open
8-arm flower in each circle centre.

**Key parameters:** `spacing` (18 mm), `flower` (arm half-length).

### `fundo_tsunagi.scad` — Linked Counterweights (分銅つなぎ)

A diamond mesh whose edges bow **inward**, so each cell is a concave-sided
"counterweight" — amime pinched rather than puffed. Single-edge, corner-gapped.

**Key parameters:** `mesh_w`/`mesh_h` (22 mm), `sag` (4 mm).

### `matsuba.scad` — Pine Needles (松葉)

Scattered open "V" needle-pairs on an offset grid, each rotated differently. Open,
no bridges.

**Key parameters:** `cell` (11 mm), `needle` (7 mm), `spread` (16°).

### `nowaki.scad` — Grasses in the Wind (野分)

Tufts of grass blades fanning from one root and swept the same way — open curves
kept shorter than the row pitch so nothing crosses or encloses. No bridges.

**Key parameters:** `blade_len` (15 mm), `bend` (7 mm).

### `kanze_mizu.scad` — Swirling Water (観世水)

Whirlpools of concentric open arcs, each ring's opening rotated a little so the
set reads as a spiral. Open arcs, non-overlapping, so no bridges.

**Key parameters:** `spacing` (21 mm), `rings` (3), `twist` (34°).

### `ryusui.scad` — Running Water (流水)

Flowing horizontal water: bands of parallel meandering lines, adjacent bands
phase-shifted so the stream reads as moving. Open lines, no bridges.

**Key parameters:** `period` (34 mm), `amp` (5 mm), `lines` (3), `band_sp` (19 mm).

### `mokko.scad` — Melon Crest (木瓜)

The four-lobed melon/quince crest: four arcs bulging outward between diagonal
cusps, with a concentric inner mokkō. The cusps are corner-gapped, and motifs
don't overlap.

**Key parameters:** `spacing` (21 mm), `rc` (cusp radius), `bulge`, `inner_frac`.

### `umebachi.scad` — Plum Blossom (梅鉢)

The plum-blossom crest: five petal dots in a ring around a centre dot. The dots
are round holes, so nothing is enclosed and no bridges are needed.

**Key parameters:** `spacing` (17 mm), `ring`, `petal`, `center`.

### `mame_shibori.scad` — Bean Dots (豆絞り)

An even field of round dots — the "bean" polka-dot tie-dye, on a hexagonal
packing. Dots are holes, no bridges.

**Key parameters:** `spacing` (9 mm), `dot` (1.8 mm).

### `ichimatsu.scad` — Checkerboard (市松)

The checkerboard drawn as outlined squares on the "filled" checks only (you mark
the checks, not the colour) — each square slightly inset so they read as distinct
checks rather than a plain grid. Corner-gapped.

**Key parameters:** `cell` (16 mm), `sq_frac` (square ÷ cell, 0.88).

### `wachigai_woven.scad` — Interlaced Rings (輪違い)

The woven (over-under) wachigai: a square grid of rings, each drawn *through* its
leading-side (+α) crossings and *broken* at the trailing-side (−α) ones, so
neighbours appear to interlace. The over/under rule (under at cardinal − α) is
globally consistent, and the four breaks per ring double as its bridges. (The
flat overlapping-rings take is `wachigai.scad`.)

**Key parameters:** `spacing` (22 mm), `ring_frac` (0.62), `gap_deg` (break width, 7°).

## Patterns to add

The 55 patterns above cover the common repertoire and then some; the
distinct-geometric well is essentially dry. What's left is refinement of existing
templates:

**Refinements to existing templates:**
- [ ] Tatewaku with a motif (clouds, flowers) tucked inside each bulge.
- [ ] Shokkō colour-variants (the octagons filled with sub-patterns).
- [ ] Tighten mitsumori kikkō (the three-hexagon grouping) and mitsudomoe (the
  comma swirls) toward the classic crest shapes.

## Known limitations & future work

Starting points for a future pass:

- **Thin features are measured (`make audit`) but still untested in plastic.** Ten
  patterns whose slots converge or run tangent — amime, asanoha, fundō-tsunagi,
  hanmaru-tsunagi, karakusa, matsuba, nowaki, seigaiha, shippō, yabane — bottom out at
  **knife-edge wedge tips** (≤ 0.11 mm, the audit's resolution floor): where merging slots
  pinch the solid between them, it tapers to zero. Expect those tips to print as wisps or
  tiny local holes — likely cosmetic on a marking jig, but they're the plates to test-print
  first. Six more have walls of 0.17–0.41 mm (hana-shippō, wachigai, wari-bishi at 0.17;
  komezashi 0.23; kakinohanazashi 0.38; wachigai_woven 0.41); everything else is
  ≥ 0.47 mm. If a knife-edge pattern misprints, the fix is corner-gap style: stop the
  converging slots just short of their merge. The **min link** (load-bearing) side is
  healthy everywhere — ≥ 0.47 mm — except wachigai_woven's 0.38 mm weave straps, where
  each over-passing ring pierces the under-ring's break by design; if those prove too
  weak in print, raise its `gap_deg` (7° → 9° roughly doubles the straps at the cost of
  longer line breaks). **Nothing has been test-printed yet.**
- **Some patterns are stylised interpretations,** not validated by a practitioner — e.g.
  bishamon-kikkō, matsukawabishi, mitsumori-kikkō, mitsudomoe, fundō-tsunagi, ichimatsu,
  amime. Treat their geometry as "inspired by," not canonical.
- **Tiling is seamless only when the pattern repeat divides the registration pitch**
  (88 mm with the defaults; see [Registration & tiling](#registration--tiling)) — otherwise
  placements align but show a small step at each seam.
- **Ergonomics are untested:** 1.6 mm may be thin for a rigid 100 mm jig (it can cup), and a
  1.2 mm slot suits a fine fabric pen, not a fat chalk pencil (the mark is ~1.2 mm wide).

## Building

A `Makefile` drives everything. Patterns are auto-discovered, so a new
`<name>.scad` is picked up with no edit to the build.

| Command | What it does |
|---------|--------------|
| `make` | Build everything out of date — STLs + gallery site |
| `make stl` | Build the printable `.stl` files into `build/` |
| `make gallery` | Render previews + thumbnails + `gallery/index.html` |
| `make index` | Regenerate `gallery/index.html` from the `Description:` lines |
| `make verify` | Check every pattern renders as one solid (`Volumes: 2`) |
| `make audit` | Thinnest-wall audit of every pattern vs the committed baseline |
| `make audit-baseline` | Refresh `minwall_baseline.json` after intentional geometry changes |
| `make clean` | Remove `build/` and `gallery/` (all generated output) |
| `make help` | List the targets |

STLs are written to **`build/`**; the gallery (previews, thumbnails, `index.html`)
to **`gallery/`**. Both are git-ignored — STLs ship via a GitHub Release, and the
gallery is rendered and published to **GitHub Pages** by `.github/workflows/pages.yml`
on every push that touches a pattern (one-time setup: repo **Settings → Pages →
Source = GitHub Actions**). Every output depends on `sashiko_lib.scad` +
`sashiko_config.scad`, so changing a shared value (e.g. `plate_t` or `chamfer`)
rebuilds everything that uses it. Requires `openscad` and ImageMagick (`convert`).

Each pattern carries a `// Description:` comment (e.g. `// Description: **Amime** —
Fishnet (網目)`). `gen_index.py` reads those to build the gallery's `index.html`
cards — a file missing that line builds with a warning and a placeholder caption.

### Min-wall audit

`make verify` proves each plate is *one* solid; `make audit` covers the other half
of printability: nothing in that solid is too thin. The plates are uniform
extrusions, so a full-plate orthographic top render (`build/audit/`, 2000 px ≈
0.06 mm/px) *is* the 2D geometry; `audit_minwall.py` segments it, calibrates
mm/px from the plate's 100 mm footprint, and binary-searches two widths per
pattern:

- **min wall** — smallest `w` whose morphological opening (erode + dilate by a
  disc of `w/2`) removes a significant piece of solid: a wall, neck, or wedge
  thinner than `w` *and too far from thicker bulk to be supported by it*.
- **min link** — smallest `w` whose erosion alone splits the solid into more
  than one piece: the thinnest **load-bearing connection**. This catches short
  necks that min wall treats as supported — it's what found genjiguruma's
  diagonal spoke tips landing exactly on the rim's bridge tabs, leaving 0.1 mm
  straps as each wheel's only anchor (fixed by moving the bridges between the
  spokes). For a healthy pattern it reads as the designed bridge/neck width.

Both values are compared against the committed `minwall_baseline.json` (0.15 mm
tolerance) and CI fails on regression; after an intentional geometry change,
run `make audit-baseline` and commit the updated baseline. Notes for reading
the numbers (also in `audit_minwall.py --help`): accuracy is pixel-bound
(~±0.1 mm; render larger for finer), and min wall reports the thinnest
**unsupported span** — a stout lattice like mame-shibori's 5.4 mm walls between
fatter junctions reads `>= 2.0` rather than 5.4. Needs `python3-numpy`.

## OpenSCAD tips

- **F5** — fast preview, **F6** — full render (export-ready, a few seconds)
- **File → Export → Export as STL** after F6, or headless:
  `openscad -o build/asanoha.stl asanoha.scad` (or just `make stl`)
- Quick top-down preview image:
  `openscad --camera=50,50,0,0,0,0,180 --projection=ortho -o out.png asanoha.scad`

## License

MIT — see [LICENSE](LICENSE). The patterns are traditional Japanese motifs (not
themselves copyrightable); the license covers the OpenSCAD implementations and
the build tooling.
