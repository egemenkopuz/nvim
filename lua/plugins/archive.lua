local archived = {
    {
        "nvim-telescope/telescope.nvim",
        enabled = false,
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

            if not require("user.config").transparent then
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
}

return {}
