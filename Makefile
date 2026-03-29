# alerts-normalize test suite
#
# Targets:
#   test                  — run all tests
#   test-pandoc           — plain Pandoc path (11 cases)
#   test-quarto           — forced Quarto path via out-format: quarto-format (6 cases)
#   test-quarto-pandoc    — Quarto runner + out-format: pandoc-format (5 cases, requires quarto)
#   test-roundtrip        — round-trip through all readable formats via pandoc-md

FILTER        = alerts-normalize.lua
INPUT_DIR     = test/input
EXPECTED      = test/expected
META_PANDOC   = $(INPUT_DIR)/alert-normalize-pandoc-mode.yaml
META_QUARTO   = $(INPUT_DIR)/alert-normalize-quarto-mode.yaml

# strips pandoc-api-version from JSON output before comparing
STRIP_VER = python3 -c "import sys,json; d=json.load(sys.stdin); d.pop('pandoc-api-version',None); d.pop('meta',None); print(json.dumps(d))"

# convert md through a format and back to pandoc-md
STEP = pandoc -f markdown -t markdown --lua-filter=$(FILTER) --metadata alerts-normalize

.PHONY: test test-pandoc test-quarto test-quarto-pandoc test-roundtrip \
        test-pandoc-basic test-pandoc-empty test-pandoc-multipara \
        test-pandoc-rich test-pandoc-passthrough \
        test-pandoc-title test-pandoc-collapse test-pandoc-title-only \
        test-pandoc-custom-type test-pandoc-pandoc-md-source \
        test-pandoc-quarto-titled \
        test-quarto-basic test-quarto-empty test-quarto-multipara \
        test-quarto-rich test-quarto-passthrough test-quarto-titled \
        test-quarto-pandoc-basic test-quarto-pandoc-empty \
        test-quarto-pandoc-multipara test-quarto-pandoc-rich \
        test-quarto-pandoc-passthrough \
        test-roundtrip-quarto test-roundtrip-github \
        test-roundtrip-obsidian test-roundtrip-quarto-source \
        test-roundtrip-title test-roundtrip-collapse \
        generate generate-pandoc generate-quarto

test: test-pandoc test-quarto test-quarto-pandoc test-roundtrip

# --- Plain Pandoc tests ---

test-pandoc: test-pandoc-basic test-pandoc-empty test-pandoc-multipara \
             test-pandoc-rich test-pandoc-passthrough \
             test-pandoc-title test-pandoc-collapse test-pandoc-title-only \
             test-pandoc-custom-type test-pandoc-pandoc-md-source \
             test-pandoc-quarto-titled

test-pandoc-basic:
	@echo -n "test-pandoc-basic: "
	@pandoc $(INPUT_DIR)/alert-normalize.md \
	  --lua-filter=$(FILTER) -t json \
	| $(STRIP_VER) | diff - $(EXPECTED)/alert-normalize-pandoc.json
	@echo "OK"

test-pandoc-empty:
	@echo -n "test-pandoc-empty: "
	@pandoc $(INPUT_DIR)/alert-normalize-empty.md \
	  --lua-filter=$(FILTER) -t json \
	| $(STRIP_VER) | diff - $(EXPECTED)/alert-normalize-empty-pandoc.json
	@echo "OK"

test-pandoc-multipara:
	@echo -n "test-pandoc-multipara: "
	@pandoc $(INPUT_DIR)/alert-normalize-multipara.md \
	  --lua-filter=$(FILTER) -t json \
	| $(STRIP_VER) | diff - $(EXPECTED)/alert-normalize-multipara-pandoc.json
	@echo "OK"

test-pandoc-rich:
	@echo -n "test-pandoc-rich: "
	@pandoc $(INPUT_DIR)/alert-normalize-rich.md \
	  --lua-filter=$(FILTER) -t json \
	| $(STRIP_VER) | diff - $(EXPECTED)/alert-normalize-rich-pandoc.json
	@echo "OK"

test-pandoc-passthrough:
	@echo -n "test-pandoc-passthrough: "
	@pandoc $(INPUT_DIR)/alert-normalize-passthrough.md \
	  --lua-filter=$(FILTER) -t json \
	| $(STRIP_VER) | diff - $(EXPECTED)/alert-normalize-passthrough-pandoc.json
	@echo "OK"

test-pandoc-title:
	@echo -n "test-pandoc-title: "
	@pandoc $(INPUT_DIR)/alert-normalize-title.md \
	  --lua-filter=$(FILTER) -t json \
	| $(STRIP_VER) | diff - $(EXPECTED)/alert-normalize-title-pandoc.json
	@echo "OK"

test-pandoc-collapse:
	@echo -n "test-pandoc-collapse: "
	@pandoc $(INPUT_DIR)/alert-normalize-collapse.md \
	  --lua-filter=$(FILTER) -t json \
	| $(STRIP_VER) | diff - $(EXPECTED)/alert-normalize-collapse-pandoc.json
	@echo "OK"

test-pandoc-title-only:
	@echo -n "test-pandoc-title-only: "
	@pandoc $(INPUT_DIR)/alert-normalize-title-only.md \
	  --lua-filter=$(FILTER) -t json \
	| $(STRIP_VER) | diff - $(EXPECTED)/alert-normalize-title-only-pandoc.json
	@echo "OK"

test-pandoc-custom-type:
	@echo -n "test-pandoc-custom-type: "
	@pandoc $(INPUT_DIR)/alert-normalize-custom-type.md \
	  --lua-filter=$(FILTER) -t json \
	| $(STRIP_VER) | diff - $(EXPECTED)/alert-normalize-custom-type-pandoc.json
	@echo "OK"

test-pandoc-pandoc-md-source:
	@echo -n "test-pandoc-pandoc-md-source: "
	@pandoc $(INPUT_DIR)/alert-normalize-pandoc-md-source.md \
	  --lua-filter=$(FILTER) -t json \
	| $(STRIP_VER) | diff - $(EXPECTED)/alert-normalize-pandoc-md-source-pandoc.json
	@echo "OK"

test-pandoc-quarto-titled:
	@echo -n "test-pandoc-quarto-titled: "
	@pandoc $(INPUT_DIR)/alert-normalize-quarto-titled.md \
	  --lua-filter=$(FILTER) -t json \
	| $(STRIP_VER) | diff - $(EXPECTED)/alert-normalize-quarto-titled-pandoc.json
	@echo "OK"

# --- Quarto forced via out-format: quarto-format ---

test-quarto: test-quarto-basic test-quarto-empty test-quarto-multipara \
             test-quarto-rich test-quarto-passthrough test-quarto-titled

test-quarto-basic:
	@echo -n "test-quarto-basic: "
	@pandoc $(INPUT_DIR)/alert-normalize.md \
	  --lua-filter=$(FILTER) --metadata-file=$(META_QUARTO) -t json \
	| $(STRIP_VER) | diff - $(EXPECTED)/alert-normalize-quarto.json
	@echo "OK"

test-quarto-empty:
	@echo -n "test-quarto-empty: "
	@pandoc $(INPUT_DIR)/alert-normalize-empty.md \
	  --lua-filter=$(FILTER) --metadata-file=$(META_QUARTO) -t json \
	| $(STRIP_VER) | diff - $(EXPECTED)/alert-normalize-empty-quarto.json
	@echo "OK"

test-quarto-multipara:
	@echo -n "test-quarto-multipara: "
	@pandoc $(INPUT_DIR)/alert-normalize-multipara.md \
	  --lua-filter=$(FILTER) --metadata-file=$(META_QUARTO) -t json \
	| $(STRIP_VER) | diff - $(EXPECTED)/alert-normalize-multipara-quarto.json
	@echo "OK"

test-quarto-rich:
	@echo -n "test-quarto-rich: "
	@pandoc $(INPUT_DIR)/alert-normalize-rich.md \
	  --lua-filter=$(FILTER) --metadata-file=$(META_QUARTO) -t json \
	| $(STRIP_VER) | diff - $(EXPECTED)/alert-normalize-rich-quarto.json
	@echo "OK"

test-quarto-passthrough:
	@echo -n "test-quarto-passthrough: "
	@pandoc $(INPUT_DIR)/alert-normalize-passthrough.md \
	  --lua-filter=$(FILTER) --metadata-file=$(META_QUARTO) -t json \
	| $(STRIP_VER) | diff - $(EXPECTED)/alert-normalize-passthrough-quarto.json
	@echo "OK"

test-quarto-titled:
	@echo -n "test-quarto-titled: "
	@pandoc $(INPUT_DIR)/alert-normalize-quarto-titled.md \
	  --lua-filter=$(FILTER) --metadata-file=$(META_QUARTO) -t json \
	| $(STRIP_VER) | diff - $(EXPECTED)/alert-normalize-quarto-titled-quarto.json
	@echo "OK"

# --- Quarto runner + out-format: pandoc-format (requires quarto) ---

test-quarto-pandoc: test-quarto-pandoc-basic test-quarto-pandoc-empty \
                    test-quarto-pandoc-multipara test-quarto-pandoc-rich \
                    test-quarto-pandoc-passthrough

test-quarto-pandoc-basic:
	@echo -n "test-quarto-pandoc-basic: "
	@quarto pandoc $(INPUT_DIR)/alert-normalize.md \
	  --lua-filter=$(FILTER) --metadata-file=$(META_PANDOC) -t json \
	| $(STRIP_VER) | diff - $(EXPECTED)/alert-normalize-pandoc.json
	@echo "OK"

test-quarto-pandoc-empty:
	@echo -n "test-quarto-pandoc-empty: "
	@quarto pandoc $(INPUT_DIR)/alert-normalize-empty.md \
	  --lua-filter=$(FILTER) --metadata-file=$(META_PANDOC) -t json \
	| $(STRIP_VER) | diff - $(EXPECTED)/alert-normalize-empty-pandoc.json
	@echo "OK"

test-quarto-pandoc-multipara:
	@echo -n "test-quarto-pandoc-multipara: "
	@quarto pandoc $(INPUT_DIR)/alert-normalize-multipara.md \
	  --lua-filter=$(FILTER) --metadata-file=$(META_PANDOC) -t json \
	| $(STRIP_VER) | diff - $(EXPECTED)/alert-normalize-multipara-pandoc.json
	@echo "OK"

test-quarto-pandoc-rich:
	@echo -n "test-quarto-pandoc-rich: "
	@quarto pandoc $(INPUT_DIR)/alert-normalize-rich.md \
	  --lua-filter=$(FILTER) --metadata-file=$(META_PANDOC) -t json \
	| $(STRIP_VER) | diff - $(EXPECTED)/alert-normalize-rich-pandoc.json
	@echo "OK"

test-quarto-pandoc-passthrough:
	@echo -n "test-quarto-pandoc-passthrough: "
	@quarto pandoc $(INPUT_DIR)/alert-normalize-passthrough.md \
	  --lua-filter=$(FILTER) --metadata-file=$(META_PANDOC) -t json \
	| $(STRIP_VER) | diff - $(EXPECTED)/alert-normalize-passthrough-pandoc.json
	@echo "OK"

# --- Round-trip tests via pandoc-md intermediate ---
#
# Readable formats only: github, obsidian, quarto.
# pandoc-format is write-only — no reader, not included in roundtrip.

ROUNDTRIP_INPUTS = $(INPUT_DIR)/alert-normalize.md \
                   $(INPUT_DIR)/alert-normalize-empty.md \
                   $(INPUT_DIR)/alert-normalize-multipara.md \
                   $(INPUT_DIR)/alert-normalize-rich.md

ROUNDTRIP_FORMATS = quarto-format github-format obsidian-format

test-roundtrip: test-roundtrip-quarto test-roundtrip-github \
                test-roundtrip-obsidian test-roundtrip-quarto-source \
                test-roundtrip-title test-roundtrip-collapse

test-roundtrip-quarto:
	@echo -n "test-roundtrip-quarto: "
	@for f in $(ROUNDTRIP_INPUTS); do \
	  pandoc $$f --lua-filter=$(FILTER) --metadata alerts-normalize=pandoc-md \
	    -t markdown --wrap=none > /tmp/rt-orig.md; \
	  $(STEP)=quarto-format -t markdown --wrap=none < /tmp/rt-orig.md \
	    | $(STEP)=pandoc-md -t markdown --wrap=none > /tmp/rt-trip.md; \
	  diff /tmp/rt-orig.md /tmp/rt-trip.md || { echo "FAIL: $$f"; exit 1; }; \
	done
	@echo "OK"

test-roundtrip-github:
	@echo -n "test-roundtrip-github: "
	@for f in $(ROUNDTRIP_INPUTS); do \
	  pandoc $$f --lua-filter=$(FILTER) --metadata alerts-normalize=pandoc-md \
	    -t markdown --wrap=none > /tmp/rt-orig.md; \
	  $(STEP)=github-format -t markdown --wrap=none < /tmp/rt-orig.md \
	    | $(STEP)=pandoc-md -t markdown --wrap=none > /tmp/rt-trip.md; \
	  diff /tmp/rt-orig.md /tmp/rt-trip.md || { echo "FAIL: $$f"; exit 1; }; \
	done
	@echo "OK"

test-roundtrip-obsidian:
	@echo -n "test-roundtrip-obsidian: "
	@for f in $(ROUNDTRIP_INPUTS); do \
	  pandoc $$f --lua-filter=$(FILTER) --metadata alerts-normalize=pandoc-md \
	    -t markdown --wrap=none > /tmp/rt-orig.md; \
	  $(STEP)=obsidian-format -t markdown --wrap=none < /tmp/rt-orig.md \
	    | $(STEP)=pandoc-md -t markdown --wrap=none > /tmp/rt-trip.md; \
	  diff /tmp/rt-orig.md /tmp/rt-trip.md || { echo "FAIL: $$f"; exit 1; }; \
	done
	@echo "OK"

test-roundtrip-quarto-source:
	@echo -n "test-roundtrip-quarto-source: "
	@for f in $(INPUT_DIR)/alert-normalize-quarto-titled.md $(ROUNDTRIP_INPUTS); do \
	  pandoc $$f --lua-filter=$(FILTER) --metadata alerts-normalize=pandoc-md \
	    -t markdown --wrap=none > /tmp/rt-orig.md; \
	  $(STEP)=quarto-format -t markdown --wrap=none < /tmp/rt-orig.md \
	    | $(STEP)=pandoc-md -t markdown --wrap=none > /tmp/rt-trip.md; \
	  diff /tmp/rt-orig.md /tmp/rt-trip.md || { echo "FAIL: $$f"; exit 1; }; \
	done
	@echo "OK"

test-roundtrip-title:
	@echo -n "test-roundtrip-title: "
	@pandoc $(INPUT_DIR)/alert-normalize-title.md --lua-filter=$(FILTER) \
	  --metadata alerts-normalize=pandoc-md -t markdown --wrap=none > /tmp/rt-orig.md; \
	for fmt in $(ROUNDTRIP_FORMATS); do \
	  $(STEP)=$$fmt -t markdown --wrap=none < /tmp/rt-orig.md \
	    | $(STEP)=pandoc-md -t markdown --wrap=none > /tmp/rt-trip.md; \
	  diff /tmp/rt-orig.md /tmp/rt-trip.md || { echo "FAIL: $$fmt"; exit 1; }; \
	done
	@echo "OK"

test-roundtrip-collapse:
	@echo -n "test-roundtrip-collapse: "
	@pandoc $(INPUT_DIR)/alert-normalize-collapse.md --lua-filter=$(FILTER) \
	  --metadata alerts-normalize=pandoc-md -t markdown --wrap=none > /tmp/rt-orig.md; \
	for fmt in $(ROUNDTRIP_FORMATS); do \
	  $(STEP)=$$fmt -t markdown --wrap=none < /tmp/rt-orig.md \
	    | $(STEP)=pandoc-md -t markdown --wrap=none > /tmp/rt-trip.md; \
	  diff /tmp/rt-orig.md /tmp/rt-trip.md || { echo "FAIL: $$fmt"; exit 1; }; \
	done
	@echo "OK"

# --- Generate expected files ---

generate: generate-pandoc generate-quarto

generate-pandoc:
	@echo "Generating pandoc expected files..."
	@for f in alert-normalize alert-normalize-empty alert-normalize-multipara \
	           alert-normalize-rich alert-normalize-passthrough \
	           alert-normalize-title alert-normalize-collapse \
	           alert-normalize-title-only alert-normalize-custom-type \
	           alert-normalize-pandoc-md-source alert-normalize-quarto-titled; do \
	  echo -n "  $$f: "; \
	  pandoc $(INPUT_DIR)/$$f.md --lua-filter=$(FILTER) -t json \
	  | $(STRIP_VER) > $(EXPECTED)/$$f-pandoc.json && echo "OK"; \
	done

generate-quarto:
	@echo "Generating quarto expected files..."
	@for f in alert-normalize alert-normalize-empty alert-normalize-multipara \
	           alert-normalize-rich alert-normalize-passthrough \
	           alert-normalize-quarto-titled; do \
	  echo -n "  $$f: "; \
	  pandoc $(INPUT_DIR)/$$f.md --lua-filter=$(FILTER) \
	    --metadata-file=$(META_QUARTO) -t json \
	  | $(STRIP_VER) > $(EXPECTED)/$$f-quarto.json && echo "OK"; \
	done
