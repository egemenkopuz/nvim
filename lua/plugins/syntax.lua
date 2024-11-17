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
            "JoosepAlviste/nvim-ts-context-commentstring",
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
                incremental_selection = { enable = false },
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
            require("nvim-ts-autotag").setup()
            require("nvim-treesitter.configs").setup(opts)
            require("treesitter-context").setup()
            require("ts_context_commentstring").setup { enable_autocmd = false }

            vim.api.nvim_set_hl(0, "TreesitterContext", { bg = "none" })
            vim.api.nvim_set_hl(0, "TreesitterContextLineNumberBottom", { underline = true })

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
            local objects = {
                { " ", desc = "whitespace" },
                { '"', desc = 'balanced "' },
                { "'", desc = "balanced '" },
                { "(", desc = "balanced (" },
                { ")", desc = "balanced ) including white-space" },
                { "<", desc = "balanced <" },
                { ">", desc = "balanced > including white-space" },
                { "?", desc = "user prompt" },
                { "U", desc = "use/call without dot in name" },
                { "[", desc = "balanced [" },
                { "]", desc = "balanced ] including white-space" },
                { "_", desc = "underscore" },
                { "`", desc = "balanced `" },
                { "a", desc = "argument" },
                { "b", desc = "balanced )]}" },
                { "c", desc = "class" },
                { "d", desc = "digit(s)" },
                { "e", desc = "word in CamelCase & snake_case" },
                { "f", desc = "function" },
                { "g", desc = "entire file" },
                { "i", desc = "indent" },
                { "o", desc = "block, conditional, loop" },
                { "q", desc = "quote `\"'" },
                { "t", desc = "tag" },
                { "u", desc = "use/call function & method" },
                { "{", desc = "balanced {" },
                { "}", desc = "balanced } including white-space" },
            }
            local ret = { mode = { "o", "x" } }
            for prefix, name in pairs {
                i = "inside",
                a = "around",
                il = "last",
                ["in"] = "next",
                al = "last",
                an = "next",
            } do
                ret[#ret + 1] = { prefix, group = name }
                for _, obj in ipairs(objects) do
                    ret[#ret + 1] = { prefix .. obj[1], desc = obj.desc }
                end
            end
            require("which-key").add(ret, { notify = false })
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
                find = "", -- Find surrounding (to the right)
                find_left = "", -- Find surrounding (to the left)
                highlight = "", -- Highlight surrounding
                replace = "gsr", -- Replace surrounding
                update_n_lines = "", -- Update `n_lines`
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
        "echasnovski/mini.pairs",
        event = "VeryLazy",
        opts = {
            modes = { insert = true, command = true, terminal = false },
            -- skip autopair when next character is one of these
            skip_next = [=[[%w%%%'%[%"%.%`%$]]=],
            -- skip autopair when the cursor is inside these treesitter nodes
            skip_ts = { "string" },
            -- skip autopair when next character is closing pair
            -- and there are more closing pairs than opening pairs
            skip_unbalanced = true,
            -- better deal with markdown code blocks
            markdown = true,
        },
        config = function(_, opts)
            require("mini.pairs").setup(opts)
        end,
    },
}
