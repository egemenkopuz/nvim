local M = {}

local merge_tb = vim.tbl_deep_extend
local general_opts = { noremap = true, silent = true }
local diag_def_virtual_text = require("user.config").diagnostics.virtual_text

for key, value in pairs(require("user.config").toggle_settings) do
    vim.g[key] = value
end

-- util init
if vim.api.nvim_get_option_value("colorcolumn", {}) == "" then
    vim.g["colorcolumn"] = false
else
    vim.g["colorcolumn"] = true
end

function M.toggle(var_name, override)
    override = override or nil
    if override then
        vim.g[var_name] = override
    else
        vim.g[var_name] = not vim.g[var_name]
    end
end

function M.is_enabled(var_name)
    return vim.g[var_name]
end

function M.notify(message, level, title)
    level = level or vim.log.levels.INFO
    local notify_options = { title = title, timeout = 2000 }
    vim.api.nvim_notify(message, level, notify_options)
end

function M.load_keymap(section_name, add_opts)
    local present, keys = pcall(require, "user.keymaps")
    if not present or keys[section_name] == nil then
        M.notify("Keymaps for " .. section_name .. " not found", vim.log.levels.ERROR)
        return
    end
    for mode, mapping in pairs(keys[section_name]) do
        for lhs, rhs in pairs(mapping) do
            local opts = merge_tb("force", general_opts, rhs.opts or {})
            rhs.opts = nil
            if rhs[2] ~= nil then
                opts = merge_tb("force", opts, { desc = rhs[2] })
            end
            opts = merge_tb("force", opts, add_opts or {})
            vim.keymap.set(mode, lhs, rhs[1], opts)
        end
    end
end

function M.load_highlights(section_name, add_opts)
    local present, keys = pcall(require, "user.highlights")
    if not present or keys[section_name] == nil then
        M.notify("Highlights for " .. section_name .. " not found", vim.log.levels.ERROR)
        return
    end
    for hl_id, hl_opts in pairs(keys[section_name]) do
        hl_opts = merge_tb("force", hl_opts, add_opts or {})
        vim.api.nvim_set_hl(0, hl_id, hl_opts)
    end
end

function M.toggle_diagnostics()
    M.toggle "diagnostics"
    if M.is_enabled "diagnostics" then
        vim.diagnostic.show()
        require("tiny-inline-diagnostic").enable()
        M.notify "Diagnostics enabled"
    else
        vim.diagnostic.hide()
        require("tiny-inline-diagnostic").disable()
        M.notify "Diagnostics disabled"
    end
end

function M.toggle_diagnostic_virtual_lines()
    if not M.is_enabled "diagnostics" then
        return
    end
    local def_diagnostics = require("user.config").diagnostics
    M.toggle "diagnostic_lines"
    if M.is_enabled "diagnostic_lines" then
        def_diagnostics.virtual_lines = true
        def_diagnostics.virtual_text = false
        require("tiny-inline-diagnostic").disable()
        M.notify "Diagnostics lines enabled"
    else
        def_diagnostics.virtual_lines = false
        def_diagnostics.virtual_text = diag_def_virtual_text
        require("tiny-inline-diagnostic").enable()
        M.notify "Diagnostics lines disabled"
    end
    vim.diagnostic.config(def_diagnostics)
end

function M.toggle_autoformat()
    M.toggle "autoformat"
    if M.is_enabled "autoformat" then
        M.notify "Autoformat enabled"
    else
        M.notify "Autoformat disabled"
    end
end

function M.toggle_colorcolumn(col_num)
    col_num = col_num or "79"
    M.toggle "colorcolumn"
    if M.is_enabled "colorcolumn" then
        vim.api.nvim_set_option_value("colorcolumn", col_num, {})
        M.notify "Colorcolumn enabled"
    else
        vim.api.nvim_set_option_value("colorcolumn", "", {})
        M.notify "Colorcolumn disabled"
    end
end

function M.get_python_path(workspace)
    local path = require("lspconfig/util").path
    -- Use activated virtualenv.
    if vim.env.VIRTUAL_ENV then
        return path.join(vim.env.VIRTUAL_ENV, "bin", "python")
    end
    -- Find and use virtualenv in workspace directory.
    for _, pattern in ipairs { "*", ".*" } do
        local match = vim.fn.glob(path.join(workspace, pattern, "pyvenv.cfg"))
        if match ~= "" then
            return path.join(path.dirname(match), "bin", "python")
        end
    end
    -- Fallback to system Python.
    return vim.fn.exepath "python3" or vim.fn.exepath "python" or "python"
end

function M.env_cleanup(venv)
    if string.find(venv, "/") then
        local final_venv = venv
        for w in venv:gmatch "([^/]+)" do
            final_venv = w
        end
        venv = final_venv
    end
    return venv
end

function M.path_exists(path)
    local ok = vim.loop.fs_stat(path)
    return ok
end

function M.colorscheme_selection(colorscheme)
    if require("user.config").colorscheme == colorscheme then
        return true
    else
        return false
    end
end

M.root_patterns = { ".git", ".clang-format", "pyproject.toml", "setup.py" }

function M.get_clients(opts)
    local ret = {}
    if vim.lsp.get_clients then
        ret = vim.lsp.get_clients(opts)
    else
        ---@diagnostic disable-next-line: deprecated
        ret = vim.lsp.get_active_clients(opts)
        if opts and opts.method then
            ret = vim.tbl_filter(function(client)
                return client.supports_method(opts.method, { bufnr = opts.bufnr })
            end, ret)
        end
    end
    return opts and opts.filter and vim.tbl_filter(opts.filter, ret) or ret
end

-- return the root directory based on:
-- * lsp workspace folders
-- * lsp root_dir
-- * root pattern of filename of the current buffer
-- * root pattern of cwd
function M.get_root()
    local path = vim.api.nvim_buf_get_name(0)
    path = path ~= "" and vim.loop.fs_realpath(path) or nil
    local roots = {}
    if path then
        for _, client in pairs(M.get_clients { bufnr = 0 }) do
            local workspace = client.config.workspace_folders
            local paths = workspace
                    and vim.tbl_map(function(ws)
                        return vim.uri_to_fname(ws.uri)
                    end, workspace)
                or client.config.root_dir and { client.config.root_dir }
                or {}
            for _, p in ipairs(paths) do
                local r = vim.loop.fs_realpath(p)
                if path:find(r, 1, true) then
                    roots[#roots + 1] = r
                end
            end
        end
    end
    table.sort(roots, function(a, b)
        return #a > #b
    end)
    local root = roots[1]
    if not root then
        path = path and vim.fs.dirname(path) or vim.loop.cwd()
        root = vim.fs.find(M.root_patterns, { path = path, upward = true })[1]
        root = root and vim.fs.dirname(root) or vim.loop.cwd()
    end
    return root
end

-- return a function that calls telescope.
-- for `files`, git_files or find_files will be chosen depending on .git
function M.telescope(builtin, opts)
    local params = { builtin = builtin, opts = opts }
    return function()
        builtin = params.builtin
        opts = params.opts
        opts = vim.tbl_deep_extend("force", { cwd = M.get_root() }, opts or {})
        if builtin == "files" then
            if vim.loop.fs_stat((opts.cwd or vim.loop.cwd()) .. "/.git") then
                opts.show_untracked = true
                builtin = "git_files"
            else
                builtin = "find_files"
            end
        end
        if builtin == "live_grep_args" then
            require("telescope").extensions.live_grep_args.live_grep_args(opts)
        elseif builtin == "grep_word_under_cursor" then
            require("telescope-live-grep-args.shortcuts").grep_word_under_cursor(opts)
        elseif builtin == "grep_visual_selection" then
            require("telescope-live-grep-args.shortcuts").grep_visual_selection(opts)
        else
            require("telescope.builtin")[builtin](opts)
        end
    end
end

function M.pick_window()
    local picked_window_id = require("window-picker").pick_window {
        include_current_win = true,
    } or vim.api.nvim_get_current_win()
    vim.api.nvim_set_current_win(picked_window_id)
end

function M.swap_window()
    local window = require("window-picker").pick_window { include_current_win = false }
    if window == nil then
        return
    end
    local target_buffer = vim.fn.winbufnr(window)
    vim.api.nvim_win_set_buf(window, 0)
    vim.api.nvim_win_set_buf(0, target_buffer)
end

function M.accept_ai_suggestion()
    if require("copilot.suggestion").is_visible() then
        if vim.api.nvim_get_mode().mode == "i" then
            vim.api.nvim_feedkeys(
                vim.api.nvim_replace_termcodes("<c-G>u", true, true, true),
                "n",
                false
            )
        end
        require("copilot.suggestion").accept()
        return true
    end
end

return M
