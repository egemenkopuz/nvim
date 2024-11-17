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
                    null_ls = { enabled = true, name = "crates.nvim" },
                },
                config = function(_, opts)
                    require("crates").setup(opts)
                end,
            },
            {
                "RRethy/vim-illuminate",
                opts = {
                    delay = 200,
                    providers = { "lsp", "treesitter", "regex" },
                    filetypes_denylist = {
                        "neo-tree",
                        "notify",
                        "dirvish",
                        "fugitive",
                        "lazy",
                        "mason",
                        "Outline",
                        "no-neck-pain",
                        "undotree",
                        "diff",
                        "Glance",
                        "trouble",
                        "copilot-chat",
                    },
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
                ["ansiblels"] = {},
                ["rust_analyzer"] = {
                    cargo = {
                        allFeatures = true,
                        loadOutDirsFromCheck = true,
                        buildScripts = { enable = true },
                    },
                    diagnostics = {
                        enable = true,
                        experimental = { enable = true },
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
                        disableOrganizeImports = true,
                        basedpyright = {
                            analysis = {
                                -- ignore = { "*" },
                                typeCheckingMode = "basic",
                                inlayHints = {
                                    callArgumentNames = "all",
                                    functionReturnTypes = true,
                                    pytestParameters = true,
                                    variableTypes = true,
                                },
                            },
                            linting = { enabled = false },
                        },
                    },
                },
                ["ruff"] = {
                    -- settings = { args = { "--ignore=F821", "--config=$ROOT/pyproject.toml" } },
                    -- settings = { args = { "--ignore=F821" } },
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
            require("mason-lspconfig").setup {
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
                            server.settings = {
                                json = {
                                    schemas = require("schemastore").json.schemas(),
                                    validate = { enable = true },
                                },
                            }
                        elseif server_name == "yamlls" then
                            server.settings = {
                                yaml = {
                                    schemas = require("schemastore").json.schemas {
                                        select = { "docker-compose.yml" },
                                    },
                                },
                            }
                        elseif server_name == "clangd" then
                            server.capabilities.offsetEncoding = "utf-16"
                            require("clangd_extensions").setup {
                                ast = require("user.config").icons.clangd,
                            }
                        end

                        lspconfig[server_name].setup(server)
                    end,
                },
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
        opts = {
            ensure_installed = require("user.config").mason_packages,
            ui = { border = "single" },
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
            "nvim-telescope/telescope.nvim",
            "mfussenegger/nvim-dap-python",
        },
        branch = "regexp",
        ft = "python",
        cmd = { "VenvSelect" },
        init = function()
            require("user.utils").load_keymap "venv"
        end,
        config = function(_, opts)
            require("venv-selector").setup(opts)
        end,
    },
}
