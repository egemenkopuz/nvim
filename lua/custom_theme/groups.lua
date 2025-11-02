local M = {}

local colors = require "custom_theme.colors"

M.setup = function()
    return {
        Float = { fg = colors.g_5, bg = colors.bg },
        Normal = { fg = colors.fg, bg = colors.bg },
        NormalFloat = { fg = colors.g_6, bg = colors.bg },
        NormalFloatBorder = { fg = colors.g_10 },
        CursorLineNr = { fg = colors.red_glowing, bold = true },

        Title = { fg = colors.red_glowing, bold = true },
        FloatTitle = { fg = colors.fg, bold = true },
        Visual = { bg = colors.g_8 }, -- visual selection
        Substitute = { bg = colors.g_8 }, -- %s

        Boolean = { fg = colors.constant }, -- boolean values
        Character = { fg = colors.string }, -- character constants
        Comment = { fg = colors.comment }, -- comments
        Conceal = { fg = colors.comment }, -- concealed text
        Conditional = { fg = colors.todo }, -- TODO find out what this is exactly
        Constant = { fg = colors.constant }, -- constants
        String = { fg = colors.string }, -- string literals
        Define = { fg = colors.todo }, -- TODO find out what this is exactly
        Directory = { fg = colors.g_2 },
        EndOfBuffer = { fg = colors.bg },
        Error = { fg = colors.error },
        ErrorMsg = { fg = colors.error },
        FoldColumn = {},
        Folded = { fg = colors.g_5 },
        Function = { fg = colors.fn, bold = true }, -- function names
        Identifier = { fg = colors.g_3 },
        Include = { fg = colors.todo }, -- TODO find out what this is exactly
        Keyword = { fg = colors.g_6, italic = false }, -- keywords
        Label = { fg = colors.todo }, -- TODO find out what this is exactly
        LineNr = { fg = colors.g_6 },
        Macro = { fg = colors.constant },
        NonText = { fg = colors.g_7 },
        Number = { fg = colors.constant },
        PreCondit = { fg = colors.todo }, -- TODO find out what this is exactly
        PreProc = { fg = colors.todo }, -- TODO find out what this is exactly
        Question = { fg = colors.todo }, -- TODO find out what this is exactly
        Repeat = { fg = colors.todo }, -- TODO find out what this is exactly
        Special = { fg = colors.red_ember, italic = false },
        SpecialComment = { fg = colors.comment, italic = false },
        SpecialKey = { fg = colors.nontext },
        Statement = { fg = colors.todo }, -- TODO find out what this is exactly
        Structure = { fg = colors.namespace },
        Type = { fg = colors.cyan_dark },
        TypeDef = { fg = colors.todo }, -- TODO find out what this is exactly

        -- treesitter
        ["@type"] = { fg = colors.red_burnt_crimson, italic = false },
        ["@variable"] = { fg = colors.g_4 },
        ["@variable.parameter"] = { fg = colors.g_1 },
        ["@string.documentation"] = { fg = colors.comment },
        ["@function"] = { fg = colors.fn, bold = true },
        ["@property.json"] = { fg = colors.fn, bold = true },

        -- lsp semantic tokens
        ["@lsp.typemod.variable.readonly"] = { fg = colors.constant, bold = true },
        ["@lsp.mod.interface.go"] = { fg = colors.red_burnt_crimson, bold = true },
        ["@lsp.typemod.parameter.interface.go"] = { fg = colors.g_3, bold = true },

        Pmenu = { link = "float" },
        PmenuSbar = { bg = colors.transparent_blue },
        PmenuSel = { fg = colors.selection, bg = colors.g_10 },
        PmenuThumb = { fg = colors.selection },

        -- LSP References, while hovering over a symbol
        LspReferenceText = { underline = true, bg = "none" },
        LspReferenceWrite = { link = "LspReferenceText" },

        -- Diagnostics
        DiagnosticError = { fg = colors.error },
        DiagnosticSignError = { fg = colors.error },
        DiagnosticFloatingError = { fg = colors.error },
        DiagnosticWarn = { fg = colors.warn },
        DiagnosticSignWarn = { fg = colors.warn },
        DiagnosticFloatingWarn = { fg = colors.warn },
        DiagnosticInfo = { fg = colors.info },
        DiagnosticSignInfo = { fg = colors.info },
        DiagnosticFloatingInfo = { fg = colors.info },
        DiagnosticHint = { fg = colors.hint },
        DiagnosticSignHint = { fg = colors.hint },
        DiagnosticFloatingHint = { fg = colors.hint },

        StatusLine = { link = "Normal" },
        StatusLineNC = { link = "Normal" },
        StatusLineBackground = { link = "Normal" },

        VertSplit = { fg = colors.g_7 },
        WinSeparator = { fg = colors.g_7 },
        TabLine = { fg = colors.g_5 },
        TabLineSel = { fg = colors.selection },

        MatchParen = { fg = colors.fg, bg = colors.g_7, underline = true }, -- matching parentheses

        -- search highlights
        Search = { fg = colors.fg, bg = colors.g_8 },
        CurSearch = { bg = colors.g_8, bold = true },
        IncSearch = { bg = colors.g_8, bold = true },

        ColorColumn = { bg = colors.g_10 },

        -- mini.files
        MiniFilesTitleFocused = { fg = colors.selection, bold = true },

        -- git signs
        GitSignsAdd = { fg = colors.added },
        GitSignsChange = { fg = colors.modified },
        GitSignsDelete = { fg = colors.removed },

        -- snacks indent scope
        SnacksIndentScope = { fg = colors.g_6 }, -- active

        -- snacks dashboard
        SnacksDashboardDesc = { fg = colors.fg },
        SnacksDashboardSpecial = { fg = colors.fg },
        SnacksDashboardIcon = { fg = colors.fg },
        SnacksDashboardFile = { fg = colors.fg },

        -- neotest
        NeotestFailed = { link = "DiagnosticError" },
        NeotestTarget = { link = "DiagnosticError" },
        NeotestPassed = { link = "DiagnosticInfo" },
        NeotestRunning = { link = "DiagnosticWarn" },
        NeotestSkipped = { link = "DiagnosticHint" },
        NeotestWatching = { link = "DiagnosticHint" },
        NeotestFile = { link = "DiagnosticInfo" },
        NeotestDir = { link = "DiagnosticInfo" },
        NeotestWinSelect = { link = "DiagnosticInfo" },
        NeotestAdapterName = { fg = colors.fg, bold = true },
    }
end

return M
