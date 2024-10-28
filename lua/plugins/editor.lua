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
        "echasnovski/mini.align",
        event = "BufReadPre",
        version = false,
        config = function(_, opts)
            require("mini.align").setup(opts)
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
        opts = function()
            local actions = require("glance").actions
            local window_picker_jump = function()
                local win = require("window-picker").pick_window()
                if not win or not vim.api.nvim_win_is_valid(win) then
                    return
                end
                actions.jump {
                    cmd = function()
                        vim.api.nvim_set_current_win(win)
                    end,
                }
            end

            return {
                use_trouble_qf = true,
                mappings = {
                    list = {
                        ["x"] = actions.jump_split,
                        ["w"] = window_picker_jump,
                        ["s"] = "",
                    },
                },
            }
        end,
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
                count = 20,
                float_opts = { width = vim.o.columns, height = vim.o.lines },
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
        "folke/zen-mode.nvim",
        cmd = { "ZenMode" },
        init = function()
            require("user.utils").load_keymap "zenmode"
        end,
        config = function(_, _)
            local opts = {
                window = { width = 0.75 },
                on_open = function(win)
                    local view = require "zen-mode.view"
                    local layout = view.layout(view.opts)
                    vim.api.nvim_win_set_config(win, {
                        width = layout.width,
                        height = layout.height - 1,
                    })
                    vim.api.nvim_win_set_config(view.bg_win, {
                        width = vim.o.columns,
                        height = view.height() - 1,
                        row = 1,
                        col = layout.col,
                        relative = "editor",
                    })
                end,
            }
            require("zen-mode").setup(opts)
        end,
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
        "MagicDuck/grug-far.nvim",
        cmd = "GrugFar",
        init = function()
            require("user.utils").load_keymap "grugfar"
        end,
        opts = {},
        config = function(_, opts)
            require("grug-far").setup(opts)
        end,
    },

    {
        "mbbill/undotree",
        cmd = "UndotreeToggle",
        init = function(_, _)
            vim.g.undotree_SetFocusWhenToggle = 1
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
        "kevinhwang91/nvim-ufo",
        enabled = false,
        dependencies = "kevinhwang91/promise-async",
        lazy = false,
        init = function()
            require("user.utils").load_keymap "ufo"
        end,
        opts = {
            provider_selector = function(bufnr, filetype, buftype)
                return { "treesitter", "indent" }
            end,
            enable_get_fold_virt_text = true,
            fold_virt_text_handler = function(virtText, lnum, endLnum, width, truncate, ctx)
                local filling = " ⋯ "
                local targetWidth = width
                local curWidth = 0
                table.insert(virtText, { filling, "Folded" })
                local endVirtText = ctx.get_fold_virt_text(endLnum)
                for i, chunk in ipairs(endVirtText) do
                    local chunkText = chunk[1]
                    local hlGroup = chunk[2]
                    if i == 1 then
                        chunkText = chunkText:gsub("^%s+", "")
                    end
                    local chunkWidth = vim.fn.strdisplaywidth(chunkText)
                    if targetWidth > curWidth + chunkWidth then
                        table.insert(virtText, { chunkText, hlGroup })
                    else
                        chunkText = truncate(chunkText, targetWidth - curWidth)
                        table.insert(virtText, { chunkText, hlGroup })
                        chunkWidth = vim.fn.strdisplaywidth(chunkText)
                        break
                    end
                    curWidth = curWidth + chunkWidth
                end
                return virtText
            end,
        },
        config = function(_, opts)
            require("ufo").setup(opts)
        end,
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

    {
        "gbprod/yanky.nvim",
        event = "BufReadPre",
        opts = { highlight = { timer = 150 } },
        keys = {
            {
                "<leader>sp",
                function()
                    require("telescope").extensions.yank_history.yank_history {}
                end,
                mode = { "n", "x" },
                desc = "Yank History",
            },
            -- stylua: ignore start
            { "y", "<Plug>(YankyYank)", mode = { "n", "x" }, desc = "Yank Text" },
            { "p", "<Plug>(YankyPutAfter)", mode = { "n", "x" }, desc = "Put Text After Cursor" },
            { "P", "<Plug>(YankyPutBefore)", mode = { "n", "x" }, desc = "Put Text Before Cursor" },
            -- { "gp", "<Plug>(YankyGPutAfter)", mode = { "n", "x" }, desc = "Put Text After Selection", },
            -- { "gP", "<Plug>(YankyGPutBefore)", mode = { "n", "x" }, desc = "Put Text Before Selection", },
            { "[y", "<Plug>(YankyCycleForward)", desc = "Cycle Forward Through Yank History" },
            { "]y", "<Plug>(YankyCycleBackward)", desc = "Cycle Backward Through Yank History" },
            { "]p", "<Plug>(YankyPutIndentAfterLinewise)", desc = "Put Indented After Cursor (Linewise)", },
            { "[p", "<Plug>(YankyPutIndentBeforeLinewise)", desc = "Put Indented Before Cursor (Linewise)", },
            { "]P", "<Plug>(YankyPutIndentAfterLinewise)", desc = "Put Indented After Cursor (Linewise)", },
            { "[P", "<Plug>(YankyPutIndentBeforeLinewise)", desc = "Put Indented Before Cursor (Linewise)", },
            { ">p", "<Plug>(YankyPutIndentAfterShiftRight)", desc = "Put and Indent Right" },
            { "<p", "<Plug>(YankyPutIndentAfterShiftLeft)", desc = "Put and Indent Left" },
            { ">P", "<Plug>(YankyPutIndentBeforeShiftRight)", desc = "Put Before and Indent Right", },
            { "<P", "<Plug>(YankyPutIndentBeforeShiftLeft)", desc = "Put Before and Indent Left" },
            { "=p", "<Plug>(YankyPutAfterFilter)", desc = "Put After Applying a Filter" },
            { "=P", "<Plug>(YankyPutBeforeFilter)", desc = "Put Before Applying a Filter" },
            -- stylua: ignore end
        },
    },

    {
        "sindrets/diffview.nvim",
        cmd = { "DiffviewOpen", "DiffviewClose" },
        init = function()
            require("user.utils").load_keymap "diffview"
        end,
        config = function()
            require("diffview").setup()
            vim.api.nvim_create_autocmd("FileType", {
                pattern = { "DiffviewFiles" },
                callback = function(event)
                    vim.bo[event.buf].buflisted = false
                    vim.keymap.set(
                        "n",
                        "q",
                        "<cmd>DiffviewClose<cr>",
                        { buffer = event.buf, silent = true }
                    )
                end,
            })
        end,
    },

    {
        "rachartier/tiny-inline-diagnostic.nvim",
        event = "LspAttach",
        opts = function()
            return {
                signs = {
                    left = " ",
                    right = "",
                    diag = "■",
                    arrow = "    ",
                    up_arrow = "    ",
                    vertical = " │",
                    vertical_end = " └",
                },
            }
        end,
        config = function(_, opts)
            require("tiny-inline-diagnostic").setup(opts)
        end,
    },
}
