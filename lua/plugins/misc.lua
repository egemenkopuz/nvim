return {
    {
        "Eandrju/cellular-automaton.nvim",
        init = function()
            require("user.utils").load_keymap "cellular_automaton"
        end,
        lazy = false,
    },

    {
        "folke/snacks.nvim",
        priority = 1000,
        lazy = false,
        init = function()
            require("user.utils").load_keymap "snacks"
        end,
        opts = function()
            local icons = require "user.icons"

            local function open_nvim_config()
                vim.cmd "e $MYVIMRC | cd %:p:h"
                require("persistence").load()
            end

            local function open_global_config()
                vim.cmd "e $HOME/.config | cd %:p:h"
                require("persistence").load()
            end

            local function nvim_version()
                local version = vim.version()
                local v = "v" .. version.major .. "." .. version.minor .. "." .. version.patch
                return v
            end

            local function plugin_stats()
                local stats = require("lazy").stats()
                local updates = require("lazy.manage.checker").updated
                return {
                    count = stats.count,
                    loaded = stats.loaded,
                    startuptime = (math.floor(stats.startuptime * 100 + 0.5) / 100),
                    updates = #updates,
                }
            end

            local out = {
                explorer = {
                    enabled = true,
                    replace_netrw = false,
                },
                input = { enabled = false },
                styles = {
                    lazygit = { width = 0, height = 0 },
                    notification = { wo = { wrap = true } },
                    zen = { width = 0.8 },
                },
                gitbrowse = {},
                bigfile = { enabled = true },
                lazygit = { enabled = true },
                scroll = {
                    enabled = false,
                    animate = {
                        duration = { step = 15, total = 250 },
                        easing = "linear",
                    },
                },
                indent = {
                    indent = { char = "┊" },
                    scope = { enabled = false },
                    animate = { enabled = false },
                    chunk = {
                        enabled = true,
                        char = {
                            corner_top = "┌",
                            corner_bottom = "└",
                            horizontal = "─",
                            vertical = "│",
                            arrow = "─",
                        },
                    },
                },
                zen = {
                    enabled = true,
                    show = { statusline = true, tabline = false },
                },
                zoom = { enabled = true },
                notifier = { enabled = true, timeout = 1000 },
                picker = {
                    prompt = "  ",
                    actions = require("trouble.sources.snacks").actions,
                    win = {
                        input = { keys = { ["<c-t>"] = { "trouble_open", mode = { "n", "i" } } } },
                    },
                    sources = {
                        explorer = {
                            layout = {
                                preset = "sidebar",
                                auto_hide = { "input" },
                                preview = false,
                            },
                        },
                        files = {
                            actions = {
                                replace_buf = function(picker)
                                    local prev_buf = vim.fn.winbufnr(vim.fn.winnr "#")
                                    picker:action "confirm"
                                    vim.schedule(function()
                                        Snacks.bufdelete { buf = prev_buf }
                                    end)
                                end,
                            },
                            win = {
                                input = {
                                    keys = { ["<M-r>"] = { "replace_buf", mode = { "i", "n" } } },
                                },
                            },
                        },
                    },
                    icons = {
                        diagnostics = {
                            Error = icons.diagnostics.error,
                            Warn = icons.diagnostics.warn,
                            Info = icons.diagnostics.info,
                            Hint = icons.diagnostics.hint,
                        },
                        git = {
                            enabled = true,
                            commit = "󰜘 ",
                            staged = "●",
                            added = "+",
                            deleted = "-",
                            modified = "○",
                            renamed = "→",
                            unmerged = "⇄",
                            untracked = "?",
                            ignored = "!",
                        },
                    },
                },
                dashboard = {
                    preset = {
                        header = require("user.icons").dashboard,
                        keys = {
                            -- stylua: ignore start
                            { action = ":ene | startinsert", desc = " New File", icon = " ", key = "fn", },
                            { action = function() Snacks.picker.recent() end, desc = " Recent Files", icon = "󱋡 ", key = "fr", },
                            { action = require("persistence").select, desc = " Sessions", icon = " ", key = "ss", },
                            { action = function() Snacks.picker.projects() end, desc = " Projects", icon = " ", key = "sp", },
                            { action = open_nvim_config, desc = "Nvim Config", icon = "  ", key = "cc" },
                            { action = open_global_config, desc = "Global Config", icon = "  ", key = "cf" },
                            { action = ":Lazy", desc = " Plugins", icon = " ", key = "cp", },
                            { action = function() vim.api.nvim_input "<cmd>qa<cr>" end, desc = " Quit", icon = " ", key = "q", },
                            -- stylua: ignore end
                        },
                    },
                    sections = {
                        { section = "header", padding = 1 },
                        { section = "keys", padding = 1 },
                        { section = "recent_files", padding = 1 },
                        { section = "projects", padding = 1 },
                        function()
                            local version = nvim_version()
                            local ps = plugin_stats()
                            return {
                                align = "center",
                                text = {
                                    { " ", hl = "footer" },
                                    { version, hl = "NonText" },
                                    { "     ", hl = "footer" },
                                    { tostring(ps.count), hl = "NonText" },
                                    { "    󰛕 ", hl = "footer" },
                                    { ps.startuptime .. " ms", hl = "NonText" },
                                },
                            }
                        end,
                    },
                },
            }

            return out
        end,
    },
}
