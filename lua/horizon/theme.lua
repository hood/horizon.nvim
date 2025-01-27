---@class horizon.Opts
---@field fg string
---@field bg string
---@field sp string
---@field bold boolean
---@field italic boolean
---@field underline boolean
---@field undercurl boolean
---@field reverse boolean
---@field standout boolean
---@field link string

---@class CustomPalette
---@field hint string
---@field info string
---@field warn string
---@field error string
---@field error_bg string
---@field warn_bg string
---@field info_bg string
---@field hint_bg string
---@field purple1 string
---@field gray string
---@field gold string
---@field blue1 string
---@field blue2 string
---@field blue3 string
---@field diff_change string
---@field diff_text string

---@alias horizon.HighlightDef {[string]: horizon.Opts}

---@alias ThemeData {theme: {[string]: horizon.Opts}, palette: {[string]: { [string]: string }}}

---@alias Theme 'light' | 'dark'

local M = {}

---@param color string A hex color
---@param percent float a negative number darkens and a positive one brightens
---@return string
local function tint(color, percent)
  assert(color and percent, 'cannot alter a color without specifying a color and percentage')
  local r = tonumber(color:sub(2, 3), 16)
  local g = tonumber(color:sub(4, 5), 16)
  local b = tonumber(color:sub(6), 16)
  if not r or not g or not b then return 'NONE' end
  local blend = function(component)
    component = math.floor(component * (1 + percent))
    return math.min(math.max(component, 0), 255)
  end
  return string.format('#%02x%02x%02x', blend(r), blend(g), blend(b))
end

-- These colours represent values not directly taken from the
-- original theme, but are similar to/inspired by the original.
-- they are largely used to plug in the gaps where there is no
-- color specified for something that needs to be highlighted
-- in the neovim context
---@param data CustomPalette
---@return CustomPalette
local function get_custom_highlights(data)
  local d = data ---@module 'horizon.palette-dark'
  local t, p = d.theme, d.palette
  return {
    hint = p.syntax.lavender,
    info = p.syntax.turquoise,
    warn = p.syntax.apricot,
    error = t.error,
    error_bg = tint(t.error, -0.8), -- error_bg = '#33222c',
    warn_bg = tint(p.syntax.apricot, -0.8), -- warn_bg = '#332e31',
    info_bg = tint(p.syntax.turquoise, -0.7), -- info_bg = '#1e3132',
    hint_bg = tint(p.syntax.lavender, -0.7), -- hint_bg = '#252732',
    purple1 = tint(p.syntax.lavender, -0.2), -- '#B180D7',
    gray = '#4B4C53',
    gold = '#C09553',
    blue1 = '#214a63',
    blue2 = '#042E48',
    blue3 = '#75BEFF',
    diff_change = '#273842',
    diff_text = '#314753',
  }
end

---@param theme horizon.HighlightDef
---@param palette {[string]: {[string]: string}}
local function get_lsp_kind_highlights(theme, palette)
  return {
    -- LSP Kind Items
    ['module'] = { fg = palette.syntax.rosebud },
    ['snippet'] = { fg = palette.syntax.lavender },
    ['folder'] = { fg = theme.fg },
    ['color'] = { fg = theme.fg },
    ['file'] = { link = 'Directory' },
    ['text'] = { link = '@string' },
    ['method'] = { link = '@method' },
    ['function'] = { link = '@function' },
    ['constructor'] = { link = '@constructor' },
    ['field'] = { link = '@field' },
    ['variable'] = { link = '@variable' },
    ['property'] = { link = '@property' },
    ['unit'] = { link = '@constant' },
    ['value'] = { link = '@variable' },
    ['enum'] = { link = '@type' },
    ['keyword'] = { link = '@keyword' },
    ['reference'] = { link = '@parameter.reference' },
    ['constant'] = { link = '@constant' },
    ['struct'] = { link = '@structure' },
    ['event'] = { link = '@variable' },
    ['operator'] = { link = '@operator' },
    ['namespace'] = { link = '@namespace' },
    ['package'] = { link = '@include' },
    ['string'] = { link = '@string' },
    ['number'] = { link = '@number' },
    ['boolean'] = { link = '@boolean' },
    ['array'] = { link = '@repeat' },
    ['object'] = { link = '@type' },
    ['key'] = { link = '@field' },
    ['null'] = { link = '@symbol' },
    ['enumMember'] = { link = '@field' },
    ['class'] = { link = '@lsp.type.class' },
    ['interface'] = { link = '@lsp.type.interface' },
    ['typeParameter'] = { link = '@lsp.type.parameter' },
  }
end

---@param data ThemeData
---@param custom CustomPalette
---@return horizon.HighlightDef
local function get_highlights(data, custom)
  local d = data ---@module 'horizon.palette-dark'
  local theme, p = d.theme, d.palette
  return {
    -- Editor
    ['Normal'] = { fg = theme.fg, bg = theme.bg },
    ['NormalNC'] = { fg = theme.fg, bg = theme.bg },
    ['SignColumn'] = {},
    ['MsgArea'] = { fg = theme.fg, bg = theme.bg },
    ['ModeMsg'] = { fg = theme.fg, bg = p.ui.background },
    ['MsgSeparator'] = { fg = theme.winseparator_fg, bg = theme.bg },
    ['SpellBad'] = { sp = p.syntax.cranberry, undercurl = true },
    ['SpellCap'] = { sp = p.syntax.tacao, undercurl = true },
    ['SpellLocal'] = { sp = p.syntax.rosebud, underline = true },
    ['SpellRare'] = { sp = p.syntax.lavender, underline = true },
    ['Pmenu'] = { fg = theme.fg, bg = theme.pmenu_bg },
    ['PmenuSel'] = { bg = custom.blue2 },
    ['PmenuSbar'] = { bg = theme.pmenu_thumb_bg },
    ['PmenuThumb'] = { bg = theme.pmenu_thumb_fg },
    ['WildMenu'] = { fg = theme.fg, bg = custom.blue2 },
    ['CursorLineNr'] = { fg = theme.active_line_number_fg, bold = true },
    ['Folded'] = { fg = custom.gray, bg = p.ui.background },
    ['FoldColumn'] = { fg = custom.gray, bg = p.ui.background },
    ['LineNr'] = { fg = theme.inactive_line_number_fg },
    ['NormalFloat'] = { bg = theme.float_bg },
    ['FloatBorder'] = { fg = theme.float_border, bg = theme.float_bg },
    ['Whitespace'] = { fg = p.ui.backgroundAlt },
    ['VertSplit'] = { fg = theme.winseparator_fg, bg = theme.bg },
    ['CursorLine'] = { bg = theme.cursorline_bg },
    ['CursorColumn'] = { bg = p.ui.background },
    ['ColorColumn'] = { bg = p.ui.background },
    ['Visual'] = { bg = theme.visual },
    ['VisualNOS'] = { bg = p.ui.background },
    ['WarningMsg'] = { fg = custom.warn, bg = theme.bg },
    ['DiffAdd'] = { bg = theme.diff_added_bg },
    ['DiffDelete'] = { bg = theme.diff_deleted_bg },
    ['DiffChange'] = { bg = custom.diff_change },
    ['DiffText'] = { bg = custom.diff_text },
    ['QuickFixLine'] = { bg = custom.blue2 },
    ['MatchParen'] = { fg = theme.match_paren, underline = true },
    ['Cursor'] = { fg = theme.cursor_fg, bg = theme.cursor_bg },
    ['lCursor'] = { fg = theme.cursor_fg, bg = theme.cursor_bg },
    ['CursorIM'] = { fg = theme.cursor_fg, bg = theme.cursor_bg },
    ['TermCursor'] = { fg = theme.term_cursor_fg, bg = theme.term_cursor_bg },
    ['TermCursorNC'] = { fg = theme.term_cursor_fg, bg = theme.term_cursor_bg },
    ['Conceal'] = { fg = custom.gray },
    ['Directory'] = { fg = p.ui.accentAlt },
    ['SpecialKey'] = { fg = p.syntax.cranberry, bold = true },
    ['ErrorMsg'] = { fg = p.ui.negative, bg = theme.bg, bold = true },
    ['Search'] = { bg = custom.blue2 },
    ['IncSearch'] = { bg = custom.blue2 },
    ['Substitute'] = { bg = custom.blue2 },
    ['MoreMsg'] = { fg = p.syntax.apricot },
    ['Question'] = { fg = p.syntax.apricot },
    ['EndOfBuffer'] = { fg = theme.bg },
    ['NonText'] = { fg = theme.bg },
    ['TabLine'] = { fg = p.ui.lightText, bg = p.ui.background },
    ['TabLineSel'] = { fg = theme.fg, bg = p.ui.background },
    ['TabLineFill'] = { fg = p.ui.background, bg = p.ui.background },

    -- Code
    ['Comment'] = theme.comment,
    ['Variable'] = { fg = p.syntax.cranberry },
    ['String'] = theme.string,
    ['Character'] = { fg = p.syntax.rosebud },
    ['Number'] = { fg = p.syntax.apricot },
    ['Float'] = { fg = p.syntax.apricot },
    ['Boolean'] = { fg = p.syntax.apricot },
    ['Constant'] = theme.constant,
    ['Type'] = { fg = p.syntax.tacao },
    ['Function'] = theme.func,
    ['Keyword'] = theme.keyword,
    ['Conditional'] = { fg = p.syntax.lavender },
    ['Repeat'] = { fg = p.syntax.lavender },
    ['Operator'] = { link = 'Delimiter' },
    ['PreProc'] = { fg = p.syntax.lavender },
    ['Include'] = { fg = p.syntax.lavender },
    ['Exception'] = { fg = p.syntax.lavender },
    ['StorageClass'] = { fg = p.syntax.tacao },
    ['Structure'] = { fg = p.syntax.tacao },
    ['Typedef'] = { fg = p.syntax.lavender },
    ['Define'] = { fg = p.syntax.lavender },
    ['Macro'] = { fg = p.syntax.lavender },
    ['Debug'] = { fg = p.syntax.cranberry },
    ['Title'] = { fg = p.syntax.tacao, bold = true },
    ['Label'] = { fg = p.syntax.cranberry },
    ['SpecialChar'] = { fg = p.syntax.rosebud },
    ['Delimiter'] = theme.delimiter,
    ['SpecialComment'] = { fg = theme.fg },
    ['Tag'] = { fg = p.syntax.cranberry },
    ['Bold'] = { bold = true },
    ['Italic'] = { italic = true },
    ['Underlined'] = { underline = true },
    ['Ignore'] = { fg = p.ui.accentAlt, bold = true },
    ['Todo'] = { fg = p.ui.warning, bold = true },
    ['Error'] = { fg = p.ui.negative, bold = true },
    ['Statement'] = { fg = p.syntax.lavender },
    ['Identifier'] = { fg = theme.fg },
    ['PreCondit'] = { fg = p.syntax.lavender },
    ['Special'] = { fg = p.syntax.apricot },

    -- Treesitter
    ['@comment'] = { link = 'Comment' },
    ['@variable'] = { link = 'Variable' },
    ['@string'] = { link = 'String' },
    ['@string.regex'] = { link = 'String' },
    ['@string.escape'] = { link = 'String' },
    ['@character'] = { link = 'String' },
    ['@character.special'] = { link = 'SpecialChar' },
    ['@number'] = { link = 'Number' },
    ['@float'] = { link = 'Float' },
    ['@boolean'] = { link = 'Boolean' },
    ['@constant'] = { link = 'Constant' },
    ['@constant.builtin'] = { link = 'Constant' },
    ['@constructor'] = { link = 'Type' },
    ['@type'] = { link = 'Type' },
    ['@include'] = { link = 'Include' },
    ['@exception'] = { link = 'Exception' },
    ['@keyword'] = { link = 'Keyword' },
    ['@keyword.return'] = { link = 'Keyword' },
    ['@keyword.operator'] = { link = 'Keyword' },
    ['@keyword.function'] = { link = 'Keyword' },
    ['@function'] = { link = 'Function' },
    ['@function.builtin'] = { link = 'Function' },
    ['@method'] = { link = 'Function' },
    ['@function.macro'] = { link = 'Function' },
    ['@conditional'] = { link = 'Conditional' },
    ['@repeat'] = { link = 'Repeat' },
    ['@operator'] = { link = 'Operator' },
    ['@preproc'] = { link = 'PreProc' },
    ['@storageclass'] = { link = 'StorageClass' },
    ['@structure'] = { link = 'Structure' },
    ['@type.definition'] = { link = 'Typedef' },
    ['@define'] = { link = 'Define' },
    ['@note'] = { link = 'Comment' },
    ['@none'] = { fg = p.ui.lightText },
    ['@todo'] = { link = 'Todo' },
    ['@debug'] = { link = 'Debug' },
    ['@danger'] = { link = 'Error' },
    ['@title'] = { link = 'Title' },
    ['@label'] = { link = 'Label' },
    ['@tag.delimiter'] = { fg = p.syntax.cranberry },
    ['@punctuation.delimiter'] = { link = 'Delimiter' },
    ['@punctuation.bracket'] = { link = 'Delimiter' },
    ['@punctuation.special'] = { link = 'Delimiter' },
    ['@tag'] = { link = 'Tag' },
    ['@strong'] = { link = 'Bold' },
    ['@emphasis'] = { link = 'Italic' },
    ['@underline'] = { link = 'Underline' },
    ['@strike'] = { strikethrough = true },
    ['@string.special'] = { fg = theme.fg },
    ['@environment.name'] = { fg = p.syntax.turquoise },
    ['@variable.builtin'] = { fg = p.syntax.tacao },
    ['@const.macro'] = { fg = p.syntax.apricot },
    ['@type.builtin'] = { fg = p.syntax.apricot },
    ['@annotation'] = { fg = p.syntax.turquoise },
    ['@namespace'] = { fg = p.syntax.turquoise },
    ['@symbol'] = { fg = theme.fg },
    ['@field'] = { fg = p.syntax.cranberry },
    ['@property'] = { fg = p.syntax.cranberry },
    ['@parameter'] = { fg = p.syntax.cranberry },
    ['@parameter.reference'] = theme.parameter,
    ['@attribute'] = { fg = p.syntax.cranberry },
    ['@text'] = { fg = p.ui.lightText },
    ['@text.emphasis'] = { bold = true },
    ['@text.reference'] = { fg = theme.link.fg, sp = p.ui.accent, underline = true, bold = true },
    ['@tag.attribute'] = { fg = p.syntax.apricot, italic = true },
    ['@error'] = { fg = custom.error },
    ['@warning'] = { fg = custom.warn },
    ['@query.linter.error'] = { fg = custom.error },
    ['@uri'] = { fg = p.syntax.turquoise, underline = true },
    ['@math'] = { fg = p.syntax.tacao },

    -- LspSemanticTokens
    ['@lsp.type.namespace'] = { link = '@namespace' },
    ['@lsp.type.type'] = { link = '@type' },
    ['@lsp.type.class'] = { link = '@type' },
    ['@lsp.type.enum'] = { link = '@type' },
    ['@lsp.type.interface'] = { link = '@type' },
    ['@lsp.type.struct'] = { link = '@structure' },
    ['@lsp.type.typeParameter'] = { link = 'TypeDef' },
    ['@lsp.type.variable'] = { link = '@variable' },
    ['@lsp.type.property'] = { link = '@property' },
    ['@lsp.type.enumMember'] = { link = '@constant' },
    ['@lsp.type.function'] = { link = '@function' },
    ['@lsp.type.method'] = { link = '@method' },
    ['@lsp.type.macro'] = { link = '@macro' },
    ['@lsp.type.decorator'] = { link = '@function' },
    ['@lsp.typemod.variable.readonly'] = { link = '@constant' },
    ['@lsp.typemod.method.defaultLibrary'] = { link = '@function.builtin' },
    ['@lsp.typemod.function.defaultLibrary'] = { link = '@function.builtin' },
    ['@lsp.typemod.variable.defaultLibrary'] = { link = '@variable.builtin' },
    ['@lsp.mod.deprecated'] = { strikethrough = true },

    -- LSP
    ['DiagnosticHint'] = { fg = custom.hint },
    ['DiagnosticInfo'] = { fg = custom.info },
    ['DiagnosticWarn'] = { fg = custom.warn },
    ['DiagnosticError'] = { fg = custom.error },
    ['DiagnosticOther'] = { fg = custom.purple1 },
    ['DiagnosticSignHint'] = { link = 'DiagnosticHint' },
    ['DiagnosticSignInfo'] = { link = 'DiagnosticInfo' },
    ['DiagnosticSignWarn'] = { link = 'DiagnosticWarn' },
    ['DiagnosticSignError'] = { link = 'DiagnosticError' },
    ['DiagnosticSignOther'] = { link = 'DiagnosticOther' },
    ['DiagnosticSignWarning'] = { link = 'DiagnosticWarn' },
    ['DiagnosticFloatingHint'] = { link = 'DiagnosticHint' },
    ['DiagnosticFloatingInfo'] = { link = 'DiagnosticInfo' },
    ['DiagnosticFloatingWarn'] = { link = 'DiagnosticWarn' },
    ['DiagnosticFloatingError'] = { link = 'DiagnosticError' },
    ['DiagnosticUnderlineHint'] = { sp = custom.hint, undercurl = true },
    ['DiagnosticUnderlineInfo'] = { sp = custom.info, undercurl = true },
    ['DiagnosticUnderlineWarn'] = { sp = custom.warn, undercurl = true },
    ['DiagnosticUnderlineError'] = { sp = custom.error, undercurl = true },
    ['DiagnosticSignInformation'] = { link = 'DiagnosticInfo' },
    ['DiagnosticVirtualTextHint'] = { fg = custom.hint, bg = custom.hint_bg },
    ['DiagnosticVirtualTextInfo'] = { fg = custom.info, bg = custom.info_bg },
    ['DiagnosticVirtualTextWarn'] = { fg = custom.warn, bg = custom.warn_bg },
    ['DiagnosticVirtualTextError'] = { fg = custom.error, bg = custom.error_bg },
    ['NvimTreeLspDiagnosticsError'] = { link = 'DiagnosticError' },
    ['NvimTreeLspDiagnosticsWarning'] = { link = 'DiagnosticWarn' },
    ['NvimTreeLspDiagnosticsInformation'] = { link = 'DiagnosticInfo' },
    ['NvimTreeLspDiagnosticsInfo'] = { link = 'DiagnosticInfo' },
    ['NvimTreeLspDiagnosticsHint'] = { link = 'DiagnosticHint' },
    ['LspDiagnosticsUnderlineError'] = { link = 'DiagnosticUnderlineError' },
    ['LspDiagnosticsUnderlineWarning'] = { link = 'DiagnosticUnderlineWarn' },
    ['LspDiagnosticsUnderlineInformation'] = { link = 'DiagnosticUnderlineInfo' },
    ['LspDiagnosticsUnderlineInfo'] = { link = 'DiagnosticUnderlineInfo' },
    ['LspDiagnosticsUnderlineHint'] = { link = 'DiagnosticUnderlineHint' },
    ['LspReferenceRead'] = { bg = p.ui.accent },
    ['LspReferenceText'] = { bg = p.ui.accent },
    ['LspReferenceWrite'] = { bg = p.ui.accent },
    ['LspCodeLens'] = { fg = theme.codelens_fg, italic = true },
    ['LspCodeLensSeparator'] = { fg = theme.codelens_fg, italic = true },

    -- StatusLine
    ['StatusLine'] = { fg = theme.statusline_fg, bg = theme.statusline_bg },
    ['StatusLineNC'] = { fg = p.ui.background, bg = theme.statusline_bg },
    ['StatusLineSeparator'] = { fg = theme.statusline_bg },
    ['StatusLineTerm'] = { fg = theme.statusline_bg },
    ['StatusLineTermNC'] = { fg = theme.statusline_bg },
  }
end

---@param data ThemeData
---@param custom CustomPalette
---@return horizon.HighlightDef
local function get_plugin_highlights(data, custom)
  local d = data ---@module 'horizon.palette-dark'
  local t, p = d.theme, d.palette
  local lsp_kinds = get_lsp_kind_highlights(t, p)
  return {
    whichkey = {
      ['WhichKey'] = { fg = p.syntax.lavender },
      ['WhichKeySeperator'] = { fg = p.syntax.tacao },
      ['WhichKeyGroup'] = { fg = p.syntax.cranberry },
      ['WhichKeyDesc'] = { fg = t.fg },
      ['WhichKeyFloat'] = { bg = t.float_bg },
    },
    gitsigns = {
      ['SignAdd'] = { fg = t.git_added_fg },
      ['SignChange'] = { fg = t.git_modified_fg },
      ['SignDelete'] = { fg = t.git_deleted_fg },
      ['GitSignsAdd'] = { fg = t.git_added_fg },
      ['GitSignsChange'] = { fg = t.git_modified_fg },
      ['GitSignsDelete'] = { fg = t.git_deleted_fg },
      ['GitSignsUntracked'] = { fg = t.git_untracked_fg },
      ['GitSignsAddInline'] = { link = 'DiffText' },
      ['GitSignsChangeInline'] = { link = 'DiffChange' },
      ['GitSignsDeleteInline'] = { link = 'DiffDelete' },
    },
    quickscope = {
      ['QuickScopePrimary'] = { fg = '#ff007c', underline = true },
      ['QuickScopeSecondary'] = { fg = '#00dfff', underline = true },
    },
    telescope = {
      ['TelescopeSelection'] = { bg = custom.blue2 },
      ['TelescopeSelectionCaret'] = { fg = p.syntax.cranberry, bg = custom.blue2 },
      ['TelescopeMatching'] = { fg = p.syntax.tacao, bold = true, italic = true },
      ['TelescopeBorder'] = { fg = t.float_border },
      ['TelescopeNormal'] = { fg = p.ui.lightText, bg = p.ui.background },
      ['TelescopePromptTitle'] = { fg = p.syntax.apricot },
      ['TelescopePromptPrefix'] = { fg = p.syntax.turquoise },
      ['TelescopeResultsTitle'] = { fg = p.syntax.apricot },
      ['TelescopePreviewTitle'] = { fg = p.syntax.apricot },
      ['TelescopePromptCounter'] = { fg = p.syntax.cranberry },
      ['TelescopePreviewHyphen'] = { fg = p.syntax.cranberry },
    },
    nvim_tree = {
      ['NvimTreeFolderIcon'] = { fg = custom.gold },
      ['NvimTreeIndentMarker'] = { fg = custom.gray },
      ['NvimTreeNormal'] = { fg = t.sidebar_fg, bg = t.sidebar_bg },
      ['NvimTreeVertSplit'] = { fg = t.sidebar_bg, bg = t.sidebar_bg },
      ['NvimTreeFolderName'] = { fg = t.sidebar_fg },
      ['NvimTreeOpenedFolderName'] = { fg = t.sidebar_fg, bold = true, italic = true },
      ['NvimTreeEmptyFolderName'] = t.comment,
      ['NvimTreeGitIgnored'] = t.comment,
      ['NvimTreeImageFile'] = { fg = p.ui.lightText },
      ['NvimTreeSpecialFile'] = { fg = p.syntax.apricot },
      ['NvimTreeEndOfBuffer'] = { fg = t.comment.fg },
      ['NvimTreeCursorLine'] = { bg = t.cursorline_bg },
      ['NvimTreeGitStaged'] = { fg = t.git_added_fg },
      ['NvimTreeGitNew'] = { fg = t.git_untracked_fg },
      ['NvimTreeGitRenamed'] = { fg = t.git_modified_fg },
      ['NvimTreeGitDeleted'] = { fg = t.git_deleted_fg },
      ['NvimTreeGitMerge'] = { fg = t.git_modified_fg },
      ['NvimTreeGitDirty'] = { fg = t.git_untracked_fg },
      ['NvimTreeSymlink'] = { fg = p.syntax.turquoise },
      ['NvimTreeRootFolder'] = { fg = t.fg, bold = true },
      ['NvimTreeExecFile'] = { fg = '#9FBA89' },
    },
    neo_tree = {
      ['NeoTreeFolderIcon'] = { fg = custom.gold },
      ['NeoTreeIndentMarker'] = { fg = custom.gray },
      ['NeoTreeNormal'] = { fg = t.sidebar_fg, bg = t.sidebar_bg },
      ['NeoTreeFileName'] = { fg = t.sidebar_fg },
      ['NeoTreeFileNameOpened'] = { fg = t.fg, bold = true, italic = true },
      ['NeoTreeDirectoryName'] = { fg = t.sidebar_fg },
      ['NeoTreeDirectoryIcon'] = { fg = custom.gold },
      ['NeoTreeVertSplit'] = { fg = t.sidebar_bg, bg = t.sidebar_bg },
      ['NeoTreeWinSeparator'] = { fg = t.sidebar_bg, bg = t.sidebar_bg },
      ['NeoTreeOpenedFolderName'] = { fg = t.fg, bold = true, italic = true },
      ['NeoTreeEmptyFolderName'] = { fg = t.comment.fg, italic = true },
      ['NeoTreeGitIgnored'] = { fg = t.comment.fg, italic = true },
      ['NeoTreeDotfile'] = { fg = t.comment.fg, italic = true },
      ['NeoTreeHiddenByName'] = { fg = t.comment.fg, italic = true },
      ['NeoTreeEndOfBuffer'] = { fg = t.comment.fg },
      ['NeoTreeCursorLine'] = { bg = t.cursorline_bg },
      ['NeoTreeGitStaged'] = { fg = t.git_added_fg },
      ['NeoTreeGitUntracked'] = { fg = t.git_untracked_fg },
      ['NeoTreeGitDeleted'] = { fg = t.git_deleted_fg },
      ['NeoTreeGitModified'] = { fg = t.git_modified_fg },
      ['NeoTreeSymbolicLinkTarget'] = { fg = p.syntax.turquoise },
      ['NeoTreeRootName'] = { fg = t.fg, bold = true },
      ['NeoTreeTitleBar'] = { fg = p.ui.backgroundAlt, bg = t.fg, bold = true },
    },
    barbar = {
      ['BufferCurrent'] = { fg = t.fg, bg = t.bg },
      ['BufferCurrentIndex'] = { fg = t.fg, bg = t.bg },
      ['BufferCurrentMod'] = { fg = p.ui.warning, bg = t.bg },
      ['BufferCurrentSign'] = { fg = p.ui.accentAlt, bg = t.bg },
      ['BufferCurrentTarget'] = { fg = p.syntax.cranberry, bg = t.bg, bold = true },
      ['BufferVisible'] = { fg = t.fg, bg = t.bg },
      ['BufferVisibleIndex'] = { fg = t.fg, bg = t.bg },
      ['BufferVisibleMod'] = { fg = p.ui.warning, bg = t.bg },
      ['BufferVisibleSign'] = { fg = custom.gray, bg = t.bg },
      ['BufferVisibleTarget'] = { fg = p.syntax.cranberry, bg = t.bg, bold = true },
      ['BufferInactive'] = { fg = custom.gray, bg = p.ui.background },
      ['BufferInactiveIndex'] = { fg = custom.gray, bg = p.ui.background },
      ['BufferInactiveMod'] = { fg = p.ui.warning, bg = p.ui.background },
      ['BufferInactiveSign'] = { fg = custom.gray, bg = p.ui.background },
      ['BufferInactiveTarget'] = { fg = p.syntax.cranberry, bg = p.ui.background, bold = true },
    },
    indent_blankline = {
      ['IndentBlanklineContextChar'] = { fg = t.indent_guide_active_fg },
      ['IndentBlanklineContextStart'] = { sp = t.indent_guide_active_fg, underline = true },
      ['IndentBlanklineChar'] = { fg = t.indent_guide_fg },
    },
    cmp = {
      ['CmpItemAbbrMatch'] = { fg = t.pmenu_item_sel_fg },
      ['CmpItemAbbrMatchFuzzy'] = { fg = t.pmenu_item_sel_fg, italic = true },
      ['CmpItemAbbrDeprecated'] = { fg = custom.gray, strikethrough = true },
      ['CmpItemKindVariable'] = lsp_kinds['variable'],
      ['CmpItemKindModule'] = lsp_kinds['module'],
      ['CmpItemKindSnippet'] = lsp_kinds['snippet'],
      ['CmpItemKindFolder'] = lsp_kinds['folder'],
      ['CmpItemKindColor'] = lsp_kinds['color'],
      ['CmpItemKindFile'] = lsp_kinds['file'],
      ['CmpItemKindText'] = lsp_kinds['text'],
      ['CmpItemKindMethod'] = lsp_kinds['method'],
      ['CmpItemKindFunction'] = lsp_kinds['function'],
      ['CmpItemKindConstructor'] = lsp_kinds['constructor'],
      ['CmpItemKindField'] = lsp_kinds['field'],
      ['CmpItemKindProperty'] = lsp_kinds['property'],
      ['CmpItemKindUnit'] = lsp_kinds['unit'],
      ['CmpItemKindValue'] = lsp_kinds['value'],
      ['CmpItemKindEnum'] = lsp_kinds['enum'],
      ['CmpItemKindKeyword'] = lsp_kinds['keyword'],
      ['CmpItemKindReference'] = lsp_kinds['reference'],
      ['CmpItemKindConstant'] = lsp_kinds['constant'],
      ['CmpItemKindStruct'] = lsp_kinds['struct'],
      ['CmpItemKindEvent'] = lsp_kinds['event'],
      ['CmpItemKindOperator'] = lsp_kinds['operator'],
      ['CmpItemKindNamespace'] = lsp_kinds['namespace'],
      ['CmpItemKindPackage'] = lsp_kinds['package'],
      ['CmpItemKindString'] = lsp_kinds['string'],
      ['CmpItemKindNumber'] = lsp_kinds['number'],
      ['CmpItemKindBoolean'] = lsp_kinds['boolean'],
      ['CmpItemKindArray'] = lsp_kinds['array'],
      ['CmpItemKindObject'] = lsp_kinds['object'],
      ['CmpItemKindKey'] = lsp_kinds['key'],
      ['CmpItemKindNull'] = lsp_kinds['null'],
      ['CmpItemKindEnumMember'] = lsp_kinds['enumMember'],
      ['CmpItemKindClass'] = lsp_kinds['class'],
      ['CmpItemKindInterface'] = lsp_kinds['interface'],
      ['CmpItemKindTypeParameter'] = lsp_kinds['typeParameter'],
    },
    navic = {
      ['NavicIconsFile'] = lsp_kinds['file'],
      ['NavicIconsModule'] = lsp_kinds['module'],
      ['NavicIconsNamespace'] = lsp_kinds['namespace'],
      ['NavicIconsPackage'] = lsp_kinds['package'],
      ['NavicIconsClass'] = lsp_kinds['class'],
      ['NavicIconsMethod'] = lsp_kinds['method'],
      ['NavicIconsProperty'] = lsp_kinds['property'],
      ['NavicIconsField'] = lsp_kinds['field'],
      ['NavicIconsConstructor'] = lsp_kinds['constructor'],
      ['NavicIconsEnum'] = lsp_kinds['enum'],
      ['NavicIconsInterface'] = lsp_kinds['interface'],
      ['NavicIconsFunction'] = lsp_kinds['function'],
      ['NavicIconsVariable'] = lsp_kinds['variable'],
      ['NavicIconsConstant'] = lsp_kinds['constant'],
      ['NavicIconsString'] = lsp_kinds['string'],
      ['NavicIconsNumber'] = lsp_kinds['number'],
      ['NavicIconsBoolean'] = lsp_kinds['boolean'],
      ['NavicIconsArray'] = lsp_kinds['array'],
      ['NavicIconsObject'] = lsp_kinds['object'],
      ['NavicIconsKey'] = lsp_kinds['key'],
      ['NavicIconsKeyword'] = lsp_kinds['keyword'],
      ['NavicIconsNull'] = lsp_kinds['null'],
      ['NavicIconsEnumMember'] = lsp_kinds['enumMember'],
      ['NavicIconsStruct'] = lsp_kinds['struct'],
      ['NavicIconsEvent'] = lsp_kinds['event'],
      ['NavicIconsOperator'] = lsp_kinds['operator'],
      ['NavicIconsTypeParameter'] = lsp_kinds['typeParameter'],
      ['NavicText'] = { fg = t.fg },
      ['NavicSeparator'] = { fg = t.fg },
    },
    packer = {
      ['packerString'] = { fg = custom.gold },
      ['packerHash'] = { fg = custom.blue3 },
      ['packerOutput'] = { fg = custom.purple1 },
      ['packerRelDate'] = { fg = custom.gray },
      ['packerSuccess'] = { fg = p.ui.positive },
      ['packerStatusSuccess'] = { fg = custom.blue3 },
    },
    symbols_outline = {
      ['SymbolsOutlineConnector'] = { fg = custom.gray },
      ['FocusedSymbol'] = { bg = '#36383F' },
    },
    notify = {
      ['NotifyERRORBorder'] = { fg = '#8A1F1F' },
      ['NotifyWARNBorder'] = { fg = '#79491D' },
      ['NotifyINFOBorder'] = { fg = custom.blue1 },
      ['NotifyDEBUGBorder'] = { fg = t.float_border },
      ['NotifyTRACEBorder'] = { fg = '#4F3552' },
      ['NotifyERRORIcon'] = { fg = p.ui.negative },
      ['NotifyWARNIcon'] = { fg = p.ui.tertiaryAccent },
      ['NotifyINFOIcon'] = { fg = custom.blue3 },
      ['NotifyDEBUGIcon'] = { fg = custom.gray },
      ['NotifyTRACEIcon'] = { fg = custom.purple1 },
      ['NotifyERRORTitle'] = { fg = p.ui.negative },
      ['NotifyWARNTitle'] = { fg = p.ui.tertiaryAccent },
      ['NotifyINFOTitle'] = { fg = custom.blue3 },
      ['NotifyDEBUGTitle'] = { fg = custom.gray },
      ['NotifyTRACETitle'] = { fg = custom.purple1 },
    },
    ts_rainbow = {
      -- ['TSRainbowRed'] = {},
      -- ['TSRainbowGreen'] = {},
      -- ['TSRainbowCyan'] = {},
      -- ['TSRainbowOrange'] = {},
      ['TSRainbowBlue'] = { fg = '#169FFF' },
      ['TSRainbowYellow'] = { fg = '#FFD602' },
      ['TSRainbowViolet'] = { fg = '#DA70D6' },
    },
    hop = {
      ['HopNextKey'] = { fg = '#4ae0ff' },
      ['HopNextKey1'] = { fg = '#d44eed' },
      ['HopNextKey2'] = { fg = '#b42ecd' },
      ['HopPreview'] = { fg = '#c7ba7d' },
      ['HopUnmatched'] = { fg = custom.gray },
    },
    crates = {
      ['CratesNvimLoading'] = { fg = p.ui.accentAlt },
      ['CratesNvimVersion'] = { fg = p.ui.accentAlt },
    },
  }
end

---Add in any enabled plugin's custom highlighting
---@param config horizon.Config
---@param plugins {[string]: horizon.Opts}
---@param highlights {[string]: horizon.Opts}
local function integrate_plugins(config, plugins, highlights)
  for plugin, enabled in pairs(config.plugins) do
    if enabled and plugins[plugin] then
      for key, value in pairs(plugins[plugin]) do
        highlights[key] = value
      end
    end
  end
  return highlights
end

---@param config horizon.Config
function M.set_highlights(config)
  local bg = vim.o.background
  local data = require(('horizon.palette-%s'):format(bg)) ---@module 'horizon.palette-dark'
  local custom = get_custom_highlights(data)
  local highlights = integrate_plugins(config, get_plugin_highlights(data, custom), get_highlights(data, custom))
  for name, value in pairs(highlights) do
    vim.api.nvim_set_hl(0, name, value)
  end
end

return M
