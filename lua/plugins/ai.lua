return {

    {
        "yetone/avante.nvim",
        event = "VeryLazy",
        lazy = false,
        version = false,
        init = function()
            require("user.utils").load_keymap "avante"
        end,
        opts = {
            provider = "copilot",
            behaviour = {
                auto_suggestions = false,
                auto_set_highlight_group = true,
                auto_set_keymaps = false,
                auto_apply_diff_after_generation = false,
                support_paste_from_clipboard = false,
                minimize_diff = true,
            },
            windows = {
                position = "right",
                wrap = true,
                width = 30,
                sidebar_header = { enabled = false },
                input = { prefix = "> ", height = 8 },
                edit = { border = require("user.icons").border, start_insert = true },
                ask = {
                    floating = false,
                    border = require("user.icons").border,
                    focus_on_apply = "ours",
                },
            },
        },
        build = "make",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "MunifTanjim/nui.nvim",
            "MeanderingProgrammer/render-markdown.nvim",
        },
    },

    {
        "zbirenbaum/copilot.lua",
        init = function()
            require("user.utils").load_keymap "copilot"
        end,
        opts = {
            suggestion = {
                enabled = true,
                auto_trigger = true,
                keymap = {
                    accept = false,
                    dismiss = false,
                    next = "<C-]>",
                    prev = "<C-[>",
                },
            },
            panel = { enabled = false },
            filetypes = {
                markdown = true,
                yaml = function()
                    if string.find(vim.fs.basename(vim.api.nvim_buf_get_name(0)), "secret") then
                        return false
                    end
                    return true
                end,
                sh = function()
                    if string.match(vim.fs.basename(vim.api.nvim_buf_get_name(0)), "^%.env.*") then
                        return false
                    end
                    return true
                end,
            },
        },
    },
}
