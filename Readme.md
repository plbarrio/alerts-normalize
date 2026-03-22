# alerts-normalize.lua

[![test](https://github.com/plbarrio/alerts-normalize/actions/workflows/test.yml/badge.svg)](https://github.com/plbarrio/alerts-normalize/actions/workflows/test.yml)
[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
[![Pandoc](https://img.shields.io/badge/pandoc-%3E%3D2.19.1-orange)](https://pandoc.org)
[![Quarto](https://img.shields.io/badge/quarto-%3E%3D1.4.0-blue)](https://quarto.org)

Pandoc Lua filter that converts GitHub alert blockquote syntax (`> [!NOTE]`,
`> [!WARNING]`, etc.) to classed Divs at the AST level. Works consistently
regardless of Markdown flavour, Pandoc version, or runner — without requiring
`-f gfm` or `+alerts` (Pandoc >= 3.9). When run inside Quarto via
`quarto render`, auto-detects and produces native `callout-*` Divs instead,
so Quarto renders styled callout boxes out of the box.

Copyright 2026 Pedro Luis Barrio under GPL-3.0-or-later, see LICENSE file
for details.

Maintained by [plbarrio](https://github.com/plbarrio).

## Requirements

Pandoc >= 2.19.1 · Quarto >= 1.4.0 (for Quarto usage)

## Usage

> [!NOTE]
> The file `alerts-normalize.lua` at the repo root is a symlink to
> [_extensions/alerts-normalize/alerts-normalize.lua](_extensions/alerts-normalize/alerts-normalize.lua).
> Plain Pandoc users
> reference the root symlink; Quarto users install via `quarto add` which
> uses `_extensions/` directly.

### Plain Pandoc

```sh
pandoc --lua-filter=alerts-normalize.lua \
       input.md -o output.pdf
```


### Quarto extension (recommended)

Install once per project:

```sh
quarto add plbarrio/alerts-normalize
```

Then declare in `_quarto.yml` at the `pre-ast` stage — required so the filter
runs before Quarto's callout processor:

```yaml
filters:
  - at: pre-ast
    path: plbarrio/alerts-normalize
```

### Quarto (manual)

Copy `alerts-normalize.lua` next to your project and declare it in `_quarto.yml`:

```yaml
filters:
  - at: pre-ast
    path: alerts-normalize.lua
```

## How it works

Any blockquote starting with `[!WORD]` is converted depending on the runner:

**Plain Pandoc** — produces a classed Div with a `Div.title` child:

```
Div.word
  Div.title
    Para "Word"
  ... remaining content ...
```

**Quarto** (`quarto render`) — auto-detected, produces a native callout Div:

```
Div.callout-word [title="Word"]
  ... remaining content ...
```

The filter must run at the `pre-ast` stage in Quarto so the converted Divs
are seen by Quarto's callout processor. Auto-detection via `quarto ~= nil`
is confirmed to work at this stage.

The five standard GitHub types are supported (`NOTE`, `TIP`, `IMPORTANT`,
`WARNING`, `CAUTION`) as well as any custom type (`SPOILER`, `EXERCISE`, etc.).

## Markdown syntax

```markdown
> [!NOTE]
> Standard GitHub alert syntax.

> [!SPOILER]
> Custom type — any uppercase word is accepted.
```

## Output

### Plain Pandoc

The filter produces classed Divs that downstream filters or writers
can render as needed. For example, as HTML:

```html
<div class="note">
  <div class="title"><p>Note</p></div>
  <p>Standard GitHub alert syntax.</p>
</div>
```
The class structure — `div.note > div.title + p` — is enough to style
alerts with plain CSS, no further tooling required.

### Quarto (all formats)

Quarto renders `Div.callout-note` as a native styled callout box — icons,
colours, and collapsible behaviour included — in HTML, PDF, EPUB, and all
other Quarto output formats.

## Configuration

Both flags are optional — in normal usage no configuration is needed.

```yaml
alerts-normalize:
  pandoc-format: true   # force Pandoc output inside quarto render
  quarto-format: true   # force Quarto/callout-* output when testing via plain pandoc
```

`pandoc-format: true` — use when running `quarto render` for a custom PDF
pipeline that handles Div rendering itself. Overrides auto-detection.

`quarto-format: true` — only needed for testing the Quarto path via plain `pandoc`
without `quarto render`. Not needed in normal usage.

## Features

- Works with any Pandoc version >= 2.19.1 — no `+alerts` extension needed
- Works in Quarto — auto-detects and produces native callouts
- Works as a Quarto extension — `quarto add plbarrio/alerts-normalize`
- Custom alert types — any uppercase word is accepted, not just the five GitHub types
- No silent failures — unrecognised markers pass through as plain blockquotes

## Tests

```sh
make test                # all tests
make test-pandoc         # plain Pandoc path (5 cases)
make test-quarto         # Quarto path via quarto-format: true (5 cases)
make test-quarto-pandoc  # quarto pandoc + pandoc-format: true (5 cases, requires quarto)
```

Test cases cover: basic alerts, empty alert, multi-paragraph alert,
alert with rich content (lists, code), and plain blockquote passthrough.
The `test-quarto-pandoc` group verifies that `pandoc-format: true` correctly
suppresses Quarto auto-detection across all input types.

## Issues and contributing

Issues and PRs welcome at the [project repository](https://github.com/plbarrio/alerts-normalize).

## License

GPL-3.0-or-later. See [LICENSE](LICENSE.md).

