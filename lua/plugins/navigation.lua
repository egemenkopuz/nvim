return {
    {
        "echasnovski/mini.files",
        version = false,
        lazy = false,
        init = function()
            require("user.utils").load_keymap "files"
        end,
        opts = { windows = { preview = true, width_focus = 30, width_preview = 50 } },
        config = function(_, opts)
            local minifiles = require "mini.files"
            minifiles.setup(opts)

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

            local map_split = function(buf_id, lhs, direction, should_close)
                local should_close = should_close or false
                local rhs = function()
                    local new_target_window
                    vim.api.nvim_win_call(require("mini.files").get_target_window(), function()
                        vim.cmd(direction .. " split")
                        new_target_window = vim.api.nvim_get_current_win()
                    end)
                    require("mini.files").set_target_window(new_target_window)
                    if should_close then
                        require("mini.files").close()
                    end
                end
                local desc = "Split " .. direction
                vim.keymap.set("n", lhs, rhs, { buffer = buf_id, desc = desc })
            end

            local ns_minifiles = vim.api.nvim_create_namespace "mini_files_git"
            local git_status_cache = {}
            local cache_timeout = 2000 -- Cache timeout in milliseconds

            local map_symbols = function(status)
                local status_map = {
                    -- stylua: ignore start 
                    [" M"] = { symbol = "•", hlGroup  = "MiniDiffSignChange"}, -- Modified in the working directory
                    ["M "] = { symbol = "✹", hlGroup  = "MiniDiffSignChange"}, -- modified in index
                    ["MM"] = { symbol = "≠", hlGroup  = "MiniDiffSignChange"}, -- modified in both working tree and index
                    ["A "] = { symbol = "+", hlGroup  = "MiniDiffSignAdd"   }, -- Added to the staging area, new file
                    ["AA"] = { symbol = "≈", hlGroup  = "MiniDiffSignAdd"   }, -- file is added in both working tree and index
                    ["D "] = { symbol = "-", hlGroup  = "MiniDiffSignDelete"}, -- Deleted from the staging area
                    ["AM"] = { symbol = "⊕", hlGroup  = "MiniDiffSignChange"}, -- added in working tree, modified in index
                    ["AD"] = { symbol = "-•", hlGroup = "MiniDiffSignChange"}, -- Added in the index and deleted in the working directory
                    ["R "] = { symbol = "→", hlGroup  = "MiniDiffSignChange"}, -- Renamed in the index
                    ["U "] = { symbol = "‖", hlGroup  = "MiniDiffSignChange"}, -- Unmerged path
                    ["UU"] = { symbol = "⇄", hlGroup  = "MiniDiffSignAdd"   }, -- file is unmerged
                    ["UA"] = { symbol = "⊕", hlGroup  = "MiniDiffSignAdd"   }, -- file is unmerged and added in working tree
                    ["??"] = { symbol = "?", hlGroup  = "MiniDiffSignDelete"}, -- Untracked files
                    ["!!"] = { symbol = "!", hlGroup  = "MiniDiffSignChange"}, -- Ignored files
                    -- stylua: ignore end
                }
                local result = status_map[status] or { symbol = "?", hlGroup = "NonText" }
                return result.symbol, result.hlGroup
            end

            local fetch_git_status = function(cwd, callback)
                local stdout = (vim.uv or vim.loop).new_pipe(false)
                local handle, pid = (vim.uv or vim.loop).spawn(
                    "git",
                    {
                        args = { "status", "--ignored", "--porcelain" },
                        cwd = cwd,
                        stdio = { nil, stdout, nil },
                    },
                    vim.schedule_wrap(function(code, signal)
                        if code == 0 then
                            stdout:read_start(function(err, content)
                                if content then
                                    callback(content)
                                    vim.g.content = content
                                end
                                stdout:close()
                            end)
                        else
                            vim.notify(
                                "Git command failed with exit code: " .. code,
                                vim.log.levels.ERROR
                            )
                            stdout:close()
                        end
                    end)
                )
            end

            local escape_pattern = function(str)
                return str:gsub("([%^%$%(%)%%%.%[%]%*%+%-%?])", "%%%1")
            end

            local update_mini_with_git = function(buf_id, git_status_map)
                vim.schedule(function()
                    local n_lines = vim.api.nvim_buf_line_count(buf_id)
                    local cwd = vim.fn.getcwd() --  vim.fn.expand("%:p:h")
                    local escapedcwd = escape_pattern(cwd)
                    if vim.fn.has "win32" == 1 then
                        escapedcwd = escapedcwd:gsub("\\", "/")
                    end

                    for i = 1, n_lines do
                        local entry = MiniFiles.get_fs_entry(buf_id, i)
                        if not entry then
                            break
                        end
                        local relative_path = entry.path:gsub("^" .. escapedcwd .. "/", "")
                        local status = git_status_map[relative_path]

                        if status then
                            local symbol, hl_group = map_symbols(status)
                            vim.api.nvim_buf_set_extmark(buf_id, ns_minifiles, i - 1, 0, {
                                -- virt_text = { { symbol, hl_group} },
                                -- virt_text_pos = "right_align",
                                sign_text = symbol,
                                sign_hl_group = hl_group,
                                priority = 2,
                            })
                        else
                        end
                    end
                end)
            end

            local is_valid_git_repo = function()
                if vim.fn.isdirectory ".git" == 0 then
                    return false
                end
                return true
            end

            local parse_git_status = function(content)
                local git_status_map = {}
                -- lua match is faster than vim.split (in my experience )
                for line in content:gmatch "[^\r\n]+" do
                    local status, file_path = string.match(line, "^(..)%s+(.*)")
                    -- Split the file path into parts
                    local parts = {}
                    for part in file_path:gmatch "[^/]+" do
                        table.insert(parts, part)
                    end
                    -- Start with the root directory
                    local current_key = ""
                    for i, part in ipairs(parts) do
                        if i > 1 then
                            -- Concatenate parts with a separator to create a unique key
                            current_key = current_key .. "/" .. part
                        else
                            current_key = part
                        end
                        -- If it's the last part, it's a file, so add it with its status
                        if i == #parts then
                            git_status_map[current_key] = status
                        else
                            -- If it's not the last part, it's a directory. Check if it exists, if not, add it.
                            if not git_status_map[current_key] then
                                git_status_map[current_key] = status
                            end
                        end
                    end
                end
                return git_status_map
            end

            local update_git_status = function(buf_id)
                if not is_valid_git_repo() then
                    return
                end
                local cwd = vim.fn.expand "%:p:h"
                local currentTime = os.time()
                if
                    git_status_cache[cwd]
                    and currentTime - git_status_cache[cwd].time < cache_timeout
                then
                    update_mini_with_git(buf_id, git_status_cache[cwd].statusMap)
                else
                    fetch_git_status(cwd, function(content)
                        local gitStatusMap = parse_git_status(content)
                        git_status_cache[cwd] = { time = currentTime, statusMap = gitStatusMap }
                        update_mini_with_git(buf_id, gitStatusMap)
                    end)
                end
            end

            local clear_cache = function()
                git_status_cache = {}
            end

            vim.api.nvim_create_autocmd("User", {
                pattern = "MiniFilesExplorerOpen",
                callback = function()
                    local bufnr = vim.api.nvim_get_current_buf()
                    update_git_status(bufnr)
                end,
            })

            vim.api.nvim_create_autocmd("User", {
                pattern = "MiniFilesExplorerClose",
                callback = function()
                    clear_cache()
                end,
            })
            vim.api.nvim_create_autocmd("User", {
                pattern = "MiniFilesBufferCreate",
                callback = function(args)
                    local buf_id = args.data.buf_id
                    vim.keymap.set("n", "g.", toggle_dotfiles, { buffer = buf_id })
                    map_split(buf_id, "gx", "belowright horizontal")
                    map_split(buf_id, "gv", "belowright vertical")
                    map_split(buf_id, "gX", "belowright horizontal", true)
                    map_split(buf_id, "gV", "belowright vertical", true)
                    local cwd = vim.fn.expand "%:p:h"
                    if git_status_cache[cwd] then
                        update_mini_with_git(buf_id, git_status_cache[cwd].statusMap)
                    end
                end,
            })
        end,
    },

    {
        "nvim-telescope/telescope.nvim",
        dependencies = {
            "nvim-lua/plenary.nvim",
            {
                "nvim-telescope/telescope-fzf-native.nvim",
                build = vim.fn.executable "make" == 1 and "make"
                    or "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build",
            },
            "nvim-telescope/telescope-file-browser.nvim",
            "nvim-telescope/telescope-ui-select.nvim",
            "olimorris/persisted.nvim",
            "ahmedkhalf/project.nvim",
            "folke/noice.nvim",
        },
        cmd = "Telescope",
        version = false,
        init = function()
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
                    -- winblend = 15,
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
            else
                for _, k in ipairs { "TelescopeBorder" } do
                    vim.api.nvim_set_hl(0, k, { fg = "gray", bg = "none" })
                end
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

    {
        "folke/flash.nvim",
        event = "VeryLazy",
        opts = {},
        init = function()
            require("user.utils").load_keymap "flash"
        end,
    },

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
