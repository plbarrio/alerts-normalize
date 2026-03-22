# Quarto example — alerts-normalize.lua
#
# Quarto auto-detected in all formats — native callout-* output throughout.
# Filter declared in _quarto.yml as ../alerts-normalize.lua
#
# Run from the examples/ directory: make html

INPUTS  = $(wildcard *.md)
OUTDIR  = output

.PHONY: all pdf-latex pdf-context pdf-typst html epub clean

all: html epub
	-$(MAKE) pdf-latex
	-$(MAKE) pdf-context
	-$(MAKE) pdf-typst

html:
	quarto render $(INPUTS) --to html --output-dir=$(OUTDIR)

epub:
	quarto render $(INPUTS) --to epub --output-dir=$(OUTDIR)

pdf-latex:
	quarto render $(INPUTS) --to pdf --pdf-engine=lualatex \
	  --output-dir=$(OUTDIR) --output demo-latex.pdf

pdf-context:
	quarto render $(INPUTS) --to pdf --pdf-engine=context \
	  --output-dir=$(OUTDIR) --output demo-context.pdf

pdf-typst:
	quarto render $(INPUTS) --to typst \
	  --output-dir=$(OUTDIR) --output demo-typst.pdf

clean:
	rm -rf $(OUTDIR)
