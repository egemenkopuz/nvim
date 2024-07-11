return {
    {
        "folke/noice.nvim",
        event = "VeryLazy",
        dependencies = { "MunifTanjim/nui.nvim" },
        opts = {
            presets = {
                bottom_search = true,
                command_palette = true,
                long_message_to_split = true,
                inc_rename = false,
            },
            lsp = {
                signature = { enabled = false },
                progress = { enabled = false },
                override = {
                    ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
                    ["vim.lsp.util.stylize_markdown"] = true,
                    ["cmp.entry.get_documentation"] = true,
                },
            },
        },
        config = true,
    },

    {
        "nvim-lualine/lualine.nvim",
        event = "BufReadPre",
        dependencies = {
            { "arkav/lualine-lsp-progress" },
            { "AndreM222/copilot-lualine" },
        },
        opts = function()
            local icons = require("user.config").icons
            local colors = require("user.config").colors
            local utils = require "user.utils"

            local diff_color = {
                added = { fg = colors.diff.added },
                modified = { fg = colors.diff.modified },
                removed = { fg = colors.diff.removed },
            }
            local diagnostics_color = {
                error = { fg = colors.diagnostics.error },
                warn = { fg = colors.diagnostics.warn },
                info = { fg = colors.diagnostics.info },
                hint = { fg = colors.diagnostics.hint },
            }
            if require("user.config").transparent then
                for _, color in pairs(diff_color) do
                    color.bg = "none"
                end
                for _, color in pairs(diagnostics_color) do
                    color.bg = "none"
                end
            end

            return {
                options = {
                    theme = "auto",
                    component_separators = { left = "", right = "" },
                    section_separators = { left = "", right = "" },
                    globalstatus = true,
                    disabled_filetypes = {
                        statusline = { "alpha", "packer", "lazy", "terminal", "dashboard" },
                    },
                },
                extensions = {
                    "toggleterm",
                    "nvim-dap-ui",
                    "lazy",
                    "trouble",
                    "overseer",
                    "symbols-outline",
                },
                sections = {
                    lualine_a = { "mode" },
                    lualine_b = { "branch" },
                    lualine_c = {
                        "git_prompt_string",
                        {
                            "diff",
                            symbols = {
                                added = icons.diff.added,
                                modified = icons.diff.modified,
                                removed = icons.diff.removed,
                            },
                            diff_color = diff_color,
                        },
                        {
                            "filename",
                            symbols = { modified = "[+]", readonly = "[-]", unnamed = "" },
                            path = 1,
                        },
                        {
                            function()
                                local recording_register = vim.fn.reg_recording()
                                if recording_register == "" then
                                    return ""
                                else
                                    return "recording @" .. recording_register
                                end
                            end,
                        },
                        {
                            function()
                                local result = vim.fn["VMInfos"]()
                                if result.status == nil then
                                    return ""
                                end
                                return "multi-cursor " .. result.ratio
                            end,
                        },
                    },
                    lualine_x = {
                        {
                            "lsp_progress",
                            display_components = { { "title", "percentage", "message" } },
                            colors = {
                                percentage = "#505A6C",
                                title = "#505A6C",
                                message = "#505A6C",
                                use = true,
                            },
                        },
                        {
                            "copilot",
                            symbols = {
                                status = { icons = { unknown = " " } },
                                spinners = require("copilot-lualine.spinners").dots,
                            },
                        },
                        {
                            function()
                                local active_clients = vim.lsp.get_clients { bufnr = 0 }

                                table.sort(active_clients, function(a, b)
                                    return a.name < b.name
                                end)

                                local index = 0
                                local lsp_names = ""
                                local mapping = require("user.config").lsp_to_status_name
                                for _, lsp_config in ipairs(active_clients) do
                                    for _, lsp_name in
                                        ipairs(require("user.config").lsp_to_status_exclude)
                                    do
                                        if lsp_config.name == lsp_name then
                                            goto continue
                                        end
                                    end

                                    -- stylua: ignore
                                    local lsp_name = mapping[lsp_config.name] == nil and lsp_config.name or mapping[lsp_config.name]

                                    index = index + 1
                                    if index == 1 then
                                        lsp_names = lsp_name
                                    else
                                        lsp_names = lsp_names .. " " .. lsp_name
                                    end

                                    ::continue::
                                end

                                return lsp_names
                            end,
                            color = { fg = "gray" },
                        },
                        {
                            function()
                                local shiftwidth = vim.api.nvim_buf_get_option(0, "shiftwidth")
                                return " " .. shiftwidth
                            end,
                            padding = 1,
                        },
                        {
                            "filetype",
                            colored = false,
                            icon_only = false,
                            icon = { align = "right" },
                        },
                        {
                            function()
                                local venv = os.getenv "CONDA_DEFAULT_ENV"
                                    or os.getenv "VIRTUAL_ENV"
                                if venv then
                                    return string.format("(%s)", utils.env_cleanup(venv))
                                end
                                return ""
                            end,
                            cond = function()
                                return vim.bo.filetype == "python"
                            end,
                        },
                    },
                    lualine_y = {
                        {
                            "diagnostics",
                            symbols = {
                                error = icons.diagnostics.error,
                                warn = icons.diagnostics.warn,
                                info = icons.diagnostics.info,
                                hint = icons.diagnostics.hint,
                            },
                            diagnostics_color = diagnostics_color,
                        },
                    },
                    lualine_z = { "location" },
                },
            }
        end,
        config = function(_, opts)
            require("lualine").setup(opts)
            if require("user.config").transparent then
                for _, section in ipairs { "b", "c", "x", "y" } do
                    vim.cmd("highlight lualine_" .. section .. "_normal guibg=NONE")
                    vim.cmd("highlight lualine_" .. section .. "_inactive guibg=NONE")
                end
            end
        end,
    },

    {
        "goolord/alpha-nvim",
        enabled = false,
        event = "VimEnter",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        opts = function()
            local config = require "user.config"
            local dashboard = require "alpha.themes.dashboard"
            local fn = vim.fn

            if config.logo then
                dashboard.section.header.val = config.logo
            end
            -- stylua: ignore
            dashboard.section.buttons.val = {
                dashboard.button("f n", " " .. " New file", ":ene <BAR> startinsert <CR>"),
                dashboard.button("f f", " " .. " Find file", ":Telescope find_files <CR>"),
                dashboard.button("f t", " " .. " Find text", ":Telescope live_grep <CR>"),
                dashboard.button("f o", "󱋡 " .. " Recent files", ":Telescope oldfiles <CR>"),
                dashboard.button("s p", " " .. " Select project", ":Telescope projects <CR>"),
                dashboard.button("s s", " " .. " Select session", ":Telescope persisted <CR>"),
                dashboard.button("c c", " " .. " Nvim config", ":e $MYVIMRC | :cd %:p:h | :SessionLoad<CR>"),
                dashboard.button("c f", " " .. " Global config", ":e $HOME/.config | :cd %:p:h | :SessionLoad<CR>"),
                dashboard.button("c p", " " .. " Plugins", ":Lazy<CR>"),
                dashboard.button("q", " " .. " Quit", ":qa <CR>"),
            }

            dashboard.section.footer.opts.hl = "Type"
            dashboard.section.header.opts.hl = "AlphaHeader"
            dashboard.section.buttons.opts.hl = "AlphaButtons"
            dashboard.opts.layout[1].val = fn.max { 2, fn.floor(fn.winheight(0) * 0.1) }

            return dashboard
        end,
        config = function(_, dashboard)
            require("alpha").setup(dashboard.opts)

            vim.api.nvim_create_autocmd("User", {
                pattern = "LazyVimStarted",
                -- stylua: ignore
                callback = function()
                    local date = os.date "%d/%m/%Y "
                    local time = os.date "%H:%M:%S"
                    local v = vim.version()
                    local version = "v" .. v.major .. "." .. v.minor .. "." .. v.patch
                    local stats = require("lazy").stats()
                    local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
                    dashboard.section.footer.val = "[" .. date .. time .. "][" .. stats.count .. " plugins " .. ms .. "ms][" .. version .. "]"
                    pcall(vim.cmd.AlphaRedraw)
                end,
            })
        end,
    },

    {
        "nvimdev/dashboard-nvim",
        lazy = false,
        opts = function()
            local logo_table = require("user.config").logo
            local logo = table.concat(logo_table, "\n")
            logo = string.rep("\n", 4) .. logo .. "\n\n"

            local opts = {
                theme = "doom",
                hide = { statusline = false },
                config = {
                    header = vim.split(logo, "\n"),
                    -- stylua: ignore
                    center = {
                        { action = "ene | startinsert", desc = " New File", icon = " ", key = "fn", },
                        { action = "Telescope find_files", desc = " Find File", icon = " ", key = "ff", },
                        { action = "Telescope live_grep", desc = " Find Text", icon = " ", key = "fg", },
                        { action = "Telescope oldfiles", desc = " Recent Files", icon = "󱋡 ", key = "fr", },
                        { action = "Telescope persisted", desc = " Sessions", icon = " ", key = "ss", },
                        { action = "Telescope projects", desc = " Projects", icon = " ", key = "sp", },
                        { action = "e $MYVIMRC | cd %:p:h | SessionLoad", desc = " Nvim Config", icon = " ", key = "cc", },
                        { action = "e $HOME/.config | cd %:p:h | SessionLoad", desc = " Global Config", icon = " ", key = "cf", },
                        { action = "Lazy", desc = " Plugins", icon = " ", key = "cp", },
                        { action = function() vim.api.nvim_input "<cmd>qa<cr>" end, desc = " Quit", icon = " ", key = "q", },
                    },
                },
            }

            for _, button in ipairs(opts.config.center) do
                button.desc = button.desc .. string.rep(" ", 43 - #button.desc)
                button.key_format = "  %s"
            end

            vim.api.nvim_set_hl(0, "DashboardFooter", { fg = "#999999" })
            vim.api.nvim_set_hl(0, "DashboardHeader", { fg = "#F05454" })
            vim.api.nvim_set_hl(0, "DashboardDesc", { fg = "#D4F5F5" })
            vim.api.nvim_set_hl(0, "DashboardKey", { fg = "#F05454" })
            vim.api.nvim_set_hl(0, "DashboardIcon", { fg = "#999999" })

            -- open dashboard after closing lazy
            if vim.o.filetype == "lazy" then
                vim.api.nvim_create_autocmd("WinClosed", {
                    pattern = tostring(vim.api.nvim_get_current_win()),
                    once = true,
                    callback = function()
                        vim.schedule(function()
                            vim.api.nvim_exec_autocmds("UIEnter", { group = "dashboard" })
                        end)
                    end,
                })
            end

            return opts
        end,
    },

    {
        "lukas-reineke/indent-blankline.nvim",
        event = "BufReadPre",
        main = "ibl",
        opts = {
            indent = { char = "│" },
            scope = {
                enabled = true,
                show_start = false,
                show_end = false,
                include = {
                    node_type = {
                        ["*"] = { "*" },
                    },
                },
            },
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
                },
            },
        },
        config = function(_, opts)
            require("ibl").setup(opts)
        end,
    },

    {
        "luukvbaal/statuscol.nvim",
        event = "BufReadPre",
        config = function(_, _)
            local builtin = require "statuscol.builtin"
            local opts = {
                relculright = true,
                segments = {
                    -- { sign = { namespace = { "diagnostic" } } },
                    -- { text = { "%=", get_lnum, " " } },
                    -- { text = { "%C" }, click = "v:lua.ScFa" },
                    { text = { builtin.lnumfunc }, click = "v:lua.ScLa" },
                    { sign = { namespace = { "gitsigns" }, maxwidth = 1, colwidth = 1 } },
                },
            }
            require("statuscol").setup(opts)
        end,
    },

    {
        "akinsho/bufferline.nvim",
        event = "BufReadPre",
        opts = {
            options = {
                numbers = function(opts)
                    return string.format("%s·%s", opts.raise(opts.id), opts.lower(opts.ordinal))
                end,
                offsets = {
                    {
                        filetype = "neo-tree",
                        text = "",
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
        "NvChad/nvim-colorizer.lua",
        enabled = false,
        event = "BufReadPre",
        opts = {
            user_default_options = { names = false },
            buftypes = { "*", "!alpha", "!mason", "!lazy", "!dashboard" },
        },
        config = true,
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
                    hex_color = hipatterns.gen_highlighter.hex_color(),
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
