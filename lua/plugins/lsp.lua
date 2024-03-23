return {
    {
        "neovim/nvim-lspconfig",
        event = "BufReadPre",
        dependencies = {
            "mason.nvim",
            "williamboman/mason-lspconfig.nvim",
            "hrsh7th/cmp-nvim-lsp",
            "b0o/schemastore.nvim",
            -- "hinell/lsp-timeout.nvim",
            "p00f/clangd_extensions.nvim",
            -- "simrat39/rust-tools.nvim",
            -- {
            --     "saecki/crates.nvim",
            --     opts = { null_ls = { enabled = true, name = "crates.nvim" } },
            --     config = function(_, opts)
            --         vim.api.nvim_create_autocmd("BufRead", {
            --             group = vim.api.nvim_create_augroup("CmpSourceCargo", { clear = true }),
            --             pattern = "Cargo.toml",
            --             callback = function()
            --                 require("cmp").setup.buffer { sources = { { name = "crates" } } }
            --             end,
            --         })
            --         require("crates").setup(opts)
            --     end,
            -- },
            { "folke/neodev.nvim", opts = { experimental = { pathStrict = true } } },
            {
                "ray-x/lsp_signature.nvim",
                opts = {
                    hint_enable = false,
                    hint_prefix = "",
                    fixpos = true,
                    padding = " ",
                    bind = true,
                    noice = true,
                    handler_opts = { border = "single" },
                },
            },
            {
                "RRethy/vim-illuminate",
                opts = {
                    delay = 200,
                    providers = { "lsp", "treesitter", "regex" },
                    filetypes_denylist = { "neo-tree", "dirvish", "fugitive", "lazy", "mason" },
                },
                config = function(_, opts)
                    require("illuminate").configure(opts)
                    vim.api.nvim_create_autocmd("FileType", {
                        callback = function()
                            local buffer = vim.api.nvim_get_current_buf()
                            pcall(vim.keymap.del, "n", "]]", { buffer = buffer })
                            pcall(vim.keymap.del, "n", "[[", { buffer = buffer })
                        end,
                    })
                    require("user.utils").load_keymap "illuminate"
                end,
            },
        },
        opts = {
            diagnostics = require("user.config").diagnostics,
            servers = {
                ["bashls"] = {},
                ["dockerls"] = {},
                ["jsonls"] = {},
                ["yamlls"] = {},
                ["marksman"] = {},
                ["eslint"] = {},
                ["clangd"] = {
                    cmd = {
                        "clangd",
                        "--background-index",
                        "--clang-tidy",
                        "--completion-style=detailed",
                        -- "--completion-parse=always",
                        -- "--cross-file-rename",
                        "--header-insertion=iwyu",
                        "--suggest-missing-includes",
                        "--function-arg-placeholders",
                        "--fallback-style=llvm",
                        -- "-j=4", -- number of workers
                    },
                    init_options = {
                        usePlaceholders = true,
                        completeUnimported = true,
                        clangdFileStatus = true,
                    },
                    root_dir = function(fname)
                        return require("lspconfig.util").root_pattern(
                            "Makefile",
                            "configure.ac",
                            "configure.in",
                            "config.h.in",
                            "meson.build",
                            "meson_options.txt",
                            "build.ninja"
                        )(fname) or require("lspconfig.util").root_pattern(
                            "compile_commands.json",
                            "compile_flags.txt"
                        )(fname) or require("lspconfig.util").find_git_ancestor(
                            fname
                        )
                    end,
                },
                ["pyright"] = {
                    settings = {
                        pyright = { autoImportCompletion = true },
                        python = {
                            analysis = {
                                autoSearchPaths = true,
                                diagnosticMode = "workspace",
                                useLibraryCodeForTypes = true,
                                typeCheckingMode = "off",
                            },
                        },
                    },
                },
                ["cmake"] = {},
                ["lua_ls"] = {
                    settings = {
                        Lua = {
                            runtime = { version = "LuaJIT" },
                            format = { enable = false },
                            telemetry = { enable = false },
                            workspace = {
                                checkThirdParty = false,
                                maxPreload = 100000,
                                preloadFileSize = 10000,
                            },
                        },
                    },
                },
            },
        },
        config = function(_, opts)
            local lspconfig = require "lspconfig"
            local utils = require "user.utils"
            local servers = opts.servers

            vim.diagnostic.config(opts.diagnostics)

            require("mason-lspconfig").setup { ensure_installed = vim.tbl_keys(servers) }
            require("mason-lspconfig").setup_handlers {
                function(server)
                    local server_opts = servers[server] or {}

                    server_opts.flags = { debounce_text_changes = 150 }
                    server_opts.on_attach = utils.lsp_on_attach()
                    server_opts.capabilities = utils.lsp_capabilities()

                    if server == "lua_ls" then
                        require("neodev").setup {}
                    end

                    server_opts.before_init = function(_, config)
                        if server == "pyright" then
                            config.settings.python.pythonPath =
                                utils.get_python_path(config.root_dir)
                        end
                    end

                    if server == "jsonls" then
                        server_opts.settings = {
                            json = {
                                schemas = require("schemastore").json.schemas(),
                                validate = { enable = true },
                            },
                        }
                    elseif server == "yamlls" then
                        server_opts.settings = {
                            yaml = {
                                schemas = require("schemastore").json.schemas {
                                    select = { "docker-compose.yml" },
                                },
                            },
                        }
                    elseif server == "clangd" then
                        server_opts.capabilities.offsetEncoding = "utf-16"
                        require("clangd_extensions").setup {
                            -- server = server_opts,
                            ast = {
                                role_icons = {
                                    type = "",
                                    declaration = "",
                                    expression = "",
                                    specifier = "",
                                    statement = "",
                                    ["template argument"] = "",
                                },
                                kind_icons = {
                                    Compound = "",
                                    Recovery = "",
                                    TranslationUnit = "",
                                    PackExpansion = "",
                                    TemplateTypeParm = "",
                                    TemplateTemplateParm = "",
                                    TemplateParamObject = "",
                                },
                            },
                        }
                    end

                    lspconfig[server].setup(server_opts)
                end,
            }
        end,
    },

    {
        "nvimtools/none-ls.nvim",
        event = "BufReadPre",
        dependencies = { "mason.nvim" },
        config = function()
            local nls = require "null-ls"
            local utils = require "user.utils"
            local packages = require("user.config").nulls_packages
            local sources = {}

            for t_pkg, pkgs in pairs(packages) do
                for _, pckg in ipairs(pkgs) do
                    if type(pckg) == "table" then
                        table.insert(sources, nls.builtins[t_pkg][pckg[1]].with { pckg[2] })
                    else
                        table.insert(sources, nls.builtins[t_pkg][pckg])
                    end
                end
            end

            nls.setup { sources = sources, on_attach = utils.formatting() }
        end,
    },

    {
        "williamboman/mason.nvim",
        cmd = "Mason",
        opts = { ensure_installed = require("user.config").mason_packages },
        config = function(_, opts)
            require("mason").setup(opts)
            local mr = require "mason-registry"
            for _, tool in ipairs(opts.ensure_installed) do
                local p = mr.get_package(tool)
                if not p:is_installed() then
                    p:install()
                end
            end
        end,
    },
}
