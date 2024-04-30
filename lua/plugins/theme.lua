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
            transparent = require("user.config").transparent,
            overrides = function(_)
                local overrides = {
                    IblIndent = { fg = "#2E3440" },
                    IblScope = { fg = "#4A5263" },
                    CursorLineNr = { fg = "#ce5a57" },
                    CursorLine = { bg = "#2E3440" },
                }
                if not require("user.config").transparent then
                    return vim.tbl_extend("force", overrides, {
                        NoiceCmdLinePopupBorder = { fg = "#282727" },
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
