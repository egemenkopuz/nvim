return {
    {
        "folke/noice.nvim",
        enabled = true,
        event = "VeryLazy",
        dependencies = { "MunifTanjim/nui.nvim" },
        init = function()
            require("user.utils").load_keymap "noice"
        end,
        opts = {
            presets = {
                bottom_search = true,
                command_palette = false,
                long_message_to_split = true,
                inc_rename = true,
                lsp_doc_border = true,
            },
            cmdline = {
                view = "cmdline",
                format = { cmdline = { pattern = "^:", icon = ":", lang = "vim" } },
            },
            lsp = {
                signature = { enabled = false },
                progress = { enabled = false },
                hover = {
                    enabled = true,
                    opts = {
                        scrollbar = false,
                        size = {
                            max_height = math.floor(vim.o.lines * 0.5),
                            max_width = math.floor(vim.o.columns * 0.4),
                        },
                    },
                },
                override = {
                    ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
                    ["vim.lsp.util.stylize_markdown"] = true,
                },
            },
        },
        config = true,
    },

    {
        "rebelot/heirline.nvim",
        event = "BufReadPre",
        dependencies = {
            {
                "linrongbin16/lsp-progress.nvim",
                opts = {
                    max_size = 80,
                    series_format = function(title, message, percentage, done)
                        local builder = {}
                        local has_title = false
                        local has_message = false
                        if type(title) == "string" and string.len(title) > 0 then
                            table.insert(builder, title)
                            has_title = true
                        end
                        if type(message) == "string" and string.len(message) > 0 then
                            table.insert(builder, message)
                            has_message = true
                        end
                        if percentage and (has_title or has_message) then
                            table.insert(builder, string.format("(%.0f%%)", percentage))
                        end
                        return table.concat(builder, " ")
                    end,
                    client_format = function(client_name, spinner, series_messages)
                        if #series_messages == 0 then
                            return nil
                        end
                        return {
                            name = client_name,
                            spinner = spinner,
                            body = table.concat(series_messages, ", "),
                        }
                    end,
                    format = function(client_messages)
                        local bufnr = vim.api.nvim_get_current_buf()
                        local lsp_clients = vim.lsp.get_clients { bufnr = bufnr }

                        local builder = {}
                        if #client_messages == 0 then
                            for _, cli in ipairs(lsp_clients) do
                                if
                                    type(cli) == "table"
                                    and type(cli.name) == "string"
                                    and string.len(cli.name) > 0
                                then
                                    if cli.name ~= "null-ls" and cli.name ~= "copilot" then
                                        table.insert(builder, cli.name)
                                    end
                                end
                            end
                        else
                            local messages_map = {}
                            for _, climsg in ipairs(client_messages) do
                                messages_map[climsg.name] = climsg.body
                            end
                            table.sort(lsp_clients, function(a, b)
                                return a.name < b.name
                            end)
                            for _, cli in ipairs(lsp_clients) do
                                if
                                    type(cli) == "table"
                                    and type(cli.name) == "string"
                                    and string.len(cli.name) > 0
                                then
                                    if messages_map[cli.name] then
                                        table.insert(builder, messages_map[cli.name])
                                    end
                                end
                            end
                        end
                        if #builder > 0 then
                            return table.concat(builder, " ")
                        end
                        return ""
                    end,
                },
                config = function(_, opts)
                    require("lsp-progress").setup(opts)
                end,
            },
        },
        opts = function()
            local gm = require "plugins.modules.heirline.git"
            local dm = require "plugins.modules.heirline.diagnostics"
            local fm = require "plugins.modules.heirline.file"
            local lm = require "plugins.modules.heirline.lang"
            local others = require "plugins.modules.heirline.others"
            local colors = require "user.colors"

            local bg_color = colors.sl_bg

            if vim.g.transparent then
                bg_color = "None"
            end

            local statusline = {
                hl = { bg = bg_color },
                others.mode(),
                gm.git_branch(),
                fm.filename(),
                gm.git_diff(),
                others.macro(),
                others.fill(),
                lm.lsp_progress(),
                others.search_count(),
                dm.diagnostics(),
                others.copilot(),
                lm.python_env(),
                fm.filetype(),
            }
            return { statusline = statusline }
        end,
        config = function(_, opts)
            vim.opt.laststatus = 3
            require("heirline").setup(opts)
        end,
    },
    {
        "folke/snacks.nvim",
        priority = 1000,
        lazy = false,
        init = function()
            require("user.utils").load_keymap "snacks"
        end,
        opts = function()
            local project_pick = function()
                local fzf_lua = require "fzf-lua"
                local history = require "project_nvim.utils.history"
                fzf_lua.fzf_exec(function(cb)
                    local results = history.get_recent_projects()
                    for _, e in ipairs(results) do
                        cb(e)
                    end
                    cb()
                end, {
                    actions = {
                        ["default"] = function(e)
                            vim.cmd("e " .. e[1] .. " | cd %:p:h")
                            require("persistence").load()
                        end,
                        ["ctrl-d"] = {
                            function(selected)
                                history.delete_project { value = selected[1] }
                            end,
                            fzf_lua.actions.resume,
                        },
                    },
                })
            end
            local function open_nvim_config()
                vim.cmd "e $MYVIMRC | cd %:p:h"
                require("persistence").load()
            end

            local function open_global_config()
                vim.cmd "e $HOME/.config | cd %:p:h"
                require("persistence").load()
            end
            return {
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
                dashboard = {
                    preset = {
                        header = require("user.icons").dashboard,
                        keys = {
                            -- stylua: ignore start
                            { action = ":ene | startinsert", desc = " New File", icon = " ", key = "fn", },
                            { action = ":FzfLua files", desc = " Find File", icon = " ", key = "ff", },
                            { action = ":FzfLua live_grep", desc = " Find Text", icon = " ", key = "fg", },
                            { action = ":FzfLua oldfiles", desc = " Recent Files", icon = "󱋡 ", key = "fr", },
                            { action = require("persistence").select, desc = " Sessions", icon = " ", key = "ss", },
                            { action = project_pick, desc = " Projects", icon = " ", key = "sp", },
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
                        { section = "startup" },
                    },
                },
            }
        end,
    },

    {
        "luukvbaal/statuscol.nvim",
        enabled = true,
        event = "BufReadPre",
        config = function(_, _)
            local builtin = require "statuscol.builtin"
            local opts = {
                relculright = true,
                segments = {
                    {
                        text = {
                            function(args)
                                args.fold = {
                                    width = 1, -- current width of the fold column
                                    close = "󰅀", -- foldclose
                                    open = "󰅂", -- foldopen
                                    sep = "", -- foldsep
                                }
                                return builtin.foldfunc(args)
                            end,
                            -- " ",
                        },
                        -- click = "v:lua.ScFa",
                    },
                    -- { sign = { namespace = { "diagnostic" } } },
                    { text = { builtin.lnumfunc }, click = "v:lua.ScLa" },
                    { sign = { namespace = { "gitsigns" }, maxwidth = 1, colwidth = 1 } },
                },
            }
            require("statuscol").setup(opts)
        end,
    },

    {
        "echasnovski/mini.map",
        version = false,
        event = "BufReadPre",
        init = function()
            require("user.utils").load_keymap "map"
        end,
        opts = function()
            local map = require "mini.map"
            return {
                integrations = {
                    map.gen_integration.builtin_search(),
                    map.gen_integration.gitsigns(),
                    map.gen_integration.diagnostic(),
                },
                symbols = {
                    encode = map.gen_encode_symbols.dot "4x2",
                    scroll_line = "┃",
                    scroll_view = "│",
                },
                window = { zindex = 9990 },
            }
        end,
        config = function(_, opts)
            require("mini.map").setup(opts)
        end,
    },

    {
        "MeanderingProgrammer/render-markdown.nvim",
        opts = {
            file_types = { "markdown", "Avante", "copilot-chat" },
            render_modes = { "n", "c", "t", "i" },
            code = {
                sign = false,
                position = "right",
                left_pad = 1,
                right_pad = 1,
                width = "block",
            },
            heading = {
                sign = false,
                border = true,
                below = "▔",
                above = "▁",
                left_pad = 0,
                right_pad = 4,
                position = "left",
                icons = {
                    " ",
                    " ",
                    " ",
                    " ",
                    " ",
                    " ",
                },
            },
        },
        ft = { "markdown", "Avante", "copilot-chat" },
    },

    {
        "echasnovski/mini.hipatterns",
        version = false,
        event = "BufReadPre",
        config = function()
            local hipatterns = require "mini.hipatterns"

            vim.api.nvim_set_hl(0, "MiniHipatternsFix", { fg = "#ffffff", bg = "#db4b4b" })
            vim.api.nvim_set_hl(0, "MiniHipatternsHack", { fg = "#181616", bg = "#e0af68" })
            vim.api.nvim_set_hl(0, "MiniHipatternsWarn", { fg = "#181616", bg = "#ffcc00" })
            vim.api.nvim_set_hl(0, "MiniHipatternsTodo", { fg = "#181616", bg = "#80C4E9" })
            vim.api.nvim_set_hl(0, "MiniHipatternsPerf", { fg = "#181616", bg = "#bb9af7" })
            vim.api.nvim_set_hl(0, "MiniHipatternsNote", { fg = "#181616", bg = "#10b981" })

            hipatterns.setup {
                -- stylua: ignore
                highlighters = {
                    fixme = { pattern = "%f[%w]()FIXME()%f[%W]", group = "MiniHipatternsFix" },
                    fix = { pattern = "%f[%w]()FIX()%f[%W]", group = "MiniHipatternsFix" },
                    hack = { pattern = "%f[%w]()HACK()%f[%W]", group = "MiniHipatternsHack" },
                    warn = { pattern = "%f[%w]()WARN()%f[%W]", group = "MiniHipatternsWarn" },
                    warning = { pattern = "%f[%w]()WARNING()%f[%W]", group = "MiniHipatternsWarn", },
                    todo = { pattern = "%f[%w]()TODO()%f[%W]", group = "MiniHipatternsTodo" },
                    perf = { pattern = "%f[%w]()PERF()%f[%W]", group = "MiniHipatternsPerf" },
                    note = { pattern = "%f[%w]()NOTE()%f[%W]", group = "MiniHipatternsNote" },
                    hex_color = hipatterns.gen_highlighter.hex_color({ priority = 2000 }),
                    shorthand = {
                        pattern = "()#%x%x%x()%f[^%x%w]",
                        group = function(_, _, data)
                            local match = data.full_match
                            local r, g, b = match:sub(2, 2), match:sub(3, 3), match:sub(4, 4)
                            local hex_color = "#" .. r .. r .. g .. g .. b .. b
                            return MiniHipatterns.compute_hex_color_group(hex_color, "bg")
                        end,
                        extmark_opts = { priority = 2000 },
                    },
                },
            }
        end,
    },

    {
        "https://git.sr.ht/~whynothugo/lsp_lines.nvim",
        event = "LspAttach",
        init = function()
            require("user.utils").load_keymap "lsp_lines"
        end,
        config = true,
    },

    {
        "sphamba/smear-cursor.nvim",
        enabled = true,
        lazy = false,
        opts = {
            smear_between_buffers = true,
            smear_between_neighbor_lines = true,
            use_floating_windows = true,
            legacy_computing_symbols_support = false,
            hide_target_hack = true,
            cursor_color = "none",
            stiffness = 0.75,
            trailing_exponent = 3,
            trailing_stiffness = 0.4,
            gamma = 1,
            volume_reduction_exponent = -0.1,
            distance_stop_animating = 0.5,
            -- filetypes_disabled = { "Avante" },
        },
    },

    {
        "echasnovski/mini.tabline",
        event = "UIEnter",
        version = false,
        init = function()
            require("user.utils").load_keymap "tabline"
        end,
        opts = function()
            local icons = require "user.icons"
            return {
                tabpage_section = "right",
                format = function(buf_id, label)
                    local modified = vim.bo[buf_id].modified and icons.diff.modified or ""
                    local readonly = vim.bo[buf_id].readonly and icons.custom.lock or ""
                    local suffix = modified .. readonly

                    return MiniTabline.default_format(buf_id, label) .. suffix
                end,
            }
        end,
        config = true,
    },
}
