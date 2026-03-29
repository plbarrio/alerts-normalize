# --- Configuration -----------------------------------------
FILTERS       = --lua-filter=../alerts-normalize.lua
INPUTS        = $(filter-out README.md, $(wildcard *.md))
OUTDIR        = output/pandoc
QOUTDIR       = output/quarto

# Target lists (Filenames only)
HTMLS        = $(INPUTS:.md=.html)
EPUBS        = $(INPUTS:.md=.epub)
PDFS_LATEX   = $(INPUTS:.md=-latex.pdf)
PDFS_TYPST   = $(INPUTS:.md=-typst.pdf)

.PHONY: all pandoc quarto html epub \
        pdf-latex-quarto pdf-typst-quarto html-quarto epub-quarto \
        clean

all: pandoc quarto

# --- Grouped targets ---------------------------------------
pandoc: html epub

quarto: html-quarto epub-quarto
	-$(MAKE) pdf-latex-quarto
	-$(MAKE) pdf-typst-quarto

# --- Target mapping -----------
html:              $(addprefix $(OUTDIR)/,$(HTMLS))
epub:              $(addprefix $(OUTDIR)/,$(EPUBS))

html-quarto:       $(addprefix $(QOUTDIR)/,$(HTMLS))
epub-quarto:       $(addprefix $(QOUTDIR)/,$(EPUBS))
pdf-latex-quarto:  $(addprefix $(QOUTDIR)/,$(PDFS_LATEX))
pdf-typst-quarto:  $(addprefix $(QOUTDIR)/,$(PDFS_TYPST))

$(OUTDIR) $(QOUTDIR):
	mkdir -p $@

# --- Pandoc rules ------------
$(OUTDIR)/%.html: %.md | $(OUTDIR)
	-pandoc $(FILTERS) --standalone --embed-resources --css=./demo.css -o $@ $<

$(OUTDIR)/%.epub: %.md | $(OUTDIR)
	-pandoc $(FILTERS) --css=./demo.css -o $@ $<

# --- Quarto rules  ------------
$(QOUTDIR)/%-latex.pdf: %.md | $(QOUTDIR)
	-quarto render $< --to pdf --pdf-engine=lualatex --output-dir=$(QOUTDIR) --output $(notdir $@)

$(QOUTDIR)/%-typst.pdf: %.md | $(QOUTDIR)
	-quarto render $< --to typst --output-dir=$(QOUTDIR) --output $(notdir $@)

$(QOUTDIR)/%.html: %.md | $(QOUTDIR)
	-quarto render $< --to html --output-dir=$(QOUTDIR)

$(QOUTDIR)/%.epub: %.md | $(QOUTDIR)
	-quarto render $< --to epub --output-dir=$(QOUTDIR)

clean:
	rm -rf output

