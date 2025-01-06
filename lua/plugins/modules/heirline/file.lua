local M = {}

local utils = require "plugins.modules.heirline.utils"
local conditions = require "heirline.conditions"

local common_colors = require("user.colors").custom

-- caching
local cache_filename = nil
local cache_filetype = nil

function M.filetype()
    return {
        static = {
            default_icon_color = common_colors.light_blue,
        },
        update = function(_)
            local filetype = vim.bo.filetype
            if filetype ~= cache_filetype then
                cache_filetype = filetype
                return true
            end
            return false
        end,
        init = function(self)
            local icon, hl, is_default = MiniIcons.get("filetype", vim.bo.filetype)
            self.icon = icon or ""
            self.hl = hl or { fg = self.default_icon_color }
            if is_default == false then
                self.filetype = self.icon .. " " .. vim.bo.filetype
            else
                self.filetype = vim.bo.filetype
            end
        end,
        provider = function(self)
            return utils.stylize(self.filetype, { padding = { left = 1, right = 1 } })
        end,
    }
end

function M.filename()
    return {
        static = {
            path_separator = package.config:sub(1, 1),
        },
        condition = function()
            return not conditions.buffer_matches { buftype = { "terminal", "toggleterm" } }
        end,
        update = function(_)
            local filename = vim.api.nvim_buf_get_name(0)
            if filename ~= cache_filename then
                cache_filename = filename
                return true
            end
            return false
        end,
        init = function(self)
            self.filename = vim.fn.expand "%:~:."
            self.filename = utils.stl_escape(self.filename)
            self.filename = utils.shorten_path(self.filename, self.path_separator, 60)
            if self.filename:find(self.path_separator) then
                self.parent_path = self.filename:match("(.*)" .. self.path_separator)
                self.filename = self.filename:match("([^" .. self.path_separator .. "]+)$")
            else
                self.parent_path = nil
            end
        end,
        {
            condition = function(self)
                return self.parent_path ~= nil
            end,
            provider = function(self)
                return utils.stylize(
                    (self.parent_path .. self.path_separator),
                    { padding = { left = 0, right = 0 } }
                )
            end,
            hl = function()
                return { fg = common_colors.sl_parent_path, bold = false }
            end,
        },
        {
            provider = function(self)
                return utils.stylize(self.filename, { padding = { left = 0, right = 0 } })
            end,
            hl = function(self)
                return { fg = common_colors.sl_filename, bold = self.parent_path and true or false }
            end,
        },
    }
end

return M
