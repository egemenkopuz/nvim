return {
    {
        "rebelot/kanagawa.nvim",
        enabled = require("user.utils").colorscheme_selection "kanagawa",
        priority = 1000,
        lazy = false,
        opts = {
            compile = true,
            colors = {
                palette = { oldWhite = "#c5c9c5" },
                theme = { all = { ui = { bg_gutter = "none" } } },
            },
            background = { dark = "dragon", light = "lotus" },
            dimInactive = true,
            transparent = require("user.config").transparent,
            overrides = function(colors)
                local diagnostic_colors = require("user.config").colors.diagnostics
                local overrides = {
                    IblIndent = { fg = "#2E3440" },
                    IblScope = { fg = "gray" },
                    CursorLineNr = { fg = "#ce5a57" },
                    CursorLine = { bg = "#2E3440" },
                    NoiceCmdLinePopupBorder = { fg = "gray" },
                    DiagnosticError = { fg = diagnostic_colors.error },
                    DiagnosticSignError = { fg = diagnostic_colors.error },
                    DiagnosticFloatingError = { fg = diagnostic_colors.error },
                    TinyInlineDiagnosticVirtualTextError = { fg = diagnostic_colors.error },
                    DiagnosticWarn = { fg = diagnostic_colors.warn },
                    DiagnosticSignWarn = { fg = diagnostic_colors.warn },
                    DiagnosticFloatingWarn = { fg = diagnostic_colors.warn },
                    TinyInlineDiagnosticVirtualTextWarn = { fg = diagnostic_colors.warn },
                    DiagnosticInfo = { fg = diagnostic_colors.info },
                    DiagnosticSignInfo = { fg = diagnostic_colors.info },
                    DiagnosticFloatingInfo = { fg = diagnostic_colors.info },
                    TinyInlineDiagnosticVirtualTextInfo = { fg = diagnostic_colors.info },
                    DiagnosticHint = { fg = diagnostic_colors.hint },
                    DiagnosticSignHint = { fg = diagnostic_colors.hint },
                    DiagnosticFloatingHint = { fg = diagnostic_colors.hint },
                    TinyInlineDiagnosticVirtualTextHint = { fg = diagnostic_colors.hint },
                    MiniMapSymbolCount = { fg = "gray" },
                    MiniMapSymbolView = { fg = "gray" },
                    MiniMapSymbolLine = { fg = "#ce5a57" },
                    FzfLuaBorder = { fg = "#524C42" },
                    FzfLuaTitle = { fg = "#ce5a57" },
                    FzfLuaPreviewBorder = { fg = "#524C42" },
                    FzfLuaHeaderText = { fg = "gray" },
                    FzfLuaScrollBorderFull = { fg = "lightgray" },
                    BlinkCmpMenu = { link = "float" },
                    BlinkCmpMenuBorder = { fg = "#524C42" },
                    BlinkCmpMenuSelection = { fg = "#7FB4CA", bg = "#2E3440" },
                    BlinkCmpDocBorder = { fg = "#524C42" },
                    BlinkCmpSignatureHelpBorder = { fg = "#524C42" },
                }
                colors.palette.oldWhite = colors.palette.fujiWhite
                if not require("user.config").transparent then
                    return vim.tbl_extend("force", overrides, {
                        NoiceCmdLinePopupTitle = { fg = "#181616", bg = "gray", bold = true },
                        NormalFloatBorder = { fg = "gray" },
                        FloatBorder = { fg = "gray" },
                        MiniFilesTitleFocused = { fg = "#ce5a57", bold = true },
                    })
                end
                return overrides
            end,
        },
        config = function(_, opts)
            require("kanagawa").setup(opts)
            vim.cmd.colorscheme "kanagawa"
        end,
    },
}
