local M = {
    __opts = {},
    __setup_called = false,
}

local default_config = {
    transparent = true,
}

local colors = require "custom_theme.colors"

function M.load()
    vim.cmd "hi clear"

    if vim.fn.exists "syntax_on" then
        vim.cmd "syntax reset"
    end

    vim.o.termguicolors = true
    vim.g.colors_name = "custom_theme"

    local hls = require("custom_theme.groups").setup()

    for group, setting in pairs(hls) do
        if M.__opts.transparent and setting.bg and setting.bg == colors.bg then
            setting.bg = nil
        end
        hls[group] = setting
    end

    for group, setting in pairs(hls) do
        vim.api.nvim_set_hl(0, group, setting)
    end
end

function M.setup(opts)
    if M.__setup_called then
        return
    end

    M.__opts = vim.tbl_deep_extend("force", default_config, opts or {})
    M.__theme = M.__opts.theme
    M.__setup_called = true
end

return M
