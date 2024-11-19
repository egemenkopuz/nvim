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
            dimInactive = not vim.g.transparent,
            transparent = vim.g.transparent,
            overrides = function(colors)
                colors.palette.oldWhite = colors.palette.fujiWhite
                local out = require("user.highlights").general
                if vim.g.transparent then
                    out = vim.tbl_deep_extend("force", out, require("user.highlights").transparent)
                end

                return out
            end,
        },
        config = function(_, opts)
            require("kanagawa").setup(opts)
            vim.cmd.colorscheme "kanagawa"
        end,
    },
}
