# Changelog

## [1.1.0] — 2026-03-29

### Added

- **Custom type remapping**: allow mapping one callout type to another via frontmatter, e.g.:

```yaml
alerts-normalize:
  out-format: pandoc-format
  custom-types:
    - info: note
```

This remaps info alerts to note during normalization.

## \[1.0.0]

### Architecture

The filter was rewritten from scratch around a two-stage pipeline:

* **Stage 1 — Normalize**: each reader (`normalize_github`, `normalize_div`) converts its input format into a canonical intermediate div with `kind`, `title`, and `collapse` attributes. No output format knowledge needed.
* **Stage 2 — Write**: `write_callout` dispatches to the correct writer via a `Writers` table keyed by `Container` enum. Each writer only knows its own syntax.

This replaces the original single-function approach (`make_div`) that mixed reading, normalizing, and writing into one path with two hardcoded outputs. The new design makes adding a format a matter of adding one row to `FormatDefaults` and one writer function, with no changes to existing code.

### Breaking changes

* Metadata key redesigned. The old boolean-flag form (`quarto-format: true`) is replaced by a clean string or nested map:

  ```yaml
  # simple string — works on command line and in frontmatter
  alerts-normalize: pandoc-format

  # nested map — for additional options
  alerts-normalize:
    out-format: pandoc-format
    custom-types:
      - spoiler
      - exercise
  ```

### Added

* **10 output formats**: `quarto-format`, `pandoc-format`, `pandoc-md`, `github-format`, `obsidian-format`, `mkdocs-format`, `myst-format`, `sphinx-format`, `hugo-format`, `docusaurus-format`, `vitepress-format`.
* **`pandoc-md` intermediate format**: attribute-based div representation for round-trip pipelines between readable formats.
* **Collapse support**: `[!NOTE]-` (collapsed) and `[!NOTE]+` (expanded) markers are normalized to `collapse="true/false"` and round-trip correctly through all readable formats. Write-only formats use their native collapse syntax (`???` for MkDocs, `dropdown` for MyST, `:::details` for VitePress/Docusaurus).
* **Inline title capture**: `> [!NOTE] My title` extracts the title correctly from the marker line.
* **Any casing accepted**: `[!NOTE]`, `[!Note]`, `[!note]` all normalize identically.
* **Quarto div normalizer**: `:::{.callout-*}` divs are read and converted to the intermediate format, enabling Quarto → any format pipelines.
* **Pandoc 3.9 / Sphinx normalizer**: `:::{.note}` plain classed divs with optional `.title` child or `title=` attribute are recognized.
* **Extended callout type whitelist**: 25 built-in types covering all major ecosystems (Obsidian, MkDocs, MyST, Sphinx, VitePress).
* **`custom-types`** frontmatter option: add types beyond the built-in whitelist without modifying the filter.
* **Quarto source roundtrip**: `quarto-format` → `pandoc-md` → `quarto-format` verified to produce identical output.
* **Test metadata files** updated to new `out-format` nested form.
* **Dispatcher pattern**: one `write_callout` entry point routes to the correct writer via a `Writers` table keyed by container type.

### Changed

* Title handling mimics pandoc 3.9: the `.title` Div child is only inserted when the user explicitly sets a title. No auto-generation from the type name.
* `write_blockquote` produces pure AST objects — `RawInline("markdown", ...)` for the marker prevents Pandoc from escaping `[` as `\[`, and `BlockQuote` wraps the content instead of `RawBlock` markdown text. Enables correct round-trip parsing.
* Format defaults extracted into a `FormatDefaults` table — no more `if/elseif` chain.
* Magic strings replaced by `TypeCase` and `Container` enums with runtime error protection against typos.

## \[0.1.0]

* Converts `> [!WORD]` GitHub alert blockquotes to classed Divs.
* Two output paths: Quarto (`callout-*` class + `title` attribute) and plain Pandoc (bare class + `.title` Div child).
* Auto-detects Quarto via the `quarto` global.
* Accepts uppercase `[!NOTE]` markers only.
* Per-document options via `quarto-format: true` / `pandoc-format: true` flags.
