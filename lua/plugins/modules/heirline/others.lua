local M = {}

local utils = require "plugins.modules.heirline.utils"
local colors = require "user.colors"
local custom_icons = require("user.icons").custom

function M.fill()
    return {
        provider = utils.fill,
        hl = "StatusLineBackground",
    }
end

function M.mode()
    return {
        init = function(self)
            self.mode = vim.fn.mode(1)
        end,
        update = {
            "ModeChanged",
            pattern = "*:*",
            callback = vim.schedule_wrap(function()
                vim.cmd "redrawstatus"
            end),
        },
        static = {
            mode_names = {
                n = "N",
                no = "N?",
                nov = "N?",
                noV = "N?",
                ["no\22"] = "N?",
                niI = "Ni",
                niR = "Nr",
                niV = "Nv",
                nt = "Nt",
                v = "V",
                vs = "Vs",
                V = "V_",
                Vs = "Vs",
                ["\22"] = "^V",
                ["\22s"] = "^V",
                s = "S",
                S = "S_",
                ["\19"] = "^S",
                i = "I",
                ic = "Ic",
                ix = "Ix",
                R = "R",
                Rc = "Rc",
                Rx = "Rx",
                Rv = "Rv",
                Rvc = "Rv",
                Rvx = "Rv",
                c = "C",
                cv = "Ex",
                r = "...",
                rm = "M",
                ["r?"] = "?",
                ["!"] = "!",
                t = "T",
            },
            mode_colors = {
                n = colors.custom.light_red,
                i = colors.custom.light_green,
                v = colors.custom.light_purple,
                V = colors.custom.light_purple,
                ["\22"] = colors.custom.light_purple,
                c = colors.custom.light_gray,
                s = colors.custom.light_cyan,
                S = colors.custom.light_cyan,
                ["\19"] = colors.custom.light_cyan,
                R = colors.custom.light_orange,
                r = colors.custom.light_orange,
                ["!"] = colors.custom.light_red,
                t = colors.custom.light_red,
            },
        },
        provider = function(self)
            local mode = "<" .. self.mode_names[self.mode] .. ">"
            return utils.stylize(mode, { padding = { left = 1, right = 4 - #mode } })
        end,
        hl = function(self)
            local mode = self.mode:sub(1, 1)
            return { fg = self.mode_colors[mode], bold = true }
        end,
    }
end

function M.macro()
    return {
        static = { recording_icon = custom_icons.macro_recording },
        condition = function()
            return vim.fn.reg_recording() ~= "" and vim.o.cmdheight == 0
        end,
        init = function(self)
            self.macro_key = vim.fn.reg_recording()
        end,
        update = { "RecordingEnter", "RecordingLeave" },
        {
            provider = function(self)
                return utils.stylize(self.recording_icon, { padding = { left = 2 } })
            end,
            hl = { fg = colors.custom.light_red, bold = false },
        },
        {
            provider = function(_)
                return utils.stylize("recording macro:", {})
            end,
            hl = { fg = colors.custom.light_yellow, bold = false },
        },
        {
            provider = function(self)
                return utils.stylize(self.macro_key, { padding = { right = 2 } })
            end,
            hl = { fg = colors.custom.light_orange, bold = false },
        },
    }
end

function M.search_count()
    return {
        condition = function()
            return vim.v.hlsearch ~= 0 and vim.o.cmdheight == 0
        end,
        init = function(self)
            local ok, search = pcall(vim.fn.searchcount)
            if ok and search.total then
                self.search = search
            end
        end,
        provider = function(self)
            local search = self.search
            return utils.stylize(
                string.format("[%d/%d]", search.current, math.min(search.total, search.maxcount)),
                { padding = { left = 1, right = 1 } }
            )
        end,
        hl = { fg = colors.custom.light_cyan, bold = false },
    }
end

function M.copilot()
    return {
        static = {
            idle_icon = custom_icons.copilot,
            color = colors.custom.sl_copilot,
        },
        condition = function()
            local client = vim.lsp.get_clients({ name = "copilot" })[1]
            if client == nil then
                return false
            end
            return true
        end,
        init = function(self)
            self.copilot_api = require "copilot.client"
            self.client = vim.lsp.get_clients({ name = "copilot" })[1]
        end,
        provider = function(self)
            if self.copilot_api.buf_is_attached(vim.api.nvim_get_current_buf()) then
                if vim.tbl_isempty(self.client.requests) then
                    return utils.stylize(self.idle_icon, { padding = { left = 1, right = 1 } })
                end
                local spinners =
                    { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }
                local ms = vim.loop.hrtime() / 1000000
                local frame = math.floor(ms / 120) % #spinners
                return utils.stylize(spinners[frame + 1], { padding = { left = 1, right = 1 } })
            end
            return ""
        end,
        hl = function(self)
            return { fg = self.color }
        end,
    }
end

return M
