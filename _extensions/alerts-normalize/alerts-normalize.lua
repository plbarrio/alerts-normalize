--[[
alerts-normalize.lua - converts GitHub alert blockquotes to classed Divs.

Converts any > [!WORD] blockquote to a Div with the lowercased class name
and a Div.title child — the same AST as pandoc -f markdown+alerts.

When run inside Quarto (quarto render), produces callout-* classes with a
title attribute instead, so that Quarto renders native styled callout boxes.
Quarto is auto-detected via the quarto global — no configuration needed.

The filter must run at the pre-ast stage so Quarto's callout processor sees
the converted Divs. Declare it in _quarto.yml as:

  filters:
    - at: pre-ast
      path: alerts-normalize.lua

Accepts any uppercase word: NOTE, WARNING, TIP, IMPORTANT, CAUTION,
or any custom type like SPOILER, EXERCISE, etc.

Per-document options (in each file's frontmatter):
  alerts-normalize:
    pandoc-format: true   # force Pandoc/container-writer output in quarto render
    quarto-format: true   # force Quarto/callout-* output (useful for testing
                          # via plain pandoc without quarto render)

Run before container-writer.lua in plain Pandoc. No +alerts extension needed.
Works with plain Pandoc, Quarto, and collection.

See copyright notice in file LICENSE.
]]

PANDOC_VERSION:must_be_at_least({ 2, 19, 1 })


-- # Options

local Options = {
  quarto_format = nil,   -- nil = auto-detect via quarto global
                         -- true = force Quarto path (testing without quarto render)
  pandoc_format = false, -- true = force Pandoc path inside quarto render
}

local function process_metadata(meta)
  local cfg = meta['alerts-normalize']
  if not cfg then return end
  if cfg['quarto-format'] ~= nil then
    Options.quarto_format = cfg['quarto-format'] == true
  end
  if cfg['pandoc-format'] ~= nil then
    Options.pandoc_format = cfg['pandoc-format'] == true
  end
end


-- # Div builder

--- Builds the output Div, adapting to Quarto or plain Pandoc.
---
--- Resolution order:
---   1. pandoc-format: true  → always Pandoc (overrides everything)
---   2. quarto-format: true  → always Quarto (testing without quarto render)
---   3. quarto ~= nil        → Quarto (auto-detect via quarto render)
---   4. fallback             → Pandoc
---
--- @param kind   string         lowercased alert type, e.g. "note"
--- @param blocks pandoc.Blocks  content blocks (without title)
--- @return pandoc.Div
local function make_div(kind, blocks)
  local label = kind:sub(1,1):upper() .. kind:sub(2)
  local use_quarto = not Options.pandoc_format
                     and (Options.quarto_format or quarto ~= nil)
  if use_quarto then
    -- Quarto: callout-* class + title attribute, no Div.title child needed.
    return pandoc.Div(blocks, pandoc.Attr('', { 'callout-' .. kind }, { title = label }))
  else
    -- Plain Pandoc: bare class + Div.title child for container-writer.
    blocks:insert(1, pandoc.Div(
      { pandoc.Para({ pandoc.Str(label) }) },
      pandoc.Attr('', { 'title' })
    ))
    return pandoc.Div(blocks, pandoc.Attr('', { kind }))
  end
end


-- # BlockQuote handler

--- Converts a GitHub alert blockquote to a classed Div.
---
--- @param bq pandoc.BlockQuote
--- @return pandoc.Div|nil
local function handle_blockquote(bq)
  -- must start with a Para whose first Str matches [!WORD]
  local first = bq.content[1]
  if not first or first.t ~= 'Para' then return nil end
  local marker = first.content[1]
  if not marker or marker.t ~= 'Str' then return nil end
  local kind = marker.text:match('^%[!(%u+)%]$')
  if not kind then return nil end
  kind = kind:lower()

  -- strip marker and leading SoftBreak from first paragraph
  local inlines = pandoc.List(first.content)
  inlines:remove(1)
  if inlines[1] and inlines[1].t == 'SoftBreak' then inlines:remove(1) end

  -- build content blocks (without title — make_div handles that)
  local blocks = pandoc.Blocks({})
  if #inlines > 0 then blocks:insert(pandoc.Para(inlines)) end
  for i = 2, #bq.content do blocks:insert(bq.content[i]) end

  return make_div(kind, blocks)
end


-- # Entry point

return {
  { Meta       = process_metadata  },
  { BlockQuote = handle_blockquote },
}
