local M = {}
local notify = require("user.utils").notify

local conditions = require "heirline.conditions"
local utils = require "plugins.modules.heirline.utils"

local config = require "user.config"
local custom_colors = config.colors.custom
local custom_icons = config.icons.custom

-- caching
local cache_python_env = ""

function M.lsp_progress()
    return {
        update = {
            "User",
            pattern = "LspProgressStatusUpdated",
            callback = vim.schedule_wrap(function()
                vim.cmd "redrawstatus"
            end),
        },
        on_click = {
            callback = function()
                vim.defer_fn(function()
                    vim.cmd "LspInfo"
                end, 100)
            end,
            name = "heirline_lspinfo",
        },
        provider = function()
            return utils.stylize(
                require("lsp-progress").progress(),
                { padding = { left = 1, right = 1 } }
            )
        end,
        hl = { fg = custom_colors.sl_lsp_progress },
    }
end

function M.python_env()
    return {
        condition = function()
            return conditions.buffer_matches { filetype = { "python" } }
        end,
        update = function()
            local venv = os.getenv "VIRTUAL_ENV" or os.getenv "CONDA_DEFAULT_ENV"
            if venv ~= nil and venv ~= cache_python_env then
                cache_python_env = venv
                return true
            end
            return false
        end,
        on_click = {
            callback = function()
                vim.defer_fn(function()
                    vim.cmd "VenvSelect"
                end, 100)
            end,
            name = "heirline_python_env",
        },
        init = function(self)
            self.venv = cache_python_env
        end,
        provider = function(self)
            local venv = utils.env_cleanup(self.venv)
            return venv ~= nil and utils.stylize(venv, { padding = { left = 1, right = 1 } })
        end,
        hl = { fg = custom_colors.sl_python_env },
    }
end

return M
