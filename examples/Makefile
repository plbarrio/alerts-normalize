# --- Configuration -----------------------------------------
FILTERS       = --lua-filter=../alerts-normalize.lua
INPUTS        = $(filter-out README.md, $(wildcard *.md))
OUTDIR        = output/pandoc
QOUTDIR       = output/quarto

# Target lists (Filenames only)
HTMLS        = $(INPUTS:.md=.html)
EPUBS        = $(INPUTS:.md=.epub)

.PHONY: all pandoc quarto html epub \
        pdf-latex-quarto pdf-typst-quarto \
        clean

all: pandoc quarto

# --- Grouped targets ---------------------------------------
pandoc: html epub

# --- Target mapping -----------
html:  $(addprefix $(OUTDIR)/,$(HTMLS))
epub:  $(addprefix $(OUTDIR)/,$(EPUBS))

$(OUTDIR) $(QOUTDIR):
	mkdir -p $@

# --- Pandoc rules ------------
$(OUTDIR)/%.html: %.md | $(OUTDIR)
	-pandoc $(FILTERS) --standalone --embed-resources --css=./demo.css -o $@ $<

$(OUTDIR)/%.epub: %.md | $(OUTDIR)
	-pandoc $(FILTERS) --css=./demo.css -o $@ $<

# --- Quarto rules  ------------
quarto: | $(QOUTDIR)
	-quarto render demo.md --to html
	-quarto render demo.md --to epub
	-$(MAKE) pdf-latex-quarto
	-$(MAKE) pdf-typst-quarto

pdf-latex-quarto: | $(QOUTDIR)
	-quarto render demo.md --to pdf --pdf-engine=lualatex --output demo-latex.pdf

pdf-typst-quarto: | $(QOUTDIR)
	-quarto render demo.md --to typst --output demo-typst.pdf

clean:
	rm -rf output
