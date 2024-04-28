return {
    {
        "nvim-treesitter/nvim-treesitter",
        version = false,
        build = ":TSUpdate",
        event = { "BufReadPost", "BufNewFile" },
        dependencies = {
            "windwp/nvim-ts-autotag",
            {
                "nvim-treesitter/nvim-treesitter-context",
                opts = { mode = "cursor", max_lines = 4 },
            },
            "windwp/nvim-autopairs",
            "JoosepAlviste/nvim-ts-context-commentstring",
            {
                "nvim-treesitter/nvim-treesitter-textobjects",
                config = function()
                    -- When in diff mode, we want to use the default
                    -- vim text objects c & C instead of the treesitter ones.
                    local move = require "nvim-treesitter.textobjects.move" ---@type table<string,fun(...)>
                    local configs = require "nvim-treesitter.configs"

                    for name, fn in pairs(move) do
                        if name:find "goto" == 1 then
                            move[name] = function(q, ...)
                                if vim.wo.diff then
                                    local config = configs.get_module("textobjects.move")[name] ---@type table<string,string>
                                    for key, query in pairs(config or {}) do
                                        if q == query and key:find "[%]%[][cC]" then
                                            vim.cmd("normal! " .. key)
                                            return
                                        end
                                    end
                                end
                                return fn(q, ...)
                            end
                        end
                    end
                end,
            },
        },
        init = function(plugin)
            require("lazy.core.loader").add_to_rtp(plugin)
            require "nvim-treesitter.query_predicates"
        end,
        opts = function()
            local MAX_FILE_LINES = 3000
            local MAX_FILE_SIZE = 1048576 -- 1MB

            return {
                sync_install = false,
                autotag = { enable = true },
                indent = { enable = true },
                ensure_installed = require("user.config").treesitter_packages,
                highlight = {
                    enable = true,
                    additional_vim_regex_highlighting = false,
                    max_file_lines = MAX_FILE_LINES,
                    disable = function(_, bufnr)
                        local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(bufnr))
                        if ok and stats and stats.size > MAX_FILE_SIZE then
                            return true
                        end
                    end,
                },
                incremental_selection = {
                    enable = true,
                    keymaps = {
                        init_selection = "<C-space>",
                        node_incremental = "<C-space>",
                        scope_incremental = false,
                        node_decremental = "<bs>",
                    },
                },
                textobjects = {
                    move = {
                        enable = true,
                        goto_next_start = { ["]f"] = "@function.outer", ["]c"] = "@class.outer" },
                        goto_next_end = { ["]F"] = "@function.outer", ["]C"] = "@class.outer" },
                        goto_previous_start = {
                            ["[f"] = "@function.outer",
                            ["[c"] = "@class.outer",
                        },
                        goto_previous_end = { ["[F"] = "@function.outer", ["[C"] = "@class.outer" },
                    },
                },
            }
        end,
        config = function(_, opts)
            require("nvim-treesitter.configs").setup(opts)
            require("treesitter-context").setup()
            require("ts_context_commentstring").setup { enable_autocmd = false }

            vim.api.nvim_set_hl(0, "TreesitterContext", { bg = "none" })
            vim.api.nvim_set_hl(0, "TreesitterContextLineNumberBottom", { underline = true })

            local autopairs = require "nvim-autopairs"
            local cmp_autopairs = require "nvim-autopairs.completion.cmp"
            autopairs.setup { disable_filetype = { "TelescopePrompt", "vim" } }
            require("cmp").event:on("confirm_done", cmp_autopairs.on_confirm_done())

            require("user.utils").load_keymap "treesitter_context"
        end,
    },

    {
        "echasnovski/mini.ai",
        event = "BufReadPre",
        dependencies = { "nvim-treesitter/nvim-treesitter-textobjects" },
        init = function()
            -- no need to load the plugin, since we only need its queries
            require("lazy.core.loader").disable_rtp_plugin "nvim-treesitter-textobjects"
        end,
        opts = function()
            local ai = require "mini.ai"
            return {
                n_lines = 500,
                custom_textobjects = {
                    o = ai.gen_spec.treesitter({
                        a = { "@block.outer", "@conditional.outer", "@loop.outer" },
                        i = { "@block.inner", "@conditional.inner", "@loop.inner" },
                    }, {}),
                    f = ai.gen_spec.treesitter(
                        { a = "@function.outer", i = "@function.inner" },
                        {}
                    ),
                    c = ai.gen_spec.treesitter({ a = "@class.outer", i = "@class.inner" }, {}),
                    t = { "<([%p%w]-)%f[^<%w][^<>]->.-</%1>", "^<.->().*()</[^/]->$" },
                    d = { "%f[%d]%d+" }, -- digits
                    e = { -- Word with case
                        {
                            "%u[%l%d]+%f[^%l%d]",
                            "%f[%S][%l%d]+%f[^%l%d]",
                            "%f[%P][%l%d]+%f[^%l%d]",
                            "^[%l%d]+%f[^%l%d]",
                        },

                        "^().*()$",
                    },
                    g = function() -- Whole buffer, similar to `gg` and 'G' motion
                        local from = { line = 1, col = 1 }
                        local to = {
                            line = vim.fn.line "$",
                            col = math.max(vim.fn.getline("$"):len(), 1),
                        }

                        return { from = from, to = to }
                    end,
                    u = ai.gen_spec.function_call(), -- u for "Usage"
                    U = ai.gen_spec.function_call { name_pattern = "[%w_]" }, -- without dot in function name
                },
            }
        end,
        config = function(_, opts)
            require("mini.ai").setup(opts)
            local i = {
                [" "] = "Whitespace",
                ['"'] = 'Balanced "',
                ["'"] = "Balanced '",
                ["`"] = "Balanced `",
                ["("] = "Balanced (",
                [")"] = "Balanced ) including white-space",
                [">"] = "Balanced > including white-space",
                ["<lt>"] = "Balanced <",
                ["]"] = "Balanced ] including white-space",
                ["["] = "Balanced [",
                ["}"] = "Balanced } including white-space",
                ["{"] = "Balanced {",
                ["?"] = "User Prompt",
                _ = "Underscore",
                a = "Argument",
                b = "Balanced ), ], }",
                c = "Class",
                d = "Digit(s)",
                e = "Word in CamelCase & snake_case",
                f = "Function",
                g = "Entire file",
                o = "Block, conditional, loop",
                q = "Quote `, \", '",
                t = "Tag",
                u = "Use/call function & method",
                U = "Use/call without dot in name",
            }
            local a = vim.deepcopy(i)
            for k, v in pairs(a) do
                a[k] = v:gsub(" including.*", "")
            end

            local ic = vim.deepcopy(i)
            local ac = vim.deepcopy(a)
            for key, name in pairs { n = "Next", l = "Last" } do
                i[key] = vim.tbl_extend("force", { name = "Inside " .. name .. " textobject" }, ic)
                a[key] = vim.tbl_extend("force", { name = "Around " .. name .. " textobject" }, ac)
            end
            require("which-key").register { mode = { "o", "x" }, i = i, a = a }
        end,
    },

    {
        "echasnovski/mini.surround",
        event = "BufReadPre",
        opts = {
            search_method = "cover",
            highlight_duration = 500,
            mappings = {
                add = "gsa", -- Add surrounding in Normal and Visual modes
                delete = "gsd", -- Delete surrounding
                find = "gsf", -- Find surrounding (to the right)
                find_left = "gsF", -- Find surrounding (to the left)
                highlight = "gsh", -- Highlight surrounding
                replace = "gsr", -- Replace surrounding
                update_n_lines = "gsn", -- Update `n_lines`
            },
        },
        config = function(_, opts)
            require("mini.surround").setup(opts)
        end,
    },

    {
        "echasnovski/mini.comment",
        event = "BufReadPre",
        dependencies = { "JoosepAlviste/nvim-ts-context-commentstring" },
        config = function()
            require("mini.comment").setup {
                options = {
                    custom_commentstring = function()
                        return require("ts_context_commentstring").calculate_commentstring()
                            or vim.bo.commentstring
                    end,
                },
            }
        end,
    },

    {
        "nmac427/guess-indent.nvim",
        event = "BufReadPre",
        opts = {
            filetype_exclude = {
                "netrw",
                "tutor",
                "alpha",
                "mason",
                "lazy",
                "log",
                "gitcommmit",
                "TelescopePrompt",
                "neo-tree",
                "neo-tree-popup",
                "notify",
                "no-neck-pain",
                "Outline",
                "undotree",
            },
        },
        config = function(_, opts)
            require("guess-indent").setup(opts)
        end,
    },
}
