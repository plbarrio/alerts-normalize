--[[
alerts-normalize.lua - converts alert blockquotes to classed Divs.

Converts any > [!WORD] blockquote to a normalized intermediate Div,
then writes it in the target format.

Accepts any casing: [!NOTE], [!Note], [!note], etc.
Captures inline title:   > [!NOTE] My Title
Captures collapse:       > [!NOTE]-  collapsed,  > [!NOTE]+  expanded

Normalizers (read formats):
  - GitHub / Obsidian  > [!WORD]
  - Quarto             :::{.callout-*}
  - Pandoc 3.9         :::{.note} + optional Div.title child
  - Sphinx             .. note:: (arrives identical to Pandoc via RST reader)

Write-only formats (no reader — content collapses to plain Para in Pandoc AST):
  - MyST, MkDocs, Hugo, Docusaurus, VitePress

Per-document options (in frontmatter):

  alerts-normalize: pandoc-format   # simple string form, also works on command line

  alerts-normalize:                 # nested form for additional options
    out-format: pandoc-format
    custom-types:
      - spoiler
      - exercise

See copyright notice in file LICENSE.
]]

PANDOC_VERSION:must_be_at_least({ 2, 19, 1 })


-- # Enums

local function make_enum(values)
  return setmetatable(values, {
    __index = function(_, key)
      error('Invalid enum value: ' .. tostring(key), 2)
    end,
    __newindex = function()
      error('Enums are read-only', 2)
    end,
  })
end

local TypeCase = make_enum {
  upper    = 'upper',
  lower    = 'lower',
  preserve = 'preserve',
}

local Container = make_enum {
  div        = 'Div',
  blockquote = 'BlockQuote',
  fence      = 'Fence',
  admonition = 'Admonition',
  directive  = 'Directive',
  shortcode  = 'Shortcode',
  colon      = 'Colon',
}


-- # Format defaults

local FormatDefaults = {
  ['quarto-format']     = { HasTitle=true,  Collapse=true,  Container=Container.div,        TypeCase=TypeCase.lower,    Prefix='callout-' },
  ['github-format']     = { HasTitle=false, Collapse=true,  Container=Container.blockquote, TypeCase=TypeCase.upper },
  ['obsidian-format']   = { HasTitle=false, Collapse=true,  Container=Container.blockquote, TypeCase=TypeCase.upper },
  ['mkdocs-format']     = { HasTitle=true,  Collapse=true,  Container=Container.admonition, TypeCase=TypeCase.lower },
  ['myst-format']       = { HasTitle=true,  Collapse=true,  Container=Container.fence,      TypeCase=TypeCase.preserve },
  ['sphinx-format']     = { HasTitle=true,  Collapse=nil,   Container=Container.directive,  TypeCase=TypeCase.lower },
  ['hugo-format']       = { HasTitle=true,  Collapse=nil,   Container=Container.shortcode,  TypeCase=TypeCase.lower },
  ['pandoc-format']     = { HasTitle=true,  Collapse=nil,   Container=Container.div,        TypeCase=TypeCase.lower },
  ['pandoc-md']         = { HasTitle=true,  Collapse=nil,   Container=Container.div,        TypeCase=TypeCase.lower },
  ['docusaurus-format'] = { HasTitle=true,  Collapse=true,  Container=Container.colon,      TypeCase=TypeCase.lower },
  ['vitepress-format']  = { HasTitle=true,  Collapse=true,  Container=Container.colon,      TypeCase=TypeCase.upper },
}


-- # State

local out_format
local write_rules


-- # Helpers

local function get_type(div)
  return div.classes[1] or 'note'
end

local function format_type(type_str)
  if write_rules.TypeCase == TypeCase.lower then
    return type_str:lower()
  elseif write_rules.TypeCase == TypeCase.upper then
    return type_str:upper()
  else
    return type_str
  end
end

local function indent_content(blocks)
  local raw = pandoc.write(pandoc.Pandoc(blocks), 'markdown')
  local indented = raw:gsub('([^\n]+)', '    %1')
  return pandoc.RawBlock('markdown', indented)
end


-- # Writers

local function write_div(div)
  local kind  = format_type(get_type(div))
  local title = div.attributes.title  -- nil if absent, '' if explicitly empty
  if out_format == 'pandoc-md' then
    -- intermediate: class only, preserve title attribute as-is
    div.classes = { kind }
    return div
  elseif write_rules.Prefix then
    -- Quarto: omit title attribute if nil, Quarto auto-generates from class
    div.classes = { write_rules.Prefix .. kind }
    if title and title ~= '' then
      div.attributes.title = title
    else
      div.attributes.title = nil
    end
    return div
  else
    -- pandoc-format: mimic pandoc 3.9 — only insert .title Div if explicitly set
    div.classes = { kind }
    div.attributes.title = nil
    if title and title ~= '' then
      div.content:insert(1, pandoc.Div(
        { pandoc.Para({ pandoc.Str(title) }) },
        pandoc.Attr('', { 'title' })
      ))
    end
    return div
  end
end

local function write_blockquote(div)
  local kind     = format_type(get_type(div))
  local title    = div.attributes.title
  local collapse = div.attributes.collapse
  local suffix   = write_rules.Collapse
    and (collapse == 'true' and '-' or collapse == 'false' and '+' or '')
    or ''
  -- marker as RawInline to prevent Pandoc from escaping the brackets
  local marker_inlines = pandoc.List({ pandoc.RawInline('markdown', '[!' .. kind .. ']' .. suffix) })
  if title and title ~= '' then
    marker_inlines:insert(pandoc.Space())
    for _, il in ipairs(pandoc.read(title).blocks[1].content) do
      marker_inlines:insert(il)
    end
  end
  -- marker gets its own Para so SoftBreak does not collapse into a space
  -- GitHub accepts '> [!NOTE]\n>\n> Body' -- blank line between marker and body is valid
  local bq_blocks = pandoc.Blocks({ pandoc.Para(marker_inlines) })
  for _, b in ipairs(div.content) do bq_blocks:insert(b) end
  return pandoc.BlockQuote(bq_blocks)
end

local function write_fence(div)
  local kind     = format_type(get_type(div))
  local title    = write_rules.HasTitle and (div.attributes.title or '') or ''
  local collapse = write_rules.Collapse and div.attributes.collapse == 'true'
  local cls      = collapse and 'dropdown' or kind
  local open     = pandoc.RawBlock('markdown', '```{' .. cls .. '} ' .. title)
  local close    = pandoc.RawBlock('markdown', '```')
  return { open, table.unpack(div.content), close }
end

local function write_admonition(div)
  local kind     = format_type(get_type(div))
  local title    = write_rules.HasTitle and (' "' .. (div.attributes.title or '') .. '"') or ''
  local collapse = write_rules.Collapse and div.attributes.collapse == 'true'
  local marker   = collapse and '???' or '!!!'
  local open     = pandoc.RawBlock('markdown', marker .. ' ' .. kind .. title)
  return { open, indent_content(div.content) }
end

local function write_directive(div)
  local kind  = format_type(get_type(div))
  local title = write_rules.HasTitle and (div.attributes.title or '') or ''
  local open  = pandoc.RawBlock('rst', '.. ' .. kind .. ':: ' .. title)
  return { open, indent_content(div.content) }
end

local function write_shortcode(div)
  local kind  = format_type(get_type(div))
  local open  = pandoc.RawBlock('html', '{{< callout ' .. kind .. ' >}}')
  local close = pandoc.RawBlock('html', '{{< /callout >}}')
  return { open, table.unpack(div.content), close }
end

local function write_colon(div)
  local kind     = format_type(get_type(div))
  local title    = write_rules.HasTitle and (div.attributes.title or '') or ''
  local collapse = write_rules.Collapse and div.attributes.collapse == 'true'
  local open     = collapse
    and pandoc.RawBlock('markdown', ':::details ' .. title)
    or  pandoc.RawBlock('markdown', ':::' .. kind .. ' ' .. title)
  local close    = pandoc.RawBlock('markdown', ':::')
  return { open, table.unpack(div.content), close }
end


-- # Dispatcher

local Writers = {
  [Container.div]        = write_div,
  [Container.blockquote] = write_blockquote,
  [Container.fence]      = write_fence,
  [Container.admonition] = write_admonition,
  [Container.directive]  = write_directive,
  [Container.shortcode]  = write_shortcode,
  [Container.colon]      = write_colon,
}

local function write_callout(div)
  local writer = Writers[write_rules.Container]
  if not writer then
    error('No writer for container: ' .. tostring(write_rules.Container), 2)
  end
  return writer(div)
end


-- # Normalizers

--- Known callout types for Pandoc/Sphinx plain div detection.
local CalloutTypes = {
  -- core (all formats)
  note=true, warning=true, tip=true, caution=true, important=true,
  -- extended (obsidian, mkdocs, admonition ecosystems)
  info=true, success=true, question=true, failure=true, danger=true,
  bug=true, example=true, quote=true, abstract=true, hint=true,
  check=true, done=true, error=true, help=true, faq=true,
  attention=true,
  -- sphinx/myst
  seealso=true, todo=true,
  -- vitepress
  details=true,
}

local function make_div(kind, blocks, title, collapse)
  local attrs = {}
  if title and title ~= '' then attrs.title = title end
  if collapse == true  then attrs.collapse = 'true'  end
  if collapse == false then attrs.collapse = 'false' end
  return pandoc.Div(blocks, pandoc.Attr('', { kind }, attrs))
end

--- GitHub / Obsidian: > [!WORD] or > [!word] — any casing accepted.
--- [!NOTE]+ expanded, [!NOTE]- collapsed.
local function normalize_github(bq)
  if out_format == 'github-format' or out_format == 'obsidian-format' then return nil end
  local first = bq.content[1]
  if not first or first.t ~= 'Para' then return nil end
  local marker = first.content[1]
  if not marker or (marker.t ~= 'Str' and marker.t ~= 'RawInline') then return nil end
  local kind, suffix = marker.text:match('^%[!([%a]+)%]([+-]?)$')
  if not kind then return nil end
  kind = kind:lower()
  local collapse
  if suffix == '-' then collapse = true
  elseif suffix == '+' then collapse = false
  end
  local inlines = pandoc.List(first.content)
  inlines:remove(1) -- remove [!WORD] marker
  local blocks = pandoc.Blocks({})
  local title
  if inlines[1] and inlines[1].t == 'Space' then
    -- > [!NOTE] Inline title / > [!NOTE] Inline title\n> Body
    inlines:remove(1)
    -- title is only the inlines before the first SoftBreak
    local title_inlines = pandoc.List({})
    while #inlines > 0 and inlines[1].t ~= 'SoftBreak' do
      title_inlines:insert(inlines:remove(1))
    end
    if inlines[1] and inlines[1].t == 'SoftBreak' then
      inlines:remove(1) -- remove the SoftBreak
    end
    if #title_inlines > 0 then
      title = pandoc.utils.stringify(title_inlines)
    end
    if #inlines > 0 then blocks:insert(pandoc.Para(inlines)) end
  elseif inlines[1] and inlines[1].t == 'SoftBreak' then
    -- > [!NOTE]
    -- > Body on next line
    inlines:remove(1)
    if #inlines > 0 then blocks:insert(pandoc.Para(inlines)) end
  end
  for i = 2, #bq.content do blocks:insert(bq.content[i]) end
  return write_callout(make_div(kind, blocks, title, collapse))
end

--- Quarto / Pandoc 3.9 / Sphinx / pandoc-md divs.
local function normalize_div(div)
  -- Quarto: :::{.callout-*} — title and collapse already in attributes
  if out_format ~= 'quarto-format' then
    local kind = div.classes[1] and div.classes[1]:match('^callout%-(.+)$')
    if kind then
      div.classes = { kind }
      return write_callout(div)
    end
  end
  -- Pandoc 3.9 / Sphinx / pandoc-md: :::{.note} — title from attribute or .title child
  if out_format ~= 'sphinx-format' and out_format ~= 'pandoc-format'
     and out_format ~= 'pandoc-md' then
    local kind = div.classes[1]
    if kind and CalloutTypes[kind] then
      local title    = div.attributes.title or nil
      local collapse_str = div.attributes.collapse
      local collapse = collapse_str == 'true' and true or nil
      if collapse_str == 'false' then collapse = false end
      local blocks = pandoc.Blocks({})
      for _, block in ipairs(div.content) do
        if block.t == 'Div' and block.classes[1] == 'title' then
          title = pandoc.utils.stringify(block.content)
        else
          blocks:insert(block)
        end
      end
      return write_callout(make_div(kind, blocks, title, collapse))
    end
  end
end


-- # Entry point

local function process_metadata(meta)
  local cfg = meta['alerts-normalize']

  if not cfg then
    -- auto-detect
    out_format = quarto ~= nil and 'quarto-format' or 'pandoc-format'
  elseif type(cfg) == 'string' then
    -- alerts-normalize: pandoc-format
    out_format = cfg
  else
    -- alerts-normalize:
    --   out-format: pandoc-format
    --   custom-types:
    --     - spoiler
    local fmt = cfg['out-format']
    out_format = fmt and pandoc.utils.stringify(fmt)
                      or (quarto ~= nil and 'quarto-format' or 'pandoc-format')
    local types = cfg['custom-types']
    if types then
      for _, v in ipairs(types) do
        CalloutTypes[pandoc.utils.stringify(v)] = true
      end
    end
  end

  write_rules = FormatDefaults[out_format] or FormatDefaults['pandoc-format']
end

return {
  { Meta       = process_metadata },
  { BlockQuote = normalize_github },
  { Div        = normalize_div },
}
