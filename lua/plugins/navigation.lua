return {
    {
        "echasnovski/mini.files",
        version = false,
        lazy = false,
        init = function()
            require("user.utils").load_keymap "files"
        end,
        opts = {
            windows = {
                preview = true,
                width_focus = 30,
                width_preview = 50,
            },
        },
        config = function(_, opts)
            require("mini.files").setup(opts)

            -- show/hide dot-files
            local show_dotfiles = true
            local filter_show = function(_)
                return true
            end
            local filter_hide = function(fs_entry)
                return not vim.startswith(fs_entry.name, ".")
            end
            local toggle_dotfiles = function()
                show_dotfiles = not show_dotfiles
                local new_filter = show_dotfiles and filter_show or filter_hide
                require("mini.files").refresh { content = { filter = new_filter } }
            end

            vim.api.nvim_create_autocmd("User", {
                pattern = "MiniFilesBufferCreate",
                callback = function(args)
                    local buf_id = args.data.buf_id
                    -- Tweak left-hand side of mapping to your liking
                    vim.keymap.set("n", "g.", toggle_dotfiles, { buffer = buf_id })
                end,
            })

            vim.api.nvim_create_autocmd("User", {
                pattern = "MiniFilesActionRename",
                callback = function(event)
                    require("lazyvim.util").lsp.on_rename(event.data.from, event.data.to)
                end,
            })

            -- target window via split
            local map_split = function(buf_id, lhs, direction)
                local rhs = function()
                    -- Make new window and set it as target
                    local new_target_window
                    vim.api.nvim_win_call(require("mini.files").get_target_window(), function()
                        vim.cmd(direction .. " split")
                        new_target_window = vim.api.nvim_get_current_win()
                    end)

                    require("mini.files").set_target_window(new_target_window)
                end

                local desc = "Split " .. direction
                vim.keymap.set("n", lhs, rhs, { buffer = buf_id, desc = desc })
            end

            vim.api.nvim_create_autocmd("User", {
                pattern = "MiniFilesBufferCreate",
                callback = function(args)
                    local buf_id = args.data.buf_id
                    map_split(buf_id, "gx", "belowright horizontal")
                    map_split(buf_id, "gv", "belowright vertical")
                end,
            })
        end,
    },

    {
        "nvim-telescope/telescope.nvim",
        dependencies = {
            "nvim-lua/plenary.nvim",
            { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
            "nvim-telescope/telescope-file-browser.nvim",
            "nvim-telescope/telescope-ui-select.nvim",
            "olimorris/persisted.nvim",
            "ahmedkhalf/project.nvim",
            "folke/noice.nvim",
        },
        cmd = "Telescope",
        version = false,
        init = function()
            require("project_nvim").setup()
            require("user.utils").load_keymap "telescope"
        end,
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
                file_browser = { hijack_netrw = false, hidden = true, use_fd = true },
            },
        },
        config = function(_, opts)
            local telescope = require "telescope"

            opts.extensions["ui-select"] = {
                require("telescope.themes").get_dropdown {
                    layout_strategy = "cursor",
                    winblend = 15,
                    layout_config = { prompt_position = "top", width = 80, height = 12 },
                },
            }

            telescope.setup(opts)

            telescope.load_extension "fzf"
            telescope.load_extension "file_browser"
            telescope.load_extension "ui-select"
            telescope.load_extension "projects"
            telescope.load_extension "persisted"
            telescope.load_extension "noice"

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
                TelescopePromptBorder = { fg = tc1 },
                TelescopeResultsNormal = { bg = tc3 },
                TelescopeResultsBorder = { fg = tc1 },
                TelescopePreviewTitle = { fg = tc3, bg = tc2, bold = true },
                TelescopePreviewNormal = { bg = tc3 },
                TelescopePreviewBorder = { fg = tc1 },
            }

            for k, v in pairs(hl_group) do
                vim.api.nvim_set_hl(0, k, v)
            end
        end,
    },

    {
        "s1n7ax/nvim-window-picker",
        event = "BufReadPost",
        version = "v1.*",
        config = function()
            require("window-picker").setup {
                autoselect_one = true,
                include_current = false,
                other_win_hl_color = "#7E9CD8",
                filter_rules = {
                    bo = {
                        filetype = {
                            "neo-tree",
                            "neo-tree-popup",
                            "notify",
                            "no-neck-pain",
                            "Outline",
                        },
                        buftype = { "terminal", "quickfix" },
                    },
                },
            }
            require("user.utils").load_keymap "window_picker"
        end,
    },

    {
        "numToStr/Navigator.nvim",
        lazy = false,
        init = function()
            require("user.utils").load_keymap "navigator"
        end,
        config = function(_, opts)
            require("Navigator").setup(opts)
        end,
    },

    -- change with smoka7/hop.nvim
    -- {
    --     "egemenkopuz/hop.nvim",
    --     event = "BufReadPre",
    --     branch = "fix-some-bugs",
    --     opts = { keys = "etovxqpdygfblzhckisuran" },
    --     config = function(_, opts)
    --         require("hop").setup(opts)
    --         require("user.utils").load_keymap "hop"
    --     end,
    -- },

    -- {
    --     "ggandor/leap.nvim",
    --     event = "BufReadPre",
    --     dependencies = { { "ggandor/flit.nvim", opts = { labeled_modes = "nv" } } },
    --     config = function(_, opts)
    --         local leap = require "leap"
    --         for k, v in pairs(opts) do
    --             leap.opts[k] = v
    --         end
    --         leap.add_default_mappings(true)
    --         vim.keymap.del({ "x", "o" }, "x")
    --         vim.keymap.del({ "x", "o" }, "X")
    --     end,
    -- },

    {
        "echasnovski/mini.bracketed",
        event = "BufReadPre",
        version = false,
        opts = {
            buffer = { suffix = "b", options = {} },
            comment = { suffix = "c", options = {} },
            conflict = { suffix = "x", options = {} },
            diagnostic = { suffix = "d", options = {} },
            file = { suffix = "f", options = {} },
            indent = { suffix = "i", options = {} },
            jump = { suffix = "j", options = {} },
            location = { suffix = "l", options = {} },
            oldfile = { suffix = "o", options = {} },
            quickfix = { suffix = "q", options = {} },
            treesitter = { suffix = "t", options = {} },
            undo = { suffix = "u", options = {} },
            window = { suffix = "w", options = {} },
            yank = { suffix = "y", options = {} },
        },
        config = function(_, opts)
            require("mini.bracketed").setup(opts)
        end,
    },
    {
        "backdround/global-note.nvim",
        cmd = { "GlobalNote", "ProjectPrivateNote", "ProjectTodo", "ProjectNote" },
        keys = {
            { "<leader>ng", "<CMD>GlobalNote<CR>", desc = "Global notes" },
            { "<leader>np", "<CMD>ProjectPrivateNote<CR>", desc = "Private note" },
            { "<leader>nn", "<CMD>ProjectNote<CR>", desc = "Local note" },
            { "<leader>nt", "<CMD>ProjectTodo<CR>", desc = "Local todos" },
        },
        config = function(_, opts)
            local wk = require "which-key"
            wk.register({
                n = { name = "notes" },
            }, { prefix = "<leader>" })
            require("global-note").setup(opts)
        end,
        opts = function()
            local get_project_name = function()
                local result = vim.system({
                    "git",
                    "rev-parse",
                    "--show-toplevel",
                }, {
                    text = true,
                }):wait()

                if result.stderr ~= "" then
                    vim.notify(result.stderr, vim.log.levels.WARN)
                    return nil
                end

                local project_directory = result.stdout:gsub("\n", "")

                local project_name = vim.fs.basename(project_directory)
                if project_name == nil then
                    vim.notify("Unable to get the project name", vim.log.levels.WARN)
                    return nil
                end

                return project_name
            end

            local global_dir = vim.fn.expand "$HOME" .. "/.notes"

            return {
                autosave = false,
                directory = global_dir,

                filename = "global.md",

                additional_presets = {
                    project_private = {
                        directory = function()
                            return vim.fs.joinpath(global_dir, get_project_name())
                        end,
                        filename = "note.md",
                        title = "Private Project Note",
                        command_name = "ProjectPrivateNote",
                    },
                    project_local = {
                        directory = function()
                            return vim.fn.getcwd()
                        end,
                        filename = "note.md",
                        title = "Project Note",
                        command_name = "ProjectNote",
                    },
                    project_todo = {

                        directory = function()
                            return vim.fn.getcwd()
                        end,
                        filename = "todo.md",
                        title = "Project Todo",
                        command_name = "ProjectTodo",
                    },
                },
            }
        end,
    },
}
