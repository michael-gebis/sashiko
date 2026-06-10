# Makefile — build the sashiko stitch-guide templates.
#
#   make            build everything out of date (STLs + gallery)
#   make stl        just the printable .stl files (written to build/)
#   make gallery    just the preview PNGs + index + contact sheet
#   make index      regenerate gallery/INDEX.md from the Description: lines
#   make verify     check every pattern renders as one solid (Volumes: 2)
#   make clean      remove generated STLs and gallery PNGs
#   make help       list the targets
#
# Patterns are discovered automatically — drop in a new <name>.scad and it is
# picked up with no edit here. Every output depends on the shared library and
# config, so changing a shared value (e.g. plate_t or chamfer in the config)
# correctly rebuilds everything that uses it. Builds are incremental.

OPENSCAD := openscad
SHARED   := sashiko_lib.scad sashiko_config.scad

# every template = every .scad except the two shared files
PATTERNS := $(filter-out sashiko_lib sashiko_config,$(basename $(wildcard *.scad)))

STLS  := $(addprefix build/,$(addsuffix .stl,$(PATTERNS)))
TOPS  := $(addprefix gallery/,$(addsuffix .png,$(PATTERNS)))
ISOS  := $(addprefix gallery/,$(addsuffix _3d.png,$(PATTERNS)))
SHEET := gallery/_contact_sheet.png
INDEX := gallery/INDEX.md

IMG     := --imgsize=1000,1000 --colorscheme=Tomorrow
TOP_CAM := --projection=ortho --camera=50,50,0,0,0,0,150
ISO_CAM := --projection=perspective --camera=50,50,1.5,58,0,22,300

.DEFAULT_GOAL := all
.SECONDARY:
.PHONY: all stl gallery contact index verify clean help

all: stl gallery                   ## build STLs + gallery (everything)

stl: $(STLS)                       ## build all printable STLs (into build/)

gallery: $(SHEET) $(ISOS) $(INDEX) ## build preview PNGs, index + contact sheet

contact: $(SHEET)                  ## (re)build just the contact sheet

index: $(INDEX)                    ## regenerate gallery/INDEX.md from Description: lines

# --- pattern rules --------------------------------------------------------

build/%.stl: %.scad $(SHARED)
	@mkdir -p build
	$(OPENSCAD) -o $@ $< 2>/dev/null

$(TOPS): gallery/%.png: %.scad $(SHARED)
	@mkdir -p gallery
	$(OPENSCAD) --render $(IMG) $(TOP_CAM) -o $@ $< 2>/dev/null

$(ISOS): gallery/%_3d.png: %.scad $(SHARED)
	@mkdir -p gallery
	$(OPENSCAD) --render $(IMG) $(ISO_CAM) -o $@ $< 2>/dev/null

$(SHEET): $(TOPS)
	montage -label '%t' $(sort $^) -tile 8x -geometry 175x175+4+7 \
	  -background white -fill black -pointsize 13 \
	  -title "Sashiko Stitch-Guide Templates ($(words $(PATTERNS)))" $@

$(INDEX): $(addsuffix .scad,$(PATTERNS)) gen_index.py
	python3 gen_index.py

# --- utility --------------------------------------------------------------

verify:                  ## check every pattern is one solid (Volumes: 2)
	@fail=0; for p in $(PATTERNS); do \
	  v=$$($(OPENSCAD) -o /tmp/_sashiko_verify.stl $$p.scad 2>&1 | grep -i volumes | grep -oE '[0-9]+'); \
	  if [ "$$v" != "2" ]; then echo "  FAIL $$p (Volumes $$v)"; fail=1; fi; \
	done; \
	if [ $$fail -eq 0 ]; then echo "OK - all $(words $(PATTERNS)) patterns render Volumes: 2"; \
	else echo "Some patterns are not one solid."; exit 1; fi

clean:                   ## remove generated STLs (build/) and gallery PNGs
	rm -rf build
	rm -f $(TOPS) $(ISOS) $(SHEET)

help:                    ## show this help
	@grep -hE '^[a-z][a-z-]*:.*##' $(MAKEFILE_LIST) | sed -E 's/:.*## /\t/' | sort
