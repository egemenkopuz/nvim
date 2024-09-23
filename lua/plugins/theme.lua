return {
    {
        "rebelot/kanagawa.nvim",
        enabled = require("user.utils").colorscheme_selection "kanagawa",
        priority = 1000,
        lazy = false,
        opts = {
            compile = true,
            colors = { theme = { all = { ui = { bg_gutter = "none" } } } },
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
                    DiagnosticWarn = { fg = diagnostic_colors.warn },
                    DiagnosticInfo = { fg = diagnostic_colors.info },
                    DiagnosticHint = { fg = diagnostic_colors.hint },
                    MiniMapSymbolCount = { fg = "gray" },
                    MiniMapSymbolView = { fg = "gray" },
                    MiniMapSymbolLine = { fg = "#ce5a57" },
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
