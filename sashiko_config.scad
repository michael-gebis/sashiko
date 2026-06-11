// sashiko_config.scad
// Shared plate configuration for every sashiko template. Change a value here and
// it applies to all templates at once. Each template `include`s this file — use
// `include`, NOT `use`, because `use` does not import top-level variables — and
// keeps only its own pattern-specific parameters (scale, corner_gap, bridge_sp …).

plate_w  = 100;   // plate width (mm)
plate_h  = 100;   // plate height (mm)
plate_t  = 1.6;   // plate thickness (mm) — slots are cut through all of it
groove_w = 1.2;   // slot width (mm)
border   = 6;     // solid border around plate edge (mm)
chamfer  = 0.5;   // 45° bevel on the four outer top edges (mm; 0 = off, keep <= t/2)
bridge_w = 1.4;   // solid tab left in each bridged slot (mm; ~1.2 min for strength)
reg      = false; // cut datum holes at the pattern-window corners for tiling (see README)
