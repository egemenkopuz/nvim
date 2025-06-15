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

    {
        "drewxs/ash.nvim",
        enabled = require("user.utils").colorscheme_selection "ash",
        priority = 1000,
        lazy = false,
        opts = {
            transparent = vim.g.transparent,
            highlights = function(_)
                local out = require("user.highlights").general
                out = vim.tbl_deep_extend("force", out, require("user.highlights").dim)
                if vim.g.transparent then
                    out = vim.tbl_deep_extend("force", out, require("user.highlights").transparent)
                else
                    out["Normal"] = { bg = "#19191a" }
                    out["NormalNC"] = { bg = "#19191a" }
                    out["NormalFloat"] = { bg = "#19191a" }
                end
                out["@variable.parameter"] = { fg = "#B7B7B7" }
                out["SnacksDashboardDesc"] = { fg = "#B7B7B7" }
                out["RenderMarkdownCode"] = { fg = "#8a9a7b", bg = "#1e1e1e" }
                out["LspInlayHint"] = { fg = "#838383", italic = true }
                out["LineNr"] = { fg = "#4f4f4f" }
                return out
            end,
        },
        config = function(_, opts)
            require("ash").setup(opts)
            vim.cmd.colorscheme "ash"
        end,
    },
}
