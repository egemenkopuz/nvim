return {
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
                lm.conform(),
                lm.lint(),
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
            -- file_types = { "markdown" },
            render_modes = { "n", "c", "t", "i" },
            code = {
                sign = false,
                style = "normal",
                position = "right",
                right_pad = 1,
                width = "block",
                highlight = "MsgArea",
            },
            checkbox = { enabled = false },
            heading = {
                icons = { "󰬺 ", "󰬻 ", "󰬼 ", "󰬽 ", "󰬾 ", "󰬿 " },
                position = "inline",
                backgrounds = {},
            },
            custom = {
                python = { pattern = "%.py$", icon = "󰌠 " },
                markdown = { pattern = "%.md$", icon = "󰍔 " },
            },
            quote = { repeat_linebreak = true },
            pipe_table = {
                preset = "round",
                alignment_indicator = "",
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
