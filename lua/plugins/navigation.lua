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

            local map_symbols = function(status, is_symlink)
                local status_map = {
                    -- stylua: ignore start 
                    [" M"] = { icon = "•", hl_group  = "GitSignsChange"}, -- Modified in the working directory
                    ["M "] = { icon = "✹", hl_group  = "GitSignsChange"}, -- modified in index
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
                    ["??"] = { icon = "?", hl_group  = "GitSignsDelete"}, -- Untracked files
                    ["!!"] = { icon = "!", hl_group  = "GitSignsChange"}, -- Ignored files
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

            local function check_symlink(path)
                local stat = vim.loop.fs_lstat(path)
                return stat and stat.type == "link"
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
                            local is_symlink = check_symlink(entry.path)
                            local symbol, hl_group = map_symbols(status, is_symlink)
                            vim.api.nvim_buf_set_extmark(buf_id, ns_minifiles, i - 1, 0, {
                                -- NOTE: if you want the signs on the right uncomment those and comment
                                -- the 3 lines after
                                -- virt_text = { { symbol, hl_group } },
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
                local cwd = vim.fs.root(buf_id, ".git")
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
        "ibhagwan/fzf-lua",
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
}
