return {
    {
        "saghen/blink.cmp",
        branch = "main",
        build = "cargo build --release",
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
            local config = require "user.config"

            local kind_icons = vim.deepcopy(require("user.icons").kinds)
            for k, v in pairs(kind_icons) do
                kind_icons[k] = string.sub(v, 1, -2)
            end

            local opts = {
                keymap = {
                    preset = "default",
                    ["<C-e>"] = {},
                    ["<C-g>"] = { vim.g.accept_ai_suggestion },
                    ["<C-space>"] = { "show", "hide" },
                },
                completion = {
                    accept = { auto_brackets = { enabled = true } },
                    menu = {
                        winblend = vim.o.pumblend,
                        scrollbar = false,
                        border = config.borders,
                    },
                    documentation = {
                        auto_show = true,
                        auto_show_delay_ms = 200,
                        window = {
                            min_width = 10,
                            max_width = 75,
                            max_height = 30,
                            scrollbar = true,
                            border = config.borders,
                        },
                    },
                    ghost_text = { enabled = false },
                },
                signature = {
                    enabled = true,
                    window = {
                        min_width = 1,
                        max_width = 100,
                        max_height = 10,
                        scrolbar = false,
                        border = config.borders,
                    },
                },
                sources = {
                    providers = {
                        lsp = { fallback_for = { "lazydev" } },
                        lazydev = { name = "LazyDev", module = "lazydev.integrations.blink" },
                        copilot = {
                            name = "copilot",
                            module = "blink-cmp-copilot",
                        },
                    },
                    completion = {
                        enabled_providers = {
                            "lsp",
                            "path",
                            "copilot",
                            "snippets",
                            "buffer",
                            "lazydev",
                        },
                    },
                },
                appearance = {
                    use_nvim_cmp_as_default = true,
                    nerd_font_variant = "mono",
                    kind_icons = kind_icons,
                },
            }
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
