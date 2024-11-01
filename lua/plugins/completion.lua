return {
    {
        "hrsh7th/nvim-cmp",
        version = false,
        event = "InsertEnter",
        dependencies = {
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",
            {
                "L3MON4D3/LuaSnip",
                dependencies = {
                    "rafamadriz/friendly-snippets",
                    config = function()
                        require("luasnip.loaders.from_vscode").lazy_load()
                    end,
                },
                opts = { history = true, delete_check_events = "TextChanged" },
                -- stylua: ignore
                keys = {
                    { "<tab>", function() return require("luasnip").jumpable(1) and "<Plug>luasnip-jump-next" or "<tab>" end, expr = true, silent = true, mode = "i", },
                    { "<tab>", function() require("luasnip").jump(1) end, mode = "s", },
                    { "<s-tab>", function() require("luasnip").jump(-1) end, mode = { "i", "s" }, },
                },
            },
            "saadparwaiz1/cmp_luasnip",
            "zbirenbaum/copilot-cmp",
        },
        opts = function()
            local cmp = require "cmp"
            return {
                window = {
                    completion = cmp.config.window.bordered {
                        scrollbar = false,
                        border = { "┌", "─", "┐", "│", "┘", "─", "└", "│" },
                    },
                    documentation = cmp.config.window.bordered {
                        scrollbar = false,
                        border = { "┌", "─", "┐", "│", "┘", "─", "└", "│" },
                    },
                },
                completion = { completeopt = "menu,menuone,noinsert" },
                snippet = {
                    expand = function(args)
                        require("luasnip").lsp_expand(args.body)
                    end,
                },
                mapping = cmp.mapping.preset.insert {
                    ["<C-d>"] = cmp.mapping.scroll_docs(4),
                    ["<C-u>"] = cmp.mapping.scroll_docs(-4),
                    ["<C-e>"] = cmp.mapping.abort(),
                    ["<C-y>"] = cmp.mapping.confirm { select = true },
                    ["<S-CR>"] = cmp.mapping.confirm {
                        behavior = cmp.ConfirmBehavior.Replace,
                        select = true,
                    },
                    ["<C-n>"] = cmp.mapping.select_next_item { behavior = cmp.SelectBehavior.Insert },
                    ["<C-p>"] = cmp.mapping.select_prev_item { behavior = cmp.SelectBehavior.Insert },
                    ["<C-CR>"] = function(fallback)
                        cmp.abort()
                        fallback()
                    end,
                },
                sources = cmp.config.sources {
                    { name = "copilot", group_index = 0 },
                    { name = "nvim_lsp", max_item_count = 20, group_index = 0 },
                    { name = "buffer", max_item_count = 20, group_index = 0 },
                    { name = "nvim_lua", max_item_count = 20, group_index = 0 },
                    { name = "luasnip", group_index = 1 },
                    { name = "path", group_index = 1 },
                    { name = "lazydev", group_index = 1 },
                },
                formatting = {
                    format = function(_, item)
                        local icons = require("user.config").icons.kinds
                        if icons[item.kind] then
                            item.kind = icons[item.kind] .. item.kind
                        end
                        return item
                    end,
                },
                formatters = { insert_text = require("copilot_cmp.format").remove_existing },
                sorting = {
                    priority_weight = 2,
                    comparators = {
                        require("copilot_cmp.comparators").prioritize,
                        require("copilot_cmp.comparators").score,
                        cmp.config.compare.offset,
                        cmp.config.compare.exact,
                        cmp.config.compare.score,
                        cmp.config.compare.recently_used,
                        cmp.config.compare.locality,
                        cmp.config.compare.kind,
                        cmp.config.compare.sort_text,
                        cmp.config.compare.length,
                        cmp.config.compare.order,
                    },
                },
                experimental = { ghost_text = { hl_group = "LspCodeLens" } },
            }
        end,
    },
    {
        "zbirenbaum/copilot-cmp",
        event = "InsertEnter",
        dependencies = {
            "zbirenbaum/copilot.lua",
            opts = {
                suggestion = { enabled = false },
                panel = { enabled = false },
                filetypes = { markdown = true },
            },
        },
        opts = { method = "getCompletionsCycling" },
        config = function(_, opts)
            require("copilot_cmp").setup(opts)
        end,
    },
}
