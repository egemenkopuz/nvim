local colors = require "user.colors"
local M = { common = {} }

M.general = {
    -- general
    FloatBorder = { fg = colors.general.border },
    NormalFloatBorder = { fg = colors.general.border },
    CursorLineNr = { fg = colors.custom.light_red },
    CursorLine = { bg = "#2E3440" },
    -- indent
    IblIndent = { fg = "#2E3440" },
    IblScope = { fg = colors.custom.gray },
    -- dap
    DapBreakpoint = { bg = "#454545" },
    DapLogPoint = { bg = "#31353f" },
    DapStopped = { fg = colors.custom.white, bg = colors.custom.light_red },
    -- noice
    NoiceCmdLinePopupTitle = { fg = colors.custom.light_red, bg = colors.custom.gray, bold = true },
    NoiceCmdLinePopupBorder = { fg = colors.general.border },
    NoicePopupBorder = { fg = colors.general.border },
    NoicePopupmenuBorder = { fg = colors.general.border },
    -- diagnostics
    DiagnosticError = { fg = colors.diagnostics.error },
    DiagnosticSignError = { fg = colors.diagnostics.error },
    DiagnosticFloatingError = { fg = colors.diagnostics.error },
    TinyInlineDiagnosticVirtualTextError = { fg = colors.diagnostics.error },
    DiagnosticWarn = { fg = colors.diagnostics.warn },
    DiagnosticSignWarn = { fg = colors.diagnostics.warn },
    DiagnosticFloatingWarn = { fg = colors.diagnostics.warn },
    TinyInlineDiagnosticVirtualTextWarn = { fg = colors.diagnostics.warn },
    DiagnosticInfo = { fg = colors.diagnostics.info },
    DiagnosticSignInfo = { fg = colors.diagnostics.info },
    DiagnosticFloatingInfo = { fg = colors.diagnostics.info },
    TinyInlineDiagnosticVirtualTextInfo = { fg = colors.diagnostics.info },
    DiagnosticHint = { fg = colors.diagnostics.hint },
    DiagnosticSignHint = { fg = colors.diagnostics.hint },
    DiagnosticFloatingHint = { fg = colors.diagnostics.hint },
    TinyInlineDiagnosticVirtualTextHint = { fg = colors.diagnostics.hint },
    -- mini-map
    MiniMapSymbolCount = { fg = colors.custom.gray },
    MiniMapSymbolView = { fg = colors.custom.gray },
    MiniMapSymbolLine = { fg = colors.custom.light_red },
    -- fzf-lua
    FzfLuaBorder = { fg = colors.general.border },
    FzfLuaTitle = { fg = colors.custom.light_red },
    FzfLuaPreviewBorder = { fg = colors.general.border },
    FzfLuaHeaderText = { fg = colors.custom.gray },
    FzfLuaScrollBorderFull = { fg = colors.custom.light_red },
    FzfColorsHl = { fg = colors.custom.light_red },
    -- blink cmp
    BlinkCmpMenu = { link = "float" },
    BlinkCmpMenuBorder = { fg = colors.general.border },
    BlinkCmpMenuSelection = { fg = colors.general.selection, bg = "#2E3440" },
    BlinkCmpDocBorder = { fg = colors.general.border },
    BlinkCmpSignatureHelpBorder = { fg = colors.general.border },
    -- Popup menu
    Pmenu = { link = "float" },
    PmenuSel = { link = "BlinkCmpMenuSelection" },
    PmenuSbar = { link = "BlinkCmpMenuBorder" },
    PmenuThumb = { link = "BlinkCmpMenuBorder" },
    -- LSP document highlighting
    LspReferenceText = { underline = true, bg = "none" },
    LspReferenceWrite = { link = "LspReferenceText" },
    -- mini.files
    MiniFilesTitleFocused = { fg = colors.custom.light_red, bold = true },
    StatusLineBackground = { bg = colors.general.status_line_bg },
    SnacksNotifierBorderInfo = { link = "FloatBorder" },
    SnacksNotifierBorderWarn = { link = "FloatBorder" },
    SnacksNotifierBorderDebug = { link = "FloatBorder" },
    SnacksNotifierBorderError = { link = "FloatBorder" },
    SnacksNotifierBorderTrace = { link = "FloatBorder" },
    MiniDiffSignChange = { fg = colors.diff.modified },
    MiniDiffSignAdd = { fg = colors.diff.added },
    MiniDiffSignDelete = { fg = colors.diff.removed },
    CmpItemAbbrMatch = { fg = colors.custom.light_red, bold = true },
    SnacksIndentScope = { fg = colors.custom.gray },
}

M.transparent = {
    FloatBorder = { fg = colors.general.border, bg = "none" },
    StatusLineBackground = { bg = "none" },
    Normal = { bg = "none" },
    NormalFLoat = { bg = "none" },
    MsgArea = { bg = "none" },
    MiniTablineCurrent = { fg = colors.custom.gray3, bg = "none", bold = true },
    MiniTablineHidden = { fg = colors.custom.gray2, bg = "none" },
    MiniTablineVisible = { fg = colors.custom.gray2, bg = "none" },
    MiniTablineModifiedCurrent = { link = "MiniTablineCurrent" },
    MiniTablineModifiedHidden = { link = "MiniTablineHidden" },
    MiniTablineModifiedVisible = { link = "MiniTablineVisible" },
}

return M
