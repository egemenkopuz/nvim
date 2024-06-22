return {
    {
        "echasnovski/mini.move",
        event = "BufReadPre",
        config = function(_, opts)
            require("mini.move").setup(opts)
        end,
    },

    {
        "echasnovski/mini.splitjoin",
        event = "BufReadPre",
        version = false,
        opts = { mappings = { toggle = "<leader>ce" } },
        config = function(_, opts)
            require("mini.splitjoin").setup(opts)
        end,
    },

    {
        "smjonas/inc-rename.nvim",
        dependencies = { "folke/noice.nvim" },
        event = "BufReadPre",
        opts = { save_in_cmdline_history = false },
        config = function(_, opts)
            require("inc_rename").setup(opts)
            require("user.utils").load_keymap "rename"
        end,
    },

    {
        "dnlhc/glance.nvim",
        event = "BufReadPre",
        opts = {
            border = { enable = true, top_char = "―", bottom_char = "―" },
            use_trouble_qf = true,
        },
        config = function(_, opts)
            require("glance").setup(opts)
            require("user.utils").load_keymap "glance"
        end,
    },

    {
        "lewis6991/gitsigns.nvim",
        event = { "BufReadPre", "BufNewFile" },
        opts = {
            signs_staged_enable = true,
            signs_staged = {
                add = { text = "│" },
                change = { text = "│" },
                delete = { text = "▁" },
                topdelete = { text = "▔" },
                changedelete = { text = "▁" },
            },
            signs = {
                add = { text = "│" },
                change = { text = "│" },
                delete = { text = "▁" },
                topdelete = { text = "▔" },
                changedelete = { text = "▁" },
            },
            current_line_blame_formatter = "<author> - <author_time:%Y-%m-%d> - <summary>",
            current_line_blame = false,
            current_line_blame_opts = {
                virt_text = true,
                virt_text_pos = "eol",
                delay = 350,
                ignore_whitespace = false,
            },
            on_attach = function(bufnr)
                require("user.utils").load_keymap("gitsigns", { buffer = bufnr })
            end,
        },
    },

    {
        "akinsho/toggleterm.nvim",
        version = "*",
        event = "BufReadPre",
        opts = {
            size = 20,
            open_mapping = [[<c-\>]],
            hide_numbers = true,
            shade_filetypes = {},
            shade_terminals = true,
            shading_factor = 2,
            start_in_insert = true,
            direction = "float",
            float_opts = {
                border = "single",
                winblend = 0,
                highlights = { border = "Normal", background = "Normal" },
            },
        },
        config = function(_, opts)
            require("toggleterm").setup(opts)
            local Terminal = require("toggleterm.terminal").Terminal
            local lazygit = Terminal:new {
                cmd = "lazygit",
                hidden = true,
                count = 2,
                on_close = function()
                    vim.cmd [[ "<Cmd>nohlsearch<Bar>diffupdate<Bar>normal! <C-L><CR>" ]]
                end,
            }
            function _LAZYGIT_TOGGLE()
                lazygit:toggle()
            end
            require("user.utils").load_keymap "toggleterm"
        end,
    },

    {
        "folke/trouble.nvim",
        cmd = { "TroubleToggle", "Trouble" },
        opts = {
            focus = true,
            modes = {
                diagnostics_preview = {
                    mode = "diagnostics",
                    preview = {
                        type = "split",
                        relative = "win",
                        position = "right",
                        size = 0.3,
                    },
                },
            },
        },
        init = function()
            require("user.utils").load_keymap "trouble"
        end,
        config = function(_, opts)
            require("trouble").setup(opts)
        end,
    },

    {
        "shortcuts/no-neck-pain.nvim",
        cmd = { "NoNeckPain" },
        init = function()
            require("user.utils").load_keymap "zenmode"
        end,
        opts = {
            width = 120,
            mappings = { toggle = false, widthUp = false, widthDown = false, scratchPad = false },
        },
    },

    {
        "ruifm/gitlinker.nvim",
        event = "BufReadPre",
        opts = { mappings = nil },
        config = function(_, opts)
            require("gitlinker").setup(opts)
            require("user.utils").load_keymap "gitlinker"
        end,
    },

    {
        "echasnovski/mini.bufremove",
        event = "BufReadPre",
        config = function(_, _)
            require("user.utils").load_keymap "bufremove"
        end,
    },

    {
        "iamcco/markdown-preview.nvim",
        ft = "markdown",
        build = function()
            vim.fn["mkdp#util#install"]()
        end,
    },

    {
        "windwp/nvim-spectre",
        build = false,
        cmd = "Spectre",
        opts = { open_cmd = "noswapfile vnew" },
        init = function()
            require("user.utils").load_keymap "spectre"
        end,
    },

    {
        "mbbill/undotree",
        cmd = "UndotreeToggle",
        init = function(_, _)
            require("user.utils").load_keymap "undotree"
        end,
    },

    {
        "hedyhli/outline.nvim",
        lazy = true,
        cmd = { "Outline", "OutlineOpen" },
        init = function()
            require("user.utils").load_keymap "symbols"
        end,
        opts = function()
            local opts = { symbols = {} }
            local kinds = require("user.config").icons.kinds
            for k, v in pairs(kinds) do
                opts.symbols[k] = { icon = v }
            end
            return opts
        end,
    },

    {
        "danymat/neogen",
        event = "BufReadPre",
        dependencies = "nvim-treesitter/nvim-treesitter",
        init = function()
            require("user.utils").load_keymap "neogen"
        end,
        opts = { snippet_engine = "luasnip" },
        config = true,
    },

    {
        "mg979/vim-visual-multi",
        event = "BufReadPre",
        init = function()
            vim.g.VM_default_mappings = 0
            vim.g.VM_maps = { ["Find Under"] = "" }
            vim.g.VM_add_cursor_at_pos_no_mappings = 1
            vim.g.VM_set_statusline = 0
            vim.g.VM_silent_exit = 1
            require("user.utils").load_keymap "visual_multi"
        end,
    },
}
