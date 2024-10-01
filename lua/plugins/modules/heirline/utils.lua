local M = {}

function M.pad_string(str, padding)
    padding = padding or {}
    return str
            and str ~= ""
            and string.rep(" ", padding.left or 0) .. str .. string.rep(" ", padding.right or 0)
        or ""
end

function M.fill()
    return "%="
end

function M.shorten_path(path, sep, max_len)
    local len = #path
    if len <= max_len then
        return path
    end
    local segments = vim.split(path, sep)
    for idx = 1, #segments - 1 do
        if len <= max_len then
            break
        end
        local segment = segments[idx]
        local shortened = segment:sub(1, vim.startswith(segment, ".") and 2 or 1)
        segments[idx] = shortened
        len = len - (#segment - #shortened)
    end

    return table.concat(segments, sep)
end

function M.filename_and_parent(path, sep)
    local segments = vim.split(path, sep)
    if #segments == 0 then
        return path
    elseif #segments == 1 then
        return segments[#segments]
    else
        return table.concat({ segments[#segments - 1], segments[#segments] }, sep)
    end
end

function M.stl_escape(str)
    if type(str) ~= "string" then
        return str
    end
    return str:gsub("%%", "%%%%")
end

function M.resolve_sign(bufnr, lnum)
    local row = lnum - 1
    local extmarks = vim.api.nvim_buf_get_extmarks(
        bufnr,
        -1,
        { row, 0 },
        { row, -1 },
        { details = true, type = "sign" }
    )
    local ret
    for _, extmark in pairs(extmarks) do
        local sign_def = extmark[4]
        if sign_def.sign_text and (not ret or (ret.priority < sign_def.priority)) then
            ret = sign_def
        end
    end
    if ret then
        return { text = ret.sign_text, texthl = ret.sign_hl_group }
    end
end

function M.env_cleanup(venv)
    local out
    if string.find(venv, "/") then
        out = venv
        for w in venv:gmatch "([^/]+)" do
            out = w
        end
    end
    return out
end

function M.stylize(str, opts)
    opts = vim.tbl_extend("force", {
        padding = { left = 0, right = 0 },
        separator = { left = "", right = "" },
    }, opts)

    return opts.separator.left .. M.pad_string(str, opts.padding) .. opts.separator.right
end

return M
