# Makefile — build the sashiko stitch-guide templates.
#
#   make            build STLs (build/) + the gallery site (gallery/)
#   make stl        just the printable .stl files (into build/)
#   make gallery    render previews + thumbnails + gallery/index.html
#   make index      regenerate gallery/index.html from the Description: lines
#   make verify     check every pattern renders as one solid (Volumes: 2)
#   make clean      remove build/ and gallery/ (all generated output)
#   make help       list the targets
#
# Patterns are auto-discovered from *.scad. The gallery (gallery/) is build
# output: it is git-ignored and published to GitHub Pages by the pages workflow.

OPENSCAD := openscad
SHARED   := sashiko_lib.scad sashiko_config.scad
PATTERNS := $(filter-out sashiko_lib sashiko_config,$(basename $(wildcard *.scad)))

STLS   := $(addprefix build/,$(addsuffix .stl,$(PATTERNS)))
TOPS   := $(addprefix gallery/,$(addsuffix .png,$(PATTERNS)))
ISOS   := $(addprefix gallery/,$(addsuffix _3d.png,$(PATTERNS)))
THUMBS := $(addprefix gallery/thumb/,$(addsuffix .png,$(PATTERNS)))
INDEX  := gallery/index.html

IMG     := --imgsize=1000,1000 --colorscheme=Tomorrow
TOP_CAM := --projection=ortho --camera=50,50,0,0,0,0,150
ISO_CAM := --projection=perspective --camera=50,50,1.5,58,0,22,300

.DEFAULT_GOAL := all
.SECONDARY:
.PHONY: all stl gallery index verify clean help

all: stl gallery                              ## build STLs + the gallery site

stl: $(STLS)                                  ## build all printable STLs (into build/)

gallery: $(TOPS) $(ISOS) $(THUMBS) $(INDEX)   ## previews + thumbnails + index.html

index: $(INDEX)                               ## regenerate index.html from Description: lines

build/%.stl: %.scad $(SHARED)
	@mkdir -p build
	$(OPENSCAD) -o $@ $< 2>/dev/null

$(TOPS): gallery/%.png: %.scad $(SHARED)
	@mkdir -p gallery
	$(OPENSCAD) --render $(IMG) $(TOP_CAM) -o $@ $< 2>/dev/null

$(ISOS): gallery/%_3d.png: %.scad $(SHARED)
	@mkdir -p gallery
	$(OPENSCAD) --render $(IMG) $(ISO_CAM) -o $@ $< 2>/dev/null

$(THUMBS): gallery/thumb/%.png: gallery/%.png
	@mkdir -p gallery/thumb
	convert $< -resize 320x320 $@

$(INDEX): $(addsuffix .scad,$(PATTERNS)) gen_index.py
	python3 gen_index.py

verify:                                       ## check every pattern is one solid (Volumes: 2)
	@fail=0; for p in $(PATTERNS); do \
	  v=$$($(OPENSCAD) -o /tmp/_sashiko_verify.stl $$p.scad 2>&1 | grep -i volumes | grep -oE '[0-9]+'); \
	  if [ "$$v" != "2" ]; then echo "  FAIL $$p (Volumes $$v)"; fail=1; fi; \
	done; \
	if [ $$fail -eq 0 ]; then echo "OK - all $(words $(PATTERNS)) patterns render Volumes: 2"; \
	else echo "Some patterns are not one connected solid."; exit 1; fi

clean:                                         ## remove build/ and gallery/ (all generated)
	rm -rf build gallery

help:                                          ## show this help
	@grep -hE '^[a-z][a-z-]*:.*##' $(MAKEFILE_LIST) | sed -E 's/:[^#]*## /\t/' | sort
