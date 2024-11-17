return {
    {
        "saghen/blink.cmp",
        version = "v0.*",
        opts_extend = {
            "sources.completion.enabled_providers",
            "sources.compat",
        },
        dependencies = {
            "rafamadriz/friendly-snippets",
            { "giuxtaposition/blink-cmp-copilot", dependencies = "zbirenbaum/copilot.lua" },
        },
        lazy = false,
        opts = function()
            local kind_icons = require("user.config").icons.kinds
            local opts = {
                keymap = {
                    preset = "default",
                    ["<C-space>"] = {},
                    ["<C-g>"] = { "show", "show_documentation", "hide_documentation" },
                },
                highlight = { use_nvim_cmp_as_default = true },
                nerd_font_variant = "mono",
                trigger = { signature_help = { enabled = true } },
                sources = {
                    lsp = { fallback_for = { "lazydev" } },
                    lazydev = {
                        name = "LazyDev",
                        module = "lazydev.integrations.blink",
                    },
                    providers = {
                        copilot = {
                            name = "copilot",
                            module = "blink-cmp-copilot",
                        },
                    },
                    compat = {},
                    completion = {
                        enabled_providers = {
                            "lsp",
                            "path",
                            "copilot",
                            "snippets",
                            "buffer",
                        },
                    },
                },
                windows = {
                    autocomplete = {
                        -- draw = "reversed",
                        winblend = vim.o.pumblend,
                        border = { "┌", "─", "┐", "│", "┘", "─", "└", "│" },
                    },
                    documentation = {
                        min_width = 10,
                        max_width = 75,
                        max_height = 30,
                        scrollbar = true,
                        auto_show = true,
                        auto_show_delay_ms = 200,
                        border = { "┌", "─", "┐", "│", "┘", "─", "└", "│" },
                        treesitter_highlighting = true,
                    },
                    signature_help = {
                        min_width = 1,
                        max_width = 100,
                        max_height = 10,
                        border = { "┌", "─", "┐", "│", "┘", "─", "└", "│" },
                        treesitter_highlighting = true,
                    },
                    ghost_text = { enabled = true },
                },
                kind_icons = {},
            }
            opts.kind_icons = vim.tbl_deep_extend("force", opts.kind_icons, kind_icons)
            return opts
        end,
        config = function(_, opts)
            -- setup compat sources
            local enabled = opts.sources.completion.enabled_providers
            for _, source in ipairs(opts.sources.compat or {}) do
                opts.sources.providers[source] = vim.tbl_deep_extend(
                    "force",
                    { name = source, module = "blink.compat.source" },
                    opts.sources.providers[source] or {}
                )
                if type(enabled) == "table" and not vim.tbl_contains(enabled, source) then
                    table.insert(enabled, source)
                end
            end
            require("blink.cmp").setup(opts)
        end,
    },
}
