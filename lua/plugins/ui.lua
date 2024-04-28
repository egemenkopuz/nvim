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
                inc_rename = true,
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
        dependencies = { "arkav/lualine-lsp-progress" },
        opts = function()
            local icons = require("user.config").icons
            local utils = require "user.utils"

            local diff_color = {
                added = { fg = "#78a5a3" },
                modified = { fg = "#e1b16a" },
                removed = { fg = "#ce5a57" },
            }
            local diagnostics_color = {
                error = { fg = "#ce5a57" },
                warn = { fg = "#e1b16a" },
                info = { fg = "#78a5a3" },
                hint = { fg = "#82a0aa" },
            }
            if require("user.config").transparent then
                diff_color = {
                    added = { fg = "#78a5a3", bg = "none" },
                    modified = { fg = "#e1b16a", bg = "none" },
                    removed = { fg = "#ce5a57", bg = "none" },
                }
                diagnostics_color = {
                    error = { fg = "#ce5a57", bg = "none" },
                    warn = { fg = "#e1b16a", bg = "none" },
                    info = { fg = "#78a5a3", bg = "none" },
                    hint = { fg = "#82a0aa", bg = "none" },
                }
            end

            return {
                options = {
                    theme = "auto",
                    component_separators = { left = "", right = "" },
                    section_separators = { left = "", right = "" },
                    globalstatus = true,
                    disabled_filetypes = { statusline = { "alpha", "packer", "lazy", "terminal" } },
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
                dashboard.button("c c", " " .. " Nvim config", ":e $MYVIMRC | :cd %:p:h <CR>"),
                dashboard.button("c f", " " .. " Global config", ":e $HOME/.config | :cd %:p:h <CR>"),
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
            vim.api.nvim_create_autocmd("BufAdd", {
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
        event = "BufReadPre",
        opts = {
            user_default_options = { names = false },
            buftypes = { "*", "!alpha", "!mason", "!lazy" },
        },
        config = true,
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
            timeout = 3000,
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
            stages = "fade",
        },
        init = function()
            vim.notify = require "notify"
            require("user.utils").load_keymap "notify"
        end,
    },

    {
        "folke/todo-comments.nvim",
        cmd = { "TodoTrouble", "TodoTelescope" },
        event = "BufReadPre",
        init = function()
            require("user.utils").load_keymap "todo_comments"
        end,
        config = function()
            require("todo-comments").setup()
        end,
    },
}
