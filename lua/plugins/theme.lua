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
                local colors = require "user.colors"
                out = vim.tbl_deep_extend("force", out, require("user.highlights").dim)
                if vim.g.transparent then
                    out = vim.tbl_deep_extend("force", out, require("user.highlights").transparent)
                else
                    local bg_color = "#19191a"
                    -- stylua: ignore start
                    out["Normal"] = { bg = bg_color }
                    out["NormalNC"] = { bg = bg_color }
                    out["NormalFloat"] = { bg = bg_color }
                    out["StatusLine"] = { bg = bg_color }
                    out["MiniTablineCurrent"] = { fg = colors.custom.gray3, bg = bg_color, bold = true }
                    out["MiniTablineHidden"] = { fg = colors.custom.gray2, bg = bg_color }
                    out["MiniTablineVisible"] = { fg = colors.custom.gray2, bg = bg_color }
                    out["StatusLineBackground"] = { bg = bg_color }
                    -- stylua: ignore end
                end
                out["TreesitterContextLineNumber"] = { fg = "#4f4f4f", bg = "#19191a" }
                out["SnacksIndentScope"] = { fg = "#4f4f4f" }
                out["SnacksIndentBlank"] = { fg = "#4f4f4f" }
                out["SnacksIndent"] = { fg = "#4f4f4f" }
                out["@variable.parameter"] = { fg = "#ccc7ca" }
                out["@string.documentation"] = { fg = "#908d8f" }
                out["Comment"] = { fg = "#908d8f" }
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

    {
        "metalelf0/black-metal-theme-neovim",
        enabled = require("user.utils").colorscheme_selection "black-metal",
        lazy = false,
        priority = 1000,
        config = function()
            local out = require("user.highlights").general
            out = vim.tbl_deep_extend("force", out, require("user.highlights").dim)
            require("black-metal").setup {
                theme = "khold",
                colored_docstrings = false,
                highlights = {
                    ["@variable.parameter"] = { fg = "#ccc7ca" },
                    ["@lsp.type.parameter"] = { fg = "#8eaff2", fmt = "italic" },
                    ["@function"] = { fg = "#8a9a7b", fmt = "bold" },
                },
            }
            require("black-metal").load()

            for group, settings in pairs(out) do
                vim.api.nvim_set_hl(0, group, settings)
            end
        end,
    },
}
