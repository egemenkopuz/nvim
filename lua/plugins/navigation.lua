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
            local uv = vim.uv or vim.loop
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

            local map_symbols = function(status, is_symlink)
                local status_map = {
                    -- stylua: ignore start 
                    [" M"] = { icon = "○", hl_group  = "GitSignsChange"}, -- Modified in the working directory
                    ["M "] = { icon = "●", hl_group  = "GitSignsChange"}, -- modified in index
                    ["MM"] = { icon = "≠", hl_group  = "GitSignsChange"}, -- modified in both working tree and index
                    ["A "] = { icon = "+", hl_group  = "GitSignsAdd"   }, -- Added to the staging area, new file
                    ["AA"] = { icon = "≈", hl_group  = "GitSignsAdd"   }, -- file is added in both working tree and index
                    ["D "] = { icon = "-", hl_group  = "GitSignsDelete"}, -- Deleted from the staging area
                    ["AM"] = { icon = "⊕", hl_group  = "GitSignsChange"}, -- added in working tree, modified in index
                    ["AD"] = { icon = "-•", hl_group = "GitSignsChange"}, -- Added in the index and deleted in the working directory
                    ["R "] = { icon = "→", hl_group  = "GitSignsChange"}, -- Renamed in the index
                    ["U "] = { icon = "‖", hl_group  = "GitSignsChange"}, -- Unmerged path
                    ["UU"] = { icon = "⇄", hl_group  = "GitSignsAdd"   }, -- file is unmerged
                    ["UA"] = { icon = "⊕", hl_group  = "GitSignsAdd"   }, -- file is unmerged and added in working tree
                    ["??"] = { icon = "?", hl_group  = "MiniFilesUntracked"}, -- Untracked files
                    ["!!"] = { icon = "!", hl_group  = "MiniFilesIgnored"}, -- Ignored files
                    -- stylua: ignore end
                }
                local result = status_map[status] or { icon = "?", hl_group = "NonText" }
                local symlink_icon = is_symlink and "↩" or ""
                local combined_icon = (symlink_icon .. result.icon)
                    :gsub("^%s+", "")
                    :gsub("%s+$", "")
                local combined_hl_group = is_symlink and "GitSignsDelete" or result.hl_group
                return combined_icon, combined_hl_group
            end

            local fetch_git_status = function(cwd, callback)
                local clean_cwd = cwd:gsub("^minifiles://%d+/", "")
                local function on_exit(content)
                    if content.code == 0 then
                        callback(content.stdout)
                        -- vim.g.content = content.stdout
                    end
                end
                vim.system(
                    { "git", "status", "--ignored", "--porcelain" },
                    { text = true, cwd = clean_cwd },
                    on_exit
                )
            end

            local function check_symlink(path)
                local stat = uv.fs_lstat(path)
                return stat and stat.type == "link"
            end

            local update_mini_with_git = function(buf_id, git_status_map)
                vim.schedule(function()
                    local nlines = vim.api.nvim_buf_line_count(buf_id)
                    local cwd = vim.fs.root(buf_id, ".git")
                    local escapedcwd = cwd and vim.pesc(cwd)

                    for i = 1, nlines do
                        local entry = MiniFiles.get_fs_entry(buf_id, i)
                        if not entry then
                            break
                        end
                        local relativePath = entry.path:gsub("^" .. escapedcwd .. "/", "")
                        local status = git_status_map[relativePath]

                        if status then
                            local symbol, hl_group = map_symbols(status, check_symlink(entry.path))
                            vim.api.nvim_buf_set_extmark(buf_id, ns_minifiles, i - 1, 0, {
                                sign_text = symbol,
                                sign_hl_group = hl_group,
                                priority = 2,
                            })
                            local line = vim.api.nvim_buf_get_lines(buf_id, i - 1, i, false)[1]
                            -- Find the name position accounting for potential icons
                            local nameStartCol = line:find(vim.pesc(entry.name)) or 0
                            if nameStartCol > 0 then
                                vim.api.nvim_buf_add_highlight(
                                    buf_id,
                                    ns_minifiles,
                                    hl_group,
                                    i - 1,
                                    nameStartCol - 1,
                                    nameStartCol + #entry.name - 1
                                )
                            end
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
                if not vim.fs.root(buf_id, ".git") then
                    return
                end
                local cwd = vim.fs.root(buf_id, ".git")
                local current_time = os.time()
                if
                    git_status_cache[cwd]
                    and current_time - git_status_cache[cwd].time < cache_timeout
                then
                    update_mini_with_git(buf_id, git_status_cache[cwd].statusMap)
                else
                    fetch_git_status(cwd, function(content)
                        local git_status_map = parse_git_status(content)
                        git_status_cache[cwd] = {
                            time = current_time,
                            statusMap = git_status_map,
                        }
                        update_mini_with_git(buf_id, git_status_map)
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
                    vim.g.minifiles_active = true
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
                    vim.g.minifiles_active = false
                    clear_cache()
                end,
            })
            vim.api.nvim_create_autocmd("User", {
                pattern = "MiniFilesActionRename",
                callback = function(args)
                    Snacks.rename.on_rename_file(args.data.from, args.data.to)
                end,
            })
            vim.api.nvim_create_autocmd("User", {
                pattern = "MiniFilesBufferUpdate",
                callback = function(args)
                    local bufnr = args.data.buf_id
                    local cwd = vim.fs.root(bufnr, ".git")
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
                    vim.keymap.set("n", "gr", files_grug_far_replace, { buffer = args.data.buf_id, desc = "Search in directory" })
                    map_split(buf_id, "gs", "belowright horizontal")
                    map_split(buf_id, "gv", "belowright vertical")
                    map_split(buf_id, "gS", "belowright horizontal", true)
                    map_split(buf_id, "gV", "belowright vertical", true)
                    map_from_window_picker(buf_id, "gw")
                    map_from_window_picker(buf_id, "gW", true)
                    -- stylua: ignore end
                end,
            })
        end,
    },

    {
        "s1n7ax/nvim-window-picker",
        event = "BufReadPost",
        version = "2.*",
        config = function()
            require("window-picker").setup {
                hint = "floating-letter",
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
                            "smear-cursor",
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

    {
        "leath-dub/snipe.nvim",
        -- init = function()
        --     require("user.utils").load_keymap "snipe"
        -- end,
        opts = {
            ui = { position = "center" },
            open_win_override = {
                border = require("user.config").borders,
            },
        },
    },
}
