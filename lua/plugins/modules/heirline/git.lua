local M = {}

local conditions = require "heirline.conditions"
local utils = require "plugins.modules.heirline.utils"

local colors = require "user.colors"
local icons = require "user.icons"

local diff_colors = colors.diff
local diff_icons = icons.diff
local branch_type_colors = colors.branch_type
local custom_icons = icons.custom

-- caching
local cache_branch = nil
local cache_git_diff = { added = 0, removed = 0, changed = 0 }

function M.git_diff()
    return {
        condition = conditions.is_git_repo,
        update = function()
            local status_dict = vim.b.gitsigns_status_dict
            if not status_dict then
                return false
            end
            if status_dict.added ~= cache_git_diff.added then
                cache_git_diff.added = status_dict.added
                return true
            end
            if status_dict.removed ~= cache_git_diff.removed then
                cache_git_diff.removed = status_dict.removed
                return true
            end
            if status_dict.changed ~= cache_git_diff.changed then
                cache_git_diff.changed = status_dict.changed
                return true
            end
            return false
        end,
        static = {
            added_color = diff_colors.added,
            removed_color = diff_colors.removed,
            changed_color = diff_colors.modified,
            added_icon = diff_icons.added,
            removed_icon = diff_icons.removed,
            modified_icon = diff_icons.modified,
        },
        init = function(self)
            self.status_dict = vim.b.gitsigns_status_dict
            self.has_changes = self.status_dict.added and self.status_dict.added > 0
                or self.status_dict.removed and self.status_dict.removed > 0
                or self.status_dict.changed and self.status_dict.changed > 0
        end,
        {
            condition = function(self)
                return self.has_changes
            end,
            provider = function(_)
                return " "
            end,
        },
        {
            provider = function(self)
                local count = self.status_dict.added or 0
                return count > 0
                    and utils.stylize(self.added_icon .. count, { padding = { right = 1 } })
            end,
            hl = function(self)
                return { fg = self.added_color }
            end,
        },
        {
            provider = function(self)
                local count = self.status_dict.changed or 0
                return count > 0
                    and utils.stylize(self.modified_icon .. count, { padding = { right = 1 } })
            end,
            hl = function(self)
                return { fg = self.changed_color }
            end,
        },
        {
            provider = function(self)
                local count = self.status_dict.removed or 0
                return count > 0
                    and utils.stylize(self.removed_icon .. count, { padding = { right = 1 } })
            end,
            hl = function(self)
                return { fg = self.removed_color }
            end,
        },
    }
end

function M.git_branch()
    return {
        condition = conditions.is_git_repo,
        update = function(_)
            local status_dict = vim.b.gitsigns_status_dict
            if status_dict and status_dict.head ~= cache_branch then
                cache_branch = status_dict.head
                return true
            end
            return false
        end,
        static = {
            default_color = branch_type_colors.default,
            int_color = branch_type_colors.int,
            feat_color = branch_type_colors.feat,
            fix_color = branch_type_colors.fix,
            release_color = branch_type_colors.release,
            dev_color = branch_type_colors.dev,
            nightly_color = branch_type_colors.nightly,
            branch_icon = custom_icons.branch,
        },
        init = function(self)
            self.status_dict = vim.b.gitsigns_status_dict
            self.branch = self.status_dict.head
            self.branch_type = nil
            self.branch_name = nil
            self.branch_type_color = nil
            self.branch_name_color = nil
            if self.branch then
                local splits = {}
                for w in string.gmatch(self.branch, "[^/]+") do
                    table.insert(splits, w)
                end
                if #splits > 1 then
                    self.branch_type = splits[1]
                    self.branch_name = vim.fn.join({ unpack(splits, 2) }, "/")
                    if string.find(self.branch_type, "feat") then
                        self.branch_type_color = self.feat_color
                    elseif string.find(self.branch_type, "dev") then
                        self.branch_type_color = self.dev_color
                    elseif string.find(self.branch_type, "nightly") then
                        self.branch_type_color = self.nightly_color
                    elseif string.find(self.branch_type, "fix") then
                        self.branch_type_color = self.fix_color
                    elseif string.find(self.branch_type, "int") then
                        self.branch_type_color = self.int_color
                    elseif string.find(self.branch_type, "release") then
                        self.branch_type_color = self.release_color
                    else
                        self.branch_type_color = self.default_color
                    end
                elseif #splits == 1 then
                    self.branch_name = splits[1]
                    if string.find(self.branch_name, "int") then
                        self.branch_name_color = self.int_color
                    elseif string.find(self.branch_name, "release") then
                        self.branch_name_color = self.release_color
                    elseif string.find(self.branch_name, "dev") then
                        self.branch_name_color = self.dev_color
                    elseif string.find(self.branch_name, "nightly") then
                        self.branch_name_color = self.nightly_color
                    end
                else
                    return
                end
            end
        end,
        on_click = {
            callback = function()
                vim.defer_fn(function()
                    Snacks.lazygit()
                end, 100)
            end,
            name = "heirline_lazygit",
        },
        {
            provider = function(self)
                return utils.stylize(self.branch_icon, {
                    padding = { left = 1, right = 1 },
                })
            end,
            hl = function(self)
                return { fg = self.branch_type_color or self.branch_name_color }
            end,
        },
        {
            condition = function(self)
                return self.branch_type ~= nil
            end,
            provider = function(self)
                return utils.stylize(self.branch_type, {})
            end,
            hl = function(self)
                return { fg = self.branch_type_color, bold = true }
            end,
        },
        {
            condition = function(self)
                return self.branch_name ~= nil
            end,
            provider = function(self)
                if self.branch_type then
                    return utils.stylize("/" .. self.branch_name, {
                        padding = { right = 1 },
                    })
                else
                    return utils.stylize(self.branch_name, {
                        padding = { right = 1 },
                    })
                end
            end,
            hl = function(self)
                return { fg = self.branch_name_color }
            end,
        },
    }
end

return M
