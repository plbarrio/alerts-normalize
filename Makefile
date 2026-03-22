# alerts-normalize test suite
#
# Targets:
#   test                  — run all tests
#   test-pandoc           — plain Pandoc path (5 cases)
#   test-quarto           — forced Quarto path via quarto-format: true (5 cases)
#   test-quarto-pandoc    — Quarto runner + pandoc-format: true (5 cases, requires quarto)

FILTER        = alerts-normalize.lua
INPUT_DIR     = test/input
EXPECTED      = test/expected
META_PANDOC   = $(INPUT_DIR)/alert-normalize-pandoc-mode.yaml
META_QUARTO   = $(INPUT_DIR)/alert-normalize-quarto-mode.yaml

# strips pandoc-api-version from JSON output before comparing
STRIP_VER = python3 -c "import sys,json; d=json.load(sys.stdin); d.pop('pandoc-api-version',None); d.pop('meta',None); print(json.dumps(d))"

.PHONY: test test-pandoc test-quarto test-quarto-pandoc \
        test-pandoc-basic test-pandoc-empty test-pandoc-multipara \
        test-pandoc-rich test-pandoc-passthrough \
        test-quarto-basic test-quarto-empty test-quarto-multipara \
        test-quarto-rich test-quarto-passthrough \
        test-quarto-pandoc-basic test-quarto-pandoc-empty \
        test-quarto-pandoc-multipara test-quarto-pandoc-rich \
        test-quarto-pandoc-passthrough \
        generate generate-pandoc generate-quarto

test: test-pandoc test-quarto test-quarto-pandoc

# --- Plain Pandoc tests ---

test-pandoc: test-pandoc-basic test-pandoc-empty test-pandoc-multipara \
             test-pandoc-rich test-pandoc-passthrough

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

# --- Quarto forced via quarto-format: true ---

test-quarto: test-quarto-basic test-quarto-empty test-quarto-multipara \
             test-quarto-rich test-quarto-passthrough

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

# --- Quarto runner + pandoc-format: true (requires quarto) ---

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

# --- Generate expected files ---

generate: generate-pandoc generate-quarto

generate-pandoc:
	@echo "Generating pandoc expected files..."
	@for f in alert-normalize alert-normalize-empty alert-normalize-multipara \
	           alert-normalize-rich alert-normalize-passthrough; do \
	  echo -n "  $$f: "; \
	  pandoc $(INPUT_DIR)/$$f.md --lua-filter=$(FILTER) -t json \
	  | $(STRIP_VER) > $(EXPECTED)/$$f-pandoc.json && echo "OK"; \
	done

generate-quarto:
	@echo "Generating quarto expected files..."
	@for f in alert-normalize alert-normalize-empty alert-normalize-multipara \
	           alert-normalize-rich alert-normalize-passthrough; do \
	  echo -n "  $$f: "; \
	  pandoc $(INPUT_DIR)/$$f.md --lua-filter=$(FILTER) \
	    --metadata-file=$(META_QUARTO) -t json \
	  | $(STRIP_VER) > $(EXPECTED)/$$f-quarto.json && echo "OK"; \
	done
