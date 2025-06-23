local M = {}

local icons = require "user.icons"

-- configurations that are set via environment variables

vim.g.transparent = vim.env.NVIM_TRANSPARENT == "true"

-- main configurations

M.colorscheme = "ash"
M.logo = icons.dashboard
M.borders = icons.borders.sharp
M.copilot_chat_window_alt_opts = { layout = "vertical", width = 0.5, height = 0.5 }

vim.g.lsp_highlight_cursor_enabled = false
vim.g.lsp_inlay_hints_enabled = true
vim.g.python3_host_prog = "/usr/bin/python3"

M.toggle_settings = {
    autoformat = true,
    colorcolumn = nil,
    diagnostics = true,
    diagnostic_lines = false,
    copilot_chat_window_alt = false,
}

-- auto install treesitter packages
M.treesitter_packages = {
    "bash",
    "c",
    "diff",
    "cmake",
    "cpp",
    "css",
    "dockerfile",
    "html",
    "javascript",
    "json5",
    "jsdoc",
    "jsonc",
    "lua",
    "luadoc",
    "luap",
    "markdown",
    "markdown_inline",
    "python",
    "query",
    "regex",
    "toml",
    "tsx",
    "typescript",
    "xml",
    "vim",
    "vimdoc",
    "yaml",
    "terraform",
    "hcl",
    "rst",
    "ninja",
    "rust",
    "go",
    "ron",
    "requirements",
}

-- auto install mason packages
M.mason_packages = {
    -- bash
    "bash-language-server",
    "shellcheck",
    "shfmt",
    -- lua
    "lua-language-server",
    "stylua",
    -- terraform
    "terraform-ls",
    "tflint",
    "trivy",
    -- cmake
    "cmake-language-server",
    "cmakelang",
    "cmakelint",
    -- python
    "basedpyright",
    "ruff",
    "debugpy",
    "black",
    "isort",
    -- Rust
    "rust-analyzer",
    -- go
    "gopls",
    "gofumpt",
    "goimports",
    "golangci-lint",
    "delve",
    -- cpp
    "clangd",
    "clang-format",
    -- debug
    "codelldb",
    -- docker
    "dockerfile-language-server",
    "docker-compose-language-service",
    "hadolint",
    -- md
    "marksman",
    -- json
    "json-lsp",
    -- yaml
    "yaml-language-server",
    -- js/ts
    "eslint-lsp",
    -- ansible
    "ansible-lint",
    "prettier",
    -- github actions
    "actionlint",
    -- toml
    "taplo",
}

M.linting = {
    linters_by_ft = {
        ansible = { "ansible_lint" },
        dockerfile = { "hadolint" },
        cmake = { "cmakelint" }, -- FIX
        c = { "cppcheck", "clang_tidy" },
        cpp = { "cppcheck", "clang_tidy" },
        ghaction = { "actionlint" },
        terraform = { "tflint", "trivy" },
        terragrunt = { "trivy" },
        bash = { "trivy", "shellcheck", "bash" },
        go = { "golangci_lint" },
    },
}

M.formatting = {
    -- stylua: ignore
    formatters_by_ft = {
        lua = { "stylua" },
        python = { "ruff_format", "ruff_organize_imports" },
        c = { "clang_format", timeout_ms = 500, lsp_format = "prefer" },
        cpp = { "clang_format", timeout_ms = 500, lsp_format = "prefer" },
        cmake = { "cmake_format", timeout_ms = 500, lsp_format = "prefer" },
        rust = { "rustfmt", lsp_format = "fallback" },
        sh = { "shfmt", "shellcheck" },
        markdown = { "prettier", timeout_ms = 500, lsp_format = "prefer" },
        javascript = { "prettier", timeout_ms = 500, lsp_format = "fallback" },
        javascriptreact = { "prettier", timeout_ms = 500, lsp_format = "fallback" },
        json = { "prettier", timeout_ms = 500, lsp_format = "prefer" },
        jsonc = { "prettier", timeout_ms = 500, lsp_format = "prefer" },
        yaml = { "prettier", timeout_ms = 500, lsp_format = "prefer" },
        typescript = { "prettier",timeout_ms = 500, lsp_format = "fallback" },
        typescriptreact = { "prettier", timeout_ms = 500, lsp_format = "fallback" },
        terraform = { "terraform_fmt", timeout_ms = 500, lsp_format = "prefer" },
        hcl = { "terragrunt_hclfmt", timeout_ms = 500, lsp_format = "prefer" },
        toml = { "taplo", timeout_ms = 500, lsp_format = "prefer" },
        go = { "goimports", "gofumpt"}
    },
    formatters = {
        injected = { options = { ignore_errors = true } },
        clang_format = {
            command = "clang-format",
            append_args = function()
                return { "--style={BasedOnStyle: Google, IndentWidth: 4}" }
            end,
        },
    },
}

M.disabled_plugins = {
    "2html_plugin",
    "getscript",
    "getscriptPlugin",
    "gzip",
    "logipat",
    "netrw",
    "netrwPlugin",
    "netrwSettings",
    "netrwFileHandlers",
    "matchit",
    "tar",
    "tarPlugin",
    "rrhelper",
    "spellfile_plugin",
    "vimball",
    "vimballPlugin",
    "zip",
    "zipPlugin",
    "tutor",
    "rplugin",
    "syntax",
    "synmenu",
    "optwin",
    "compiler",
    "bugreport",
}

-- diagnostic configurations
M.diagnostics = {
    signs = {
        text = {
            [vim.diagnostic.severity.ERROR] = icons.diagnostics.error,
            [vim.diagnostic.severity.WARN] = icons.diagnostics.warn,
            [vim.diagnostic.severity.INFO] = icons.diagnostics.info,
            [vim.diagnostic.severity.HINT] = icons.diagnostics.hint,
        },
    },
    underline = true,
    update_in_insert = false,
    virtual_text = false,
    severity_sort = true,
    float = {
        border = M.borders,
        header = " ",
        source = "if_many",
        severity_sort = true,
        title = { { " Diagnostics ", "FloatTitle" } },
        prefix = function(diag)
            local sym = icons.diagnostics.error
            if diag.severity == vim.diagnostic.severity.INFO then
                sym = icons.diagnostics.info
            elseif diag.severity == vim.diagnostic.severity.WARN then
                sym = icons.diagnostics.warn
            elseif diag.severity == vim.diagnostic.severity.HINT then
                sym = icons.diagnostics.hint
            end
            local prefix = string.format(" %s ", sym)
            local severity = vim.diagnostic.severity[diag.severity]
            local diag_hl_name = severity:sub(1, 1) .. severity:sub(2):lower()
            return prefix, "Diagnostic" .. diag_hl_name:gsub("^%l", string.upper)
        end,
    },
    virtual_lines = false,
}


-- stylua: ignore start
vim.fn.sign_define( "DiagnosticSignError", { text = "", numhl = "DiagnosticError", linehl = "DiagnosticLineError" })
vim.fn.sign_define( "DiagnosticSignWarn", { text = "", numhl = "DiagnosticWarn", linehl = "DiagnosticLineWarn" })
vim.fn.sign_define( "DiagnosticSignInfo", { text = "", numhl = "DiagnosticInfo", linehl = "DiagnosticLineInfo" })
vim.fn.sign_define( "DiagnosticSignHint", { text = "", numhl = "DiagnosticHint", linehl = "DiagnosticLineHint" })
vim.fn.sign_define( "DapBreakpoint", { text = "", numhl = "DapBreakpoint" })
vim.fn.sign_define( "DagLogPoint", { text = "", numhl = "DapLogPoint", linehl = "DapLogPoint" })
vim.fn.sign_define( "DapStopped", { text = "", numhl = "DapStopped", linehl = "DapStopped" })
-- stylua: ignore end

return M
