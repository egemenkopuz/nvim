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
}

return {}
