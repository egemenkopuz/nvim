local M = {}

local conditions = require "heirline.conditions"
local utils = require "plugins.modules.heirline.utils"

local config = require "user.config"
local diag_colors = config.colors.diagnostics
local diag_icons = config.icons.diagnostics

function M.diagnostics()
    return {
        condition = conditions.has_diagnostics,
        static = {
            error_color = diag_colors.error,
            warn_color = diag_colors.warn,
            info_color = diag_colors.info,
            hint_color = diag_colors.hint,
            error_icon = diag_icons.error,
            warn_icon = diag_icons.warn,
            info_icon = diag_icons.info,
            hint_icon = diag_icons.hint,
        },
        update = { "DiagnosticChanged", "BufEnter" },
        init = function(self)
            self.errors = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR })
            self.warnings = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.WARN })
            self.hints = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.HINT })
            self.info = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.INFO })
        end,
        on_click = {
            callback = function()
                vim.cmd "Trouble diagnostics toggle filter.buf=0"
            end,
            name = "heirline_diagnostics",
        },
        {
            provider = function(self)
                return self.errors > 0
                    and utils.stylize((self.error_icon .. self.errors .. " "), {})
            end,
            hl = function(self)
                return { fg = self.error_color }
            end,
        },
        {
            provider = function(self)
                return self.warnings > 0
                    and utils.stylize(self.warn_icon .. self.warnings .. " ", {})
            end,
            hl = function(self)
                return { fg = self.warn_color }
            end,
        },
        {
            provider = function(self)
                return self.info > 0 and utils.stylize(self.info_icon .. self.info .. " ", {})
            end,
            hl = function(self)
                return { fg = self.info_color }
            end,
        },
        {
            provider = function(self)
                return self.hints > 0 and utils.stylize(self.hint_icon .. self.hints, {})
            end,
            hl = function(self)
                return { fg = self.hint_color }
            end,
        },
    }
end

return M
