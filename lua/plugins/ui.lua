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
                command_palette = true,
                long_message_to_split = true,
                inc_rename = true,
                lsp_doc_border = true,
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
                styles = { lazygit = { width = 0, height = 0 } },
                bigfile = { enabled = true },
                lazygit = { enabled = true },
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
        "lukas-reineke/indent-blankline.nvim",
        event = "BufReadPre",
        main = "ibl",
        opts = {
            indent = { char = "│" },
            scope = { enabled = true, show_start = false, show_end = false },
            exclude = {
                filetypes = {
                    "help",
                    "alpha",
                    "dashboard",
                    "neo-tree",
                    "Trouble",
                    "trouble",
                    "lazy",
                    "mason",
                    "notify",
                    "toggleterm",
                    "lazyterm",
                    "copilot-chat",
                },
            },
        },
        config = function(_, opts)
            require("ibl").setup(opts)
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
        "akinsho/bufferline.nvim",
        event = "BufReadPre",
        opts = {
            options = {
                numbers = function(opts)
                    return opts.raise(opts.ordinal)
                end,
                offsets = {
                    {
                        filetype = "undotree",
                        text = "Undo History",
                        padding = 0,
                        text_align = "center",
                        highlight = "Offset",
                    },
                    {
                        filetype = "Outline",
                        text = "LSP Symbols",
                        padding = 0,
                        text_align = "center",
                        highlight = "Offset",
                    },
                },
                diagnostics = "nvim_lsp",
                show_buffer_close_icons = false,
                show_close_icon = false,
                color_icons = false,
                close_command = function(n)
                    require("mini.bufremove").delete(n, false)
                end,
                right_mouse_command = function(n)
                    require("mini.bufremove").delete(n, false)
                end,
                always_show_bufferline = false,
            },
        },
        config = function(_, opts)
            opts.options.groups = {
                items = {
                    require("bufferline.groups").builtin.pinned:with { icon = "" },
                },
            }
            require("bufferline").setup(opts)
            require("user.utils").load_keymap "bufferline"

            -- Fix bufferline when restoring a session
            vim.api.nvim_create_autocmd({ "BufAdd", "BufDelete" }, {
                callback = function()
                    vim.schedule(function()
                        pcall(nvim_bufferline)
                    end)
                end,
            })
        end,
    },

    {
        "OXY2DEV/markview.nvim",
        ft = "markdown",
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
        "rcarriga/nvim-notify",
        lazy = false,
        opts = {
            timeout = 1000,
            max_height = function()
                return math.floor(vim.o.lines * 0.75)
            end,
            max_width = function()
                return math.floor(vim.o.columns * 0.75)
            end,
            on_open = function(win)
                vim.api.nvim_win_set_config(win, { zindex = 100 })
            end,
            render = "compact",
            stages = "static",
        },
        init = function()
            vim.notify = require "notify"
            require("user.utils").load_keymap "notify"
        end,
    },
}
