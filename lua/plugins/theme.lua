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
                local overrides = {
                    IblIndent = { fg = "#2E3440" },
                    IblScope = { fg = "gray" },
                    CursorLineNr = { fg = "#ce5a57" },
                    CursorLine = { bg = "#2E3440" },
                }
                colors.palette.oldWhite = colors.palette.fujiWhite
                if not require("user.config").transparent then
                    return vim.tbl_extend("force", overrides, {
                        NoiceCmdLinePopupBorder = { fg = "gray" },
                        NoiceCmdLinePopupTitle = { fg = "#181616", bg = "gray", bold = true },
                        NormalFloatBorder = { fg = "gray" },
                        FloatBorder = { fg = "gray" },
                        MiniFilesTitleFocused = { fg = "#ce5a57", bold = true },
                    })
                end
                return vim.tbl_extend("force", overrides, {
                    NoiceCmdLinePopupBorder = { fg = "gray" },
                })
            end,
        },
        config = function(_, opts)
            require("kanagawa").setup(opts)
            vim.cmd.colorscheme "kanagawa"
        end,
    },
}
