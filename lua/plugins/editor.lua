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
                border = {
                    enable = vim.g.transparent,
                    top_char = "―",
                    bottom_char = "―",
                },
                mappings = {
                    list = {
                        ["s"] = actions.jump_split,
                        ["w"] = window_picker_jump,
                        ["<C-b>"] = actions.preview_scroll_win(5),
                        ["<C-f>"] = actions.preview_scroll_win(-5),
                        ["<C-u>"] = false,
                        ["<C-d>"] = false,
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
            float_opts = { border = "single", winblend = 0 },
            highlights = { FloatBorder = { guifg = "#524C42" } },
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
            auto_preview = false,
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
        "brianhuster/live-preview.nvim",
        cmd = "LivePreview",
        dependencies = { "ibhagwan/fzf-lua" },
        opts = { picker = "fzf-lua" },
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
            local kinds = require("user.icons").kinds
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
        opts = { snippet_engine = "nvim" },
        config = true,
    },

    {
        "kevinhwang91/nvim-ufo",
        enabled = true,
        dependencies = "kevinhwang91/promise-async",
        lazy = false,
        init = function()
            require("user.utils").load_keymap "ufo"
        end,
        opts = {
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
        "gbprod/yanky.nvim",
        event = "BufReadPre",
        init = function()
            require("user.utils").load_keymap "yanky"
        end,
        opts = { highlight = { timer = 150 } },
    },

    {
        "sindrets/diffview.nvim",
        cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewFileHistory" },
        init = function()
            require("user.utils").load_keymap "diffview"
        end,
        opts = function()
            local actions = require "diffview.actions"
            return {
                enhanced_diff_hl = true,
                view = {
                    default = { disable_diagnostics = true },
                    merge_tool = { layout = "diff3_mixed" },
                    file_panel = {
                        win_config = {
                            position = "bottom",
                            height = 10,
                        },
                    },
                    file_history_panel = {
                        win_config = {
                            type = "split",
                            position = "bottom",
                            height = 10,
                        },
                    },
                },
                keymaps = {
                    disable_defaults = true,
                    view = {
                        -- stylua: ignore start
                        { "n", "<C-f>", actions.toggle_files, { desc = "Toggle the file panel" } },
			{ "n", "gf", actions.goto_file_edit, { desc = "Open the file in the previous tabpage" } },
			{ "n", "co", actions.conflict_choose_all("ours"), { desc = "Choose conflict --ours" } },
			{ "n", "ct", actions.conflict_choose_all("theirs"), { desc = "Choose conflict --theirs" } },
			{ "n", "cb", actions.conflict_choose_all("base"), { desc = "Choose conflict --base" } },
                        -- stylua: ignore end
                        ["gq"] = function()
                            if vim.fn.tabpagenr "$" > 1 then
                                vim.cmd.DiffviewClose()
                            else
                                vim.cmd.quitall()
                            end
                        end,
                    },
                    file_panel = {
                        -- stylua: ignore start
                        { "n", "j", actions.next_entry, { desc = "Bring the cursor to the next file entry" } },
			{ "n", "<down>", actions.select_next_entry, { desc = "Select the next file entry" } },
			{ "n", "k", actions.prev_entry, { desc = "Bring the cursor to the previous file entry" } },
			{ "n", "<up>", actions.select_prev_entry, { desc = "Select the previous file entry" } },
			{ "n", "<cr>", actions.select_entry, { desc = "Open the diff for the selected entry" } },
			{ "n", "<C-f>", actions.toggle_files, { desc = "Toggle the file panel" } },
			{ "n", "s", actions.toggle_stage_entry, { desc = "Stage/unstage the selected entry" } },
			{ "n", "S", actions.stage_all, { desc = "Stage all entries" } },
			{ "n", "U", actions.unstage_all, { desc = "Unstage all entries" } },
			{ "n", "c-", actions.prev_conflict, { desc = "Go to prev conflict" } },
			{ "n", "c+", actions.next_conflict, { desc = "Go to next conflict" } },
			{ "n", "gf", actions.goto_file_edit, { desc = "Open the file in the previous tabpage" } },
			{ "n", "co", actions.conflict_choose_all("ours"), { desc = "Choose conflict --ours" } },
			{ "n", "ct", actions.conflict_choose_all("theirs"), { desc = "Choose conflict --theirs" } },
			{ "n", "cb", actions.conflict_choose_all("base"), { desc = "Choose conflict --base" } },
			{ "n", "<Right>", actions.open_fold, { desc = "Expand fold" } },
			{ "n", "<Left>", actions.close_fold, { desc = "Collapse fold" } },
			{ "n", "l", actions.listing_style, { desc = "Toggle between 'list' and 'tree' views" } },
			{ "n", "L", actions.open_commit_log, { desc = "Open the commit log panel" } },
			{ "n", "g?", actions.help("file_panel"), { desc = "Open the help panel" } },
                        -- stylua: ignore end
                        ["gq"] = function()
                            if vim.fn.tabpagenr "$" > 1 then
                                vim.cmd.DiffviewClose()
                            else
                                vim.cmd.quitall()
                            end
                        end,
                        {
                            "n",
                            "cc",
                            function()
                                vim.ui.input({ prompt = "Commit message: " }, function(msg)
                                    if not msg then
                                        return
                                    end
                                    local results = vim.system(
                                        { "git", "commit", "-m", msg },
                                        { text = true }
                                    ):wait()
                                    vim.notify(
                                        results.stdout,
                                        vim.log.levels.INFO,
                                        { title = "Commit", render = "simple" }
                                    )
                                end)
                            end,
                        },
                        {
                            "n",
                            "cx",
                            function()
                                local results = vim.system(
                                    { "git", "commit", "--amend", "--no-edit" },
                                    { text = true }
                                ):wait()
                                vim.notify(
                                    results.stdout,
                                    vim.log.levels.INFO,
                                    { title = "Commit amend", render = "simple" }
                                )
                            end,
                        },
                    },
                    diff2 = {
                        { "n", "++", "]c" },
                        { "n", "--", "[c" },
                    },
                    file_history_panel = {
                        -- stylua: ignore start
                        { "n", "j", actions.next_entry, { desc = "Bring the cursor to the next log entry" } },
			{ "n", "<down>", actions.select_next_entry, { desc = "Select the next log entry" } },
			{ "n", "k", actions.prev_entry, { desc = "Bring the cursor to the previous log entry." } },
			{ "n", "<up>", actions.select_prev_entry, { desc = "Select the previous file entry." } },
			{ "n", "<cr>", actions.select_entry, { desc = "Open the diff for the selected entry." } },
			{ "n", "gd", actions.open_in_diffview, { desc = "Open the entry under the cursor in a diffview" } },
			{ "n", "y", actions.copy_hash, { desc = "Copy the commit hash of the entry under the cursor" } },
			{ "n", "L", actions.open_commit_log, { desc = "Show commit details" } },
			{ "n", "gf", actions.goto_file_edit, { desc = "Open the file in the previous tabpage" } },
			{ "n", "g?", actions.help("file_history_panel"), { desc = "Open the help panel" } },
			["gq"] = function()
				if vim.fn.tabpagenr("$") > 1 then
					vim.cmd.DiffviewClose()
				else
					vim.cmd.quitall()
				end
			end,
                        -- stylua: ignore end
                    },
                    help_panel = {
                        { "n", "q", actions.close, { desc = "Close help menu" } },
                    },
                },
            }
        end,
        config = function(_, opts)
            require("diffview").setup(opts)
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
        event = "VeryLazy",
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
                options = {
                    multiple_diag_under_cursor = true,
                    multilines = true,
                    show_all_diags_on_cursorline = true,
                },
            }
        end,
        config = function(_, opts)
            require("tiny-inline-diagnostic").setup(opts)
        end,
    },
}
