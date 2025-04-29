local archived = {
    {
        "nvim-telescope/telescope.nvim",
        dependencies = {
            "nvim-lua/plenary.nvim",
            {
                "nvim-telescope/telescope-fzf-native.nvim",
                build = vim.fn.executable "make" == 1 and "make"
                    or "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build",
            },
            {
                "danielfalk/smart-open.nvim",
                branch = "0.2.x",
                config = function()
                    require("telescope").load_extension "smart_open"
                end,
                dependencies = { "kkharji/sqlite.lua" },
            },
            "nvim-telescope/telescope-live-grep-args.nvim",
            "nvim-telescope/telescope-ui-select.nvim",
            "ANGkeith/telescope-terraform-doc.nvim",
            "olimorris/persisted.nvim",
            "ahmedkhalf/project.nvim",
            "folke/noice.nvim",
            {
                "rachartier/tiny-code-action.nvim",
                dependencies = {
                    { "nvim-lua/plenary.nvim" },
                    { "nvim-telescope/telescope.nvim" },
                },
                event = "LspAttach",
                opts = {
                    telescope_opts = {
                        layout_strategy = "vertical",
                        layout_config = {
                            width = 0.6,
                            height = 0.8,
                            preview_cutoff = 1,
                            preview_height = function(_, _, max_lines)
                                local h = math.floor(max_lines * 0.5)
                                return math.max(h, 10)
                            end,
                        },
                    },
                },
                config = function(_, opts)
                    require("user.utils").load_keymap "tiny_code_action"
                    require("tiny-code-action").setup(opts)
                end,
            },
        },
        cmd = "Telescope",
        version = false,
        -- init = function()
        --     require("user.utils").load_keymap "telescope"
        -- end,
        opts = {
            defaults = {
                vimgrep_arguments = {
                    "rg",
                    "--color=never",
                    "--no-heading",
                    "--with-filename",
                    "--line-number",
                    "--column",
                    "--smart-case",
                    "--hidden",
                    "--glob",
                    "!**/.git/*",
                },
                prompt_prefix = "   ",
                selection_caret = "  ",
                entry_prefix = "  ",
                initial_mode = "insert",
                selection_strategy = "reset",
                sorting_strategy = "ascending",
                layout_strategy = "horizontal",
                layout_config = {
                    horizontal = {
                        prompt_position = "top",
                        preview_width = 0.55,
                        results_width = 0.8,
                    },
                    vertical = { mirror = false },
                    width = 0.87,
                    height = 0.80,
                    preview_cutoff = 120,
                },
                path_display = { "truncate" },
                winblend = 0,
                color_devicons = true,
                set_env = { ["COLORTERM"] = "truecolor" },
            },
            extensions = {
                fzf = {
                    fuzzy = true,
                    override_generic_sorter = true,
                    override_file_sorter = true,
                    case_mode = "smart_case",
                },
                extensions = {
                    smart_open = { match_algorithm = "fzf" },
                },
            },
        },
        config = function(_, opts)
            local telescope = require "telescope"
            local actions = require "telescope.actions"
            local lga_actions = require "telescope-live-grep-args.actions"

            opts.extensions["ui-select"] = {
                require("telescope.themes").get_dropdown {
                    layout_strategy = "cursor",
                    layout_config = { prompt_position = "top", width = 80, height = 12 },
                },
            }
            opts.extensions["live_grep_args"] = {
                auto_quoting = true,
                mappings = { -- extend mappings
                    i = {
                        ["<C-k>"] = lga_actions.quote_prompt(),
                        ["<C-i>"] = lga_actions.quote_prompt { postfix = " --iglob " },
                        -- freeze the current list and start a fuzzy search in the frozen list
                        ["<C-space>"] = actions.to_fuzzy_refine,
                    },
                },
            }
            opts.defaults.mappings = { n = { ["q"] = actions.close } }

            telescope.setup(opts)

            telescope.load_extension "fzf"
            telescope.load_extension "live_grep_args"
            telescope.load_extension "ui-select"
            telescope.load_extension "projects"
            telescope.load_extension "persisted"
            telescope.load_extension "noice"
            telescope.load_extension "terraform_doc"

            if not vim.g.transparent then
                local tc1 = "#282727"
                local tc2 = "#7FB4CA"
                local tc3 = "#181616"
                local tc4 = "#FF5D62"

                local hl_group = {
                    TelescopeMatching = { fg = tc2 },
                    TelescopeSelection = { fg = tc2, bg = tc1 },
                    TelescopePromptTitle = { fg = tc3, bg = tc4, bold = true },
                    TelescopePromptPrefix = { fg = tc2 },
                    TelescopePromptCounter = { fg = tc2 },
                    -- TelescopePromptBorder = { fg = tc1 },
                    -- TelescopeResultsNormal = { bg = tc3 },
                    TelescopeResultsTitle = { fg = tc3, bg = "lightgray", bold = true },
                    -- TelescopeResultsBorder = { fg = tc1 },
                    TelescopePreviewTitle = { fg = tc3, bg = tc2, bold = true },
                    -- TelescopePreviewNormal = { bg = tc3 },
                    -- TelescopePreviewBorder = { fg = tc1 },
                    TelescopeBorder = { fg = "gray", bg = "none" },
                }
                for k, v in pairs(hl_group) do
                    vim.api.nvim_set_hl(0, k, v)
                end
            else
                for _, k in ipairs { "TelescopeBorder" } do
                    vim.api.nvim_set_hl(0, k, { fg = "gray", bg = "none" })
                end
            end
        end,
    },

    {
        "folke/persistence.nvim",
        event = "BufReadPre",
        opts = {},
      -- stylua: ignore
      keys = {
        { "<leader>qs", function() require("persistence").load() end, desc = "Restore Session" },
        { "<leader>qS", function() require("persistence").select() end,desc = "Select Session" },
        { "<leader>ql", function() require("persistence").load({ last = true }) end, desc = "Restore Last Session" },
        { "<leader>qd", function() require("persistence").stop() end, desc = "Don't Save Current Session" },
      },
    },

    {
        "hrsh7th/nvim-cmp",
        version = false,
        event = "InsertEnter",
        dependencies = {
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",
            {
                "L3MON4D3/LuaSnip",
                dependencies = {
                    "rafamadriz/friendly-snippets",
                    config = function()
                        require("luasnip.loaders.from_vscode").lazy_load()
                    end,
                },
                opts = { history = true, delete_check_events = "TextChanged" },
                -- stylua: ignore
                keys = {
                    { "<tab>", function() return require("luasnip").jumpable(1) and "<Plug>luasnip-jump-next" or "<tab>" end, expr = true, silent = true, mode = "i", },
                    { "<tab>", function() require("luasnip").jump(1) end, mode = "s", },
                    { "<s-tab>", function() require("luasnip").jump(-1) end, mode = { "i", "s" }, },
                },
            },
            "saadparwaiz1/cmp_luasnip",
            "zbirenbaum/copilot-cmp",
        },
        opts = function()
            local cmp = require "cmp"
            return {
                window = {
                    completion = cmp.config.window.bordered {
                        scrollbar = false,
                        border = { "┌", "─", "┐", "│", "┘", "─", "└", "│" },
                    },
                    documentation = cmp.config.window.bordered {
                        scrollbar = false,
                        border = { "┌", "─", "┐", "│", "┘", "─", "└", "│" },
                    },
                },
                completion = { completeopt = "menu,menuone,noinsert" },
                snippet = {
                    expand = function(args)
                        require("luasnip").lsp_expand(args.body)
                    end,
                },
                mapping = cmp.mapping.preset.insert {
                    ["<C-d>"] = cmp.mapping.scroll_docs(4),
                    ["<C-u>"] = cmp.mapping.scroll_docs(-4),
                    ["<C-e>"] = cmp.mapping.abort(),
                    ["<C-y>"] = cmp.mapping.confirm { select = true },
                    ["<S-CR>"] = cmp.mapping.confirm {
                        behavior = cmp.ConfirmBehavior.Replace,
                        select = true,
                    },
                    ["<C-n>"] = cmp.mapping.select_next_item { behavior = cmp.SelectBehavior.Insert },
                    ["<C-p>"] = cmp.mapping.select_prev_item { behavior = cmp.SelectBehavior.Insert },
                    ["<C-CR>"] = function(fallback)
                        cmp.abort()
                        fallback()
                    end,
                },
                sources = cmp.config.sources {
                    { name = "copilot", group_index = 0 },
                    { name = "nvim_lsp", max_item_count = 20, group_index = 0 },
                    { name = "buffer", max_item_count = 20, group_index = 0 },
                    { name = "nvim_lua", max_item_count = 20, group_index = 0 },
                    { name = "crates", group_index = 0 },
                    { name = "luasnip", group_index = 1 },
                    { name = "path", group_index = 1 },
                    { name = "lazydev", group_index = 1 },
                },
                formatting = {
                    format = function(_, item)
                        local icons = require("user.icons").kinds
                        if icons[item.kind] then
                            item.kind = icons[item.kind] .. item.kind
                        end
                        local widths = {
                            abbr = vim.g.cmp_widths and vim.g.cmp_widths.abbr or 40,
                            menu = vim.g.cmp_widths and vim.g.cmp_widths.menu or 30,
                        }

                        for key, width in pairs(widths) do
                            if item[key] and vim.fn.strdisplaywidth(item[key]) > width then
                                item[key] = vim.fn.strcharpart(item[key], 0, width - 1) .. "…"
                            end
                        end

                        return item
                    end,
                },
                formatters = { insert_text = require("copilot_cmp.format").remove_existing },
                sorting = {
                    priority_weight = 2,
                    comparators = {
                        require("copilot_cmp.comparators").prioritize,
                        require("copilot_cmp.comparators").score,
                        cmp.config.compare.offset,
                        cmp.config.compare.exact,
                        cmp.config.compare.score,
                        cmp.config.compare.recently_used,
                        cmp.config.compare.locality,
                        cmp.config.compare.kind,
                        cmp.config.compare.sort_text,
                        cmp.config.compare.length,
                        cmp.config.compare.order,
                    },
                },
                experimental = { ghost_text = { hl_group = "LspCodeLens" } },
            }
        end,
    },

    {
        "zbirenbaum/copilot-cmp",
        event = "InsertEnter",
        dependencies = {
            "zbirenbaum/copilot.lua",
            opts = {
                suggestion = { enabled = false },
                panel = { enabled = false },
                filetypes = {
                    markdown = true,
                    sh = function()
                        if
                            string.match(vim.fs.basename(vim.api.nvim_buf_get_name(0)), "^%.env.*")
                        then
                            return false
                        end
                        return true
                    end,
                },
            },
        },
        opts = { method = "getCompletionsCycling" },
        config = function(_, opts)
            require("copilot_cmp").setup(opts)
        end,
    },

    {
        "RRethy/vim-illuminate",
        opts = {
            delay = 200,
            providers = { "lsp", "treesitter", "regex" },
            filetypes_denylist = {
                "neo-tree",
                "notify",
                "dirvish",
                "fugitive",
                "lazy",
                "mason",
                "Outline",
                "no-neck-pain",
                "undotree",
                "diff",
                "Glance",
                "trouble",
                "copilot-chat",
            },
        },
        config = function(_, opts)
            require("illuminate").configure(opts)
            vim.api.nvim_create_autocmd("FileType", {
                callback = function()
                    local buffer = vim.api.nvim_get_current_buf()
                    pcall(vim.keymap.del, "n", "]]", { buffer = buffer })
                    pcall(vim.keymap.del, "n", "[[", { buffer = buffer })
                end,
            })
            require("user.utils").load_keymap "illuminate"
        end,
    },

    {
        "nvimtools/none-ls.nvim",
        event = "BufReadPre",
        dependencies = { "mason.nvim" },
        config = function()
            local nls = require "null-ls"
            local utils = require "user.utils"
            local packages = require("user.config").nulls_packages
            local sources = {}

            for t_pkg, pkgs in pairs(packages) do
                for _, pckg in ipairs(pkgs) do
                    if type(pckg) == "table" then
                        table.insert(sources, nls.builtins[t_pkg][pckg[1]].with { pckg[2] })
                    else
                        table.insert(sources, nls.builtins[t_pkg][pckg])
                    end
                end
            end

            nls.setup { sources = sources, on_attach = utils.formatting() }
        end,
    },

    {
        "lukas-reineke/indent-blankline.nvim",
        enabled = false,
        event = "BufReadPre",
        main = "ibl",
        opts = {
            indent = { char = "│" },
            scope = { enabled = true, show_start = false, show_end = false },
            exclude = {
                filetypes = {
                    "help",
                    "alpha",
                    "dashboard",
                    "neo-tree",
                    "Trouble",
                    "trouble",
                    "lazy",
                    "mason",
                    "notify",
                    "toggleterm",
                    "lazyterm",
                    "copilot-chat",
                },
            },
        },
        config = function(_, opts)
            require("ibl").setup(opts)
        end,
    },

    {
        "ruifm/gitlinker.nvim",
        enabled = false,
        event = "BufReadPre",
        opts = { mappings = nil },
        config = function(_, opts)
            require("gitlinker").setup(opts)
            require("user.utils").load_keymap "gitlinker"
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
        "Civitasv/cmake-tools.nvim",
        enabled = false,
        depends = { "nvim-lua/plenary.nvim", "stevearc/overseer.nvim" },
        ft = { "cmake", "cpp" },
        opts = {
            cmake_executor = {
                name = "overseer",
                default_opts = {
                    overseer = {
                        new_task_opts = {
                            strategy = {
                                "toggleterm",
                                direction = "horizontal",
                                autos_croll = true,
                                quit_on_exit = "success",
                            },
                        },
                    },
                    toggleterm = { direction = "horizontal" },
                },
            },
        },
        config = function(_, opts)
            require("cmake-tools").setup(opts)
        end,
    },

    {
        "kawre/leetcode.nvim",
        enabled = false,
        build = ":TSUpdate html",
        lazy = "leetcode.nvim" ~= vim.fn.argv()[1],
        dependencies = {
            "nvim-telescope/telescope.nvim",
            "MunifTanjim/nui.nvim",
            "nvim-treesitter/nvim-treesitter",
        },
        opts = {
            storage = {
                home = vim.fn.expand "~/workspace/competitive-programming/answers/leetcode/",
                cache = vim.fn.stdpath "cache" .. "/leetcode",
            },
            injector = {
                ["cpp"] = {
                    before = { "#include <bits/stdc++.h>", "using namespace std;" },
                    after = {},
                },
            },
        },
    },

    {
        "akinsho/bufferline.nvim",
        enabled = false,
        event = "BufReadPre",
        opts = {
            highlights = {
                tab_separator = { fg = "none", bg = "none" },
                tab_separator_selected = { fg = "none", bg = "none" },
                separator_selected = { fg = "none", bg = "none" },
                separator_visible = { fg = "none", bg = "none" },
                separator = { fg = "none", bg = "none" },
            },
            options = {
                numbers = function(opts)
                    return opts.raise(opts.ordinal)
                end,
                offsets = {
                    {
                        filetype = "undotree",
                        text = "Undo History",
                        padding = 0,
                        text_align = "center",
                        highlight = "Offset",
                    },
                    {
                        filetype = "Outline",
                        text = "LSP Symbols",
                        padding = 0,
                        text_align = "center",
                        highlight = "Offset",
                    },
                },
                diagnostics = "nvim_lsp",
                show_buffer_close_icons = false,
                show_close_icon = false,
                color_icons = false,
                close_command = function(n)
                    Snacks.bufdelete { buf = n }
                end,
                right_mouse_command = function(n)
                    Snacks.bufdelete { buf = n }
                end,
                always_show_bufferline = false,
            },
        },
        config = function(_, opts)
            opts.options.groups = {
                items = {
                    require("bufferline.groups").builtin.pinned:with { icon = "" },
                },
            }
            require("bufferline").setup(opts)
            require("user.utils").load_keymap "bufferline"

            -- Fix bufferline when restoring a session
            vim.api.nvim_create_autocmd({ "BufAdd", "BufDelete" }, {
                callback = function()
                    vim.schedule(function()
                        pcall(nvim_bufferline)
                    end)
                end,
            })
        end,
    },

    {
        "yetone/avante.nvim",
        enabled = false,
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
            mappings = {
                diff = {
                    ours = "co",
                    theirs = "ct",
                    all_theirs = "ca",
                    both = "cb",
                    cursor = "cc",
                    next = "]a",
                    prev = "[a",
                },
                jump = { next = "]]", prev = "[[" },
                submit = { normal = "<CR>", insert = "<C-s>" },
                sidebar = {
                    apply_all = "A",
                    apply_cursor = "a",
                    switch_windows = "<Tab>",
                    reverse_switch_windows = "<S-Tab>",
                },
            },
            hints = { enabled = false },
        },
        build = "make",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "MunifTanjim/nui.nvim",
            "MeanderingProgrammer/render-markdown.nvim",
        },
    },

    {
        "ibhagwan/fzf-lua",
        enabled = false,
        cmd = "FzfLua",
        lazy = false,
        keys = {
            { "<c-j>", "<c-j>", ft = "fzf", mode = "t", nowait = true },
            { "<c-k>", "<c-k>", ft = "fzf", mode = "t", nowait = true },
        },
        opts = function(_, opts)
            local fzf = require "fzf-lua"
            local config = require "fzf-lua.config"
            local actions = require "fzf-lua.actions"
            local utils = require "user.utils"

            config.defaults.keymap.fzf["ctrl-q"] = "select-all+accept"
            config.defaults.keymap.fzf["ctrl-u"] = "half-page-up"
            config.defaults.keymap.fzf["ctrl-d"] = "half-page-down"
            config.defaults.keymap.fzf["ctrl-f"] = "preview-page-down"
            config.defaults.keymap.fzf["ctrl-b"] = "preview-page-up"
            config.defaults.keymap.builtin["<c-f>"] = "preview-page-down"
            config.defaults.keymap.builtin["<c-b>"] = "preview-page-up"

            -- Trouble
            config.defaults.actions.files["ctrl-t"] = require("trouble.sources.fzf").actions.open

            -- Toggle root dir / cwd
            config.defaults.actions.files["ctrl-r"] = function(_, ctx)
                local o = vim.deepcopy(ctx.__call_opts)
                o.root = o.root == false
                o.cwd = nil
                o.buf = ctx.__CTX.bufnr
                utils.pick(ctx.__INFO.cmd, o)
            end

            config.defaults.actions.files["alt-c"] = config.defaults.actions.files["ctrl-r"]
            config.set_action_helpstr(config.defaults.actions.files["ctrl-r"], "toggle-root-dir")

            return {
                "default-title",
                fzf_colors = {
                    ["hl"] = { "fg", "FzfColorsHl" },
                    ["hl+"] = { "fg", "FzfColorsHl" },
                    ["gutter"] = "-1",
                },
                fzf_opts = {
                    ["--no-info"] = "",
                    ["--info"] = "hidden",
                    ["--padding"] = "2%,2%,2%,2%",
                    ["--header"] = " ",
                    ["--no-scrollbar"] = true,
                },
                defaults = {
                    formatter = "path.filename_first",
                    -- formatter = "path.dirname_first",
                    -- git_icons = false,
                },
                ui_select = function(fzf_opts, items)
                    return vim.tbl_deep_extend("force", fzf_opts, {
                        prompt = " ",
                        winopts = {
                            title = " "
                                .. vim.trim((fzf_opts.prompt or "Select"):gsub("%s*:%s*$", ""))
                                .. " ",
                            title_pos = "center",
                        },
                    }, fzf_opts.kind == "codeaction" and {
                        winopts = {
                            layout = "vertical",
                            -- height is number of items minus 15 lines for the preview, with a max of 80% screen height
                            height = math.floor(math.min(vim.o.lines * 0.8 - 16, #items + 3) + 0.5)
                                + 16,
                            width = 0.7,
                            preview = not vim.tbl_isempty(
                                        utils.get_clients { bufnr = 0, name = "vtsls" }
                                    )
                                    and {
                                        layout = "vertical",
                                        vertical = "down:15,border-top",
                                        hidden = "hidden",
                                    }
                                or {
                                    layout = "vertical",
                                    vertical = "down:15,border-top",
                                },
                        },
                    } or {
                        winopts = {
                            width = 0.5,
                            -- height is number of items, with a max of 80% screen height
                            height = math.floor(math.min(vim.o.lines * 0.8, #items + 3) + 0.5),
                        },
                    })
                end,
                winopts = {
                    width = 0.9,
                    height = 0.9,
                    row = 0.5,
                    col = 0.5,
                    preview = {
                        scrollchars = { "┃", "" },
                        -- default = "bat_native",
                    },
                },
                files = {
                    cwd_prompt = false,
                    git_icons = true,
                    no_header = false,
                    actions = {
                        ["ctrl-s"] = actions.file_split,
                        ["ctrl-v"] = actions.file_vsplit,
                        ["ctrl-t"] = require("trouble.sources.fzf").actions.open,
                        ["alt-h"] = { actions.toggle_hidden },
                        ["Ctrl-Space"] = function(_, action_opts)
                            fzf.buffers { query = action_opts.last_query, cwd = action_opts.cwd }
                        end,
                    },
                },
                buffers = {
                    no_header = false,
                    fzf_opts = { ["--delimiter"] = " ", ["--with-nth"] = "-1.." },
                    actions = {
                        ["ctrl-x"] = false,
                        ["ctrl-d"] = { actions.buf_del, actions.resume },
                        ["Ctrl-Space"] = function(_, action_opts)
                            fzf.files { query = action_opts.last_query, cwd = action_opts.cwd }
                        end,
                    },
                },
                grep = {
                    actions = {
                        ["ctrl-s"] = actions.file_split,
                        ["ctrl-v"] = actions.file_vsplit,
                        ["alt-h"] = { actions.toggle_hidden },
                    },
                    rg_glob = true,
                    glob_flag = "--iglob",
                    glob_separator = "%s%-%-",
                },
                lsp = {
                    code_actions = {
                        previewer = vim.fn.executable "delta" == 1 and "codeaction_native" or nil,
                    },
                    symbols = {
                        symbol_hl = function(s)
                            return "TroubleIcon" .. s
                        end,
                        symbol_fmt = function(s)
                            return s:lower() .. "\t"
                        end,
                        child_prefix = false,
                    },
                },
            }
        end,
        init = function()
            require("user.utils").load_keymap "fzf"
        end,
        config = function(_, opts)
            if opts[1] == "default-title" then
                -- use the same prompt for all pickers for profile `default-title` and
                -- profiles that use `default-title` as base profile
                local function fix(t)
                    t.prompt = t.prompt ~= nil and " " or nil
                    for _, v in pairs(t) do
                        if type(v) == "table" then
                            fix(v)
                        end
                    end
                    return t
                end
                opts = vim.tbl_deep_extend(
                    "force",
                    fix(require "fzf-lua.profiles.default-title"),
                    opts
                )
                opts[1] = nil
            end
            require("fzf-lua").register_ui_select(opts.ui_select or nil)
            require("fzf-lua").setup(opts)
        end,
    },

    {
        "ahmedkhalf/project.nvim",
        lazy = false,
        opts = { manual_mode = true },
        config = function()
            require("project_nvim").setup()
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
        "echasnovski/mini.pairs",
        event = "VeryLazy",
        opts = {
            modes = { insert = true, command = true, terminal = false },
            -- skip autopair when next character is one of these
            skip_next = [=[[%w%%%'%[%"%.%`%$]]=],
            -- skip autopair when the cursor is inside these treesitter nodes
            skip_ts = { "string" },
            -- skip autopair when next character is closing pair
            -- and there are more closing pairs than opening pairs
            skip_unbalanced = true,
            -- better deal with markdown code blocks
            markdown = true,
        },
        config = function(_, opts)
            require("mini.pairs").setup(opts)
        end,
    },

    {
        "leath-dub/snipe.nvim",
        init = function()
            require("user.utils").load_keymap "snipe"
        end,
        opts = {
            ui = { position = "center" },
            open_win_override = {
                border = require("user.config").borders,
            },
        },
    },

    {
        "echasnovski/mini.bufremove",
        event = "BufReadPre",
        config = function(_, _)
            require("user.utils").load_keymap "bufremove"
        end,
    },

    {
        "folke/noice.nvim",
        event = "VeryLazy",
        dependencies = { "MunifTanjim/nui.nvim" },
        init = function()
            require("user.utils").load_keymap "noice"
        end,
        opts = {
            presets = {
                bottom_search = true,
                command_palette = false,
                long_message_to_split = true,
                inc_rename = true,
                lsp_doc_border = true,
            },
            cmdline = {
                view = "cmdline",
                format = { cmdline = { pattern = "^:", icon = ":", lang = "vim" } },
            },
            lsp = {
                signature = { enabled = false },
                progress = { enabled = false },
                hover = {
                    enabled = true,
                    opts = {
                        scrollbar = false,
                        size = {
                            max_height = math.floor(vim.o.lines * 0.5),
                            max_width = math.floor(vim.o.columns * 0.4),
                        },
                    },
                },
                override = {
                    ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
                    ["vim.lsp.util.stylize_markdown"] = true,
                },
            },
        },
        config = true,
    },
}

return {}
