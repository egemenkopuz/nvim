return {
    {
        "neovim/nvim-lspconfig",
        event = "BufReadPre",
        dependencies = {
            "mason.nvim",
            "williamboman/mason-lspconfig.nvim",
            "b0o/schemastore.nvim",
            "p00f/clangd_extensions.nvim",
            {
                "folke/lazydev.nvim",
                ft = "lua",
                opts = {
                    library = {
                        { path = "luvit-meta/library", words = { "vim%.uv" } },
                    },
                },
            },
            {
                "saecki/crates.nvim",
                event = { "BufRead Cargo.toml" },
                tag = "stable",
                opts = {
                    lsp = {
                        enabled = true,
                        actions = true,
                        completion = true,
                        hover = true,
                    },
                    completion = { cmp = { enabled = false } },
                },
                config = function(_, opts)
                    require("crates").setup(opts)
                end,
            },
        },
        opts = {
            diagnostics = require("user.config").diagnostics,
            servers = {
                ["bashls"] = {},
                ["dockerls"] = {},
                ["jsonls"] = {
                    settings = {
                        json = {
                            format = { enable = true },
                            validate = { enable = true },
                        },
                    },
                },
                ["yamlls"] = {
                    capabilities = {
                        textDocument = {
                            foldingRange = {
                                dynamicRegistration = false,
                                lineFoldingOnly = true,
                            },
                        },
                    },
                    settings = {
                        redhat = { telemetry = { enabled = false } },
                        yaml = {
                            keyOrdering = false,
                            format = { enable = true },
                            validate = true,
                            schemaStore = { enable = false, url = "" },
                        },
                    },
                },
                ["marksman"] = {},
                ["eslint"] = {},
                ["ansiblels"] = {},
                ["terraformls"] = {},
                ["rust_analyzer"] = {
                    cargo = {
                        allFeatures = true,
                        loadOutDirsFromCheck = true,
                        buildScripts = { enable = true },
                    },
                    diagnostics = {
                        enable = true,
                        -- experimental = { enable = true },
                    },
                    checkOnSave = true,
                    procMacro = {
                        enable = true,
                        ignored = {
                            ["async-trait"] = { "async_trait" },
                            ["napi-derive"] = { "napi" },
                            ["async-recursion"] = { "async_recursion" },
                        },
                    },
                    files = {
                        excludeDirs = {
                            ".direnv",
                            ".git",
                            ".github",
                            ".gitlab",
                            "bin",
                            "node_modules",
                            "target",
                            "venv",
                            ".venv",
                        },
                    },
                },
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
                ["basedpyright"] = {
                    settings = {
                        basedpyright = {
                            disableOrganizeImports = true,
                            analysis = {
                                typeCheckingMode = "recommended",
                                diagnosticMode = "openFilesOnly",
                                inlayHints = {
                                    callArgumentNames = "all",
                                    functionReturnTypes = true,
                                    pytestParameters = true,
                                    variableTypes = true,
                                    genericTypes = true,
                                    useTypingExtensions = true,
                                },
                            },
                            linting = { enabled = false },
                        },
                    },
                },
                ["ruff"] = {},
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
            require("mason-lspconfig").setup {
                automatic_installation = true,
                ensure_installed = vim.tbl_keys(servers),
                handlers = {
                    function(server_name)
                        local server = servers[server_name] or {}

                        server.flags = { debounce_text_changes = 150 }
                        server.on_attach = utils.lsp_on_attach()

                        -- stylua: ignore
                        server.capabilities = require("blink.cmp").get_lsp_capabilities()
                        server.capabilities.textDocument.foldingRange = {
                            dynamicRegistration = false,
                            lineFoldingOnly = true,
                        }
                        server.before_init = function(_, config)
                            if server_name == "pyright" then
                                config.settings.python.pythonPath =
                                    utils.get_python_path(config.root_dir)
                            end
                        end

                        if server_name == "jsonls" then
                            server.settings.json.schemas = require("schemastore").json.schemas()
                        elseif server_name == "yamlls" then
                            server.settings.yaml.schemas = require("schemastore").json.schemas()
                        elseif server_name == "clangd" then
                            server.capabilities.offsetEncoding = "utf-16"
                            require("clangd_extensions").setup {
                                ast = require("user.icons").clangd,
                            }
                        end

                        lspconfig[server_name].setup(server)
                    end,
                },
            }
        end,
    },

    {
        "williamboman/mason.nvim",
        cmd = "Mason",
        opts = {
            ensure_installed = require("user.config").mason_packages,
            ui = { border = require("user.config").borders },
        },
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

    {
        "linux-cultist/venv-selector.nvim",
        dependencies = {
            "neovim/nvim-lspconfig",
            "mfussenegger/nvim-dap-python",
        },
        branch = "regexp",
        ft = "python",
        cmd = { "VenvSelect" },
        opts = { picker = "native" },
        init = function()
            require("user.utils").load_keymap "venv"
        end,
        config = function(_, opts)
            require("venv-selector").setup(opts)
        end,
    },
}
