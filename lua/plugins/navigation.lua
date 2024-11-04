return {
    {
        "echasnovski/mini.files",
        version = false,
        lazy = false,
        init = function()
            require("user.utils").load_keymap "files"
        end,
        opts = {
            mappings = {
                show_help = "?",
                go_in_plus = "<cr>",
                go_out_plus = "<tab>",
            },
            options = { permanent_delete = false },
            windows = { preview = true, width_focus = 50, width_preview = 75 },
            content = {
                filter = function(entry)
                    return entry.fs_type ~= "file" or entry.name ~= ".DS_Store"
                end,
                sort = function(entries)
                    local function compare_alphanumerically(e1, e2)
                        -- Put directories first.
                        if e1.is_dir and not e2.is_dir then
                            return true
                        end
                        if not e1.is_dir and e2.is_dir then
                            return false
                        end
                        -- Order numerically based on digits if the text before them is equal.
                        if
                            e1.pre_digits == e2.pre_digits
                            and e1.digits ~= nil
                            and e2.digits ~= nil
                        then
                            return e1.digits < e2.digits
                        end
                        -- Otherwise order alphabetically ignoring case.
                        return e1.lower_name < e2.lower_name
                    end

                    local sorted = vim.tbl_map(function(entry)
                        local pre_digits, digits = entry.name:match "^(%D*)(%d+)"
                        if digits ~= nil then
                            digits = tonumber(digits)
                        end

                        return {
                            fs_type = entry.fs_type,
                            name = entry.name,
                            path = entry.path,
                            lower_name = entry.name:lower(),
                            is_dir = entry.fs_type == "directory",
                            pre_digits = pre_digits,
                            digits = digits,
                        }
                    end, entries)
                    table.sort(sorted, compare_alphanumerically)
                    -- Keep only the necessary fields.
                    return vim.tbl_map(function(x)
                        return { name = x.name, fs_type = x.fs_type, path = x.path }
                    end, sorted)
                end,
            },
        },
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
                    vim.api.nvim_win_call(
                        require("mini.files").get_explorer_state().target_window,
                        function()
                            vim.cmd("belowright " .. direction .. " split")
                            new_target_window = vim.api.nvim_get_current_win()
                        end
                    )
                    require("mini.files").set_target_window(new_target_window)
                    require("mini.files").go_in {}
                    if should_close then
                        require("mini.files").close()
                    end
                end
                local desc = "Split " .. direction
                vim.keymap.set("n", lhs, rhs, { buffer = buf_id, desc = desc })
            end

            local map_from_window_picker = function(buf_id, lhs, should_close)
                local should_close = should_close or false
                local rhs = function()
                    local new_target_window = require("window-picker").pick_window()
                    if
                        not new_target_window or not vim.api.nvim_win_is_valid(new_target_window)
                    then
                        return
                    end
                    require("mini.files").set_target_window(new_target_window)
                    require("mini.files").go_in {}
                    if should_close then
                        require("mini.files").close()
                    end
                end
                local desc = "Pick window"
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
                local function on_exit(content)
                    if content.code == 0 then
                        callback(content.stdout)
                        vim.g.content = content.stdout
                    end
                end
                vim.system(
                    { "git", "status", "--ignored", "--porcelain" },
                    { text = true, cwd = cwd },
                    on_exit
                )
            end

            local escape_pattern = function(str)
                return str:gsub("([%^%$%(%)%%%.%[%]%*%+%-%?])", "%%%1")
            end

            local update_mini_with_git = function(buf_id, git_status_map)
                vim.schedule(function()
                    local nlines = vim.api.nvim_buf_line_count(buf_id)
                    local cwd = vim.fs.root(buf_id, ".git")
                    local escapedcwd = escape_pattern(cwd)
                    if vim.fn.has "win32" == 1 then
                        escapedcwd = escapedcwd:gsub("\\", "/")
                    end

                    for i = 1, nlines do
                        local entry = MiniFiles.get_fs_entry(buf_id, i)
                        if not entry then
                            break
                        end
                        local relativePath = entry.path:gsub("^" .. escapedcwd .. "/", "")
                        local status = git_status_map[relativePath]

                        if status then
                            local symbol, hlGroup = map_symbols(status)
                            vim.api.nvim_buf_set_extmark(buf_id, ns_minifiles, i - 1, 0, {
                                -- NOTE: if you want the signs on the right uncomment those and comment
                                -- the 3 lines after
                                -- virt_text = { { symbol, hlGroup } },
                                -- virt_text_pos = "right_align",
                                sign_text = symbol,
                                sign_hl_group = hlGroup,
                                priority = 2,
                            })
                        else
                        end
                    end
                end)
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
                if not vim.fs.root(vim.uv.cwd(), ".git") then
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
                        git_status_cache[cwd] = {
                            time = currentTime,
                            statusMap = gitStatusMap,
                        }
                        update_mini_with_git(buf_id, gitStatusMap)
                    end)
                end
            end

            local clear_cache = function()
                git_status_cache = {}
            end

            local files_grug_far_replace = function(path)
                local cur_entry_path = MiniFiles.get_fs_entry().path
                local prefills = { filesFilter = "*", paths = vim.fs.dirname(cur_entry_path) }
                local grug_far = require "grug-far"
                if not grug_far.has_instance "explorer" then
                    grug_far.open {
                        instanceName = "explorer",
                        prefills = prefills,
                        staticTitle = "Find and Replace from Explorer",
                    }
                else
                    grug_far.open_instance "explorer"
                    grug_far.update_instance_prefills("explorer", prefills, false)
                end
            end

            vim.api.nvim_create_autocmd("User", {
                pattern = "MiniFilesExplorerOpen",
                callback = function()
                    local bufnr = vim.api.nvim_get_current_buf()
                    update_git_status(bufnr)
                end,
            })
            vim.api.nvim_create_autocmd("User", {
                pattern = "MiniFilesWindowOpen",
                callback = function(args)
                    vim.api.nvim_win_set_config(args.data.win_id, { border = "rounded" })
                end,
            })
            vim.api.nvim_create_autocmd("User", {
                pattern = "MiniFilesExplorerClose",
                callback = function()
                    clear_cache()
                end,
            })
            vim.api.nvim_create_autocmd("User", {
                pattern = "MiniFilesActionRename",
                callback = function(args)
                    if not args.data.from or not args.data.to then
                        return
                    end
                    local changes = {
                        files = {
                            {
                                oldUri = vim.uri_from_fname(args.data.from),
                                newUri = vim.uri_from_fname(args.data.to),
                            },
                        },
                    }
                    local clients = vim.lsp.get_clients()
                    for _, client in ipairs(clients) do
                        if client.supports_method "workspace/willRenameFiles" then
                            local resp =
                                client.request_sync("workspace/willRenameFiles", changes, 10000, 0)
                            if resp and resp.result ~= nil then
                                vim.lsp.util.apply_workspace_edit(
                                    resp.result,
                                    client.offset_encoding
                                )
                            end
                        end
                    end

                    for _, client in ipairs(clients) do
                        if client.supports_method "workspace/didRenameFiles" then
                            client.notify("workspace/didRenameFiles", changes)
                        end
                    end
                end,
            })
            vim.api.nvim_create_autocmd("User", {
                pattern = "MiniFilesBufferUpdate",
                callback = function(args)
                    local bufnr = args.data.buf_id
                    local cwd = vim.fn.expand "%:p:h"
                    if git_status_cache[cwd] then
                        update_mini_with_git(bufnr, git_status_cache[cwd].statusMap)
                    end
                end,
            })
            vim.api.nvim_create_autocmd("User", {
                pattern = "MiniFilesWindowUpdate",
                callback = function(args)
                    local config = vim.api.nvim_win_get_config(args.data.win_id)
                    config.height = math.max(15, config.height)
                    if config.title[#config.title][1] ~= " " then
                        table.insert(config.title, { " ", "NormalFloat" })
                    end
                    if config.title[1][1] ~= " " then
                        table.insert(config.title, 1, { " ", "NormalFloat" })
                    end
                    vim.api.nvim_win_set_config(args.data.win_id, config)
                end,
            })
            vim.api.nvim_create_autocmd("User", {
                pattern = "MiniFilesBufferCreate",
                callback = function(args)
                    -- stylua: ignore start
                    local buf_id = args.data.buf_id
                    vim.keymap.set("n", "g.", toggle_dotfiles, { buffer = buf_id })
                    vim.keymap.set("n", "gs", files_grug_far_replace, { buffer = args.data.buf_id, desc = "Search in directory" })
                    map_split(buf_id, "gx", "belowright horizontal")
                    map_split(buf_id, "gv", "belowright vertical")
                    map_split(buf_id, "gX", "belowright horizontal", true)
                    map_split(buf_id, "gV", "belowright vertical", true)
                    map_from_window_picker(buf_id, "gw")
                    map_from_window_picker(buf_id, "gW", true)
                    -- stylua: ignore end
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
        "s1n7ax/nvim-window-picker",
        event = "BufReadPost",
        version = "2.*",
        config = function()
            require("window-picker").setup {
                hint = "floating-big-letter",
                autoselect_one = false,
                include_current = false,
                floating_big_letter = { font = "ansi-shadow" },
                filter_func = function(windows, rules)
                    local function predicate(wid)
                        local cfg = vim.api.nvim_win_get_config(wid)
                        if not cfg.focusable then
                            return false
                        end
                        return true
                    end
                    local filtered = vim.tbl_filter(predicate, windows)
                    local dfilter = require("window-picker.filters.default-window-filter"):new()
                    dfilter:set_config(rules)
                    return dfilter:filter_windows(filtered)
                end,
                filter_rules = {
                    bo = {
                        filetype = {
                            "neo-tree",
                            "neo-tree-popup",
                            "notify",
                            "no-neck-pain",
                            "Outline",
                            "undotree",
                            "diff",
                            "Glance",
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
            buffer = { suffix = "", options = {} },
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
            undo = { suffix = "", options = {} },
            window = { suffix = "w", options = {} },
            yank = { suffix = "", options = {} },
        },
        config = function(_, opts)
            require("mini.bracketed").setup(opts)
        end,
    },
}
