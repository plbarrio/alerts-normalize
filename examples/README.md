# alerts-normalize.lua — demo

This directory contains a comprehensive demo of `alerts-normalize.lua` covering
all supported input formats, output formats, and syntax variants.

## Files

- **`demo.md`**: Full showcase of all supported syntax — standard and extended
  alert types, any casing, inline titles, collapse markers, rich content
  (lists, code, tables, nested blocks), and all source formats (GitHub,
  Pandoc 3.9, Quarto).
- **`demo.css`**: GitHub Primer styles with Octicons (MIT License) embedded as
  Data URIs — generates self-contained, portable HTML.
- **`Makefile`**: Build targets for all output formats.
- **`_quarto.yml`**: Quarto project config declaring the filter at `pre-ast`.

## Building

### Pandoc (lightweight)

```sh
make html
```

Renders `demo.md` via Pandoc with `demo.css`. Fast, no Quarto required.

### Quarto (native callouts)

```sh
make html-quarto
```

Renders via `quarto render` — produces native styled callout boxes with icons,
colours, and collapse behaviour.

### All formats

```sh
make all
```

Builds both Pandoc and Quarto HTML, EPUB, and PDF outputs into `output/`.

## What the demo covers

| Section | What it tests |
|---|---|
| Standard GitHub types | `NOTE`, `TIP`, `IMPORTANT`, `WARNING`, `CAUTION` |
| Casing | `[!NOTE]`, `[!Note]`, `[!note]` |
| Extended types | 20+ types from Obsidian/MkDocs/MyST/Sphinx ecosystems |
| Inline title | `> [!NOTE] My title` |
| Collapse | `[!NOTE]-` collapsed, `[!NOTE]+` expanded |
| Collapse with title | Both markers combined |
| Rich content | Multiple paragraphs, lists, code blocks, tables, nested blocks |
| Empty alert | `> [!NOTE]` with no body |
| Passthrough | Plain blockquotes left untouched |
| Pandoc 3.9 source | `:::{.note}` plain classed divs |
| Quarto source | `:::{.callout-note}` divs |
| Custom type | Types outside the whitelist pass through unchanged |

---

*Icons from [GitHub Octicons](https://primer.style), MIT License.*
