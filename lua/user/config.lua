local M = { icons = {} }

M.colorscheme = "kanagawa"

vim.g.python3_host_prog = "/usr/bin/python3"

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
    "json",
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
}

-- auto install mason packages
M.mason_packages = {
    "bash-language-server",
    "lua-language-server",
    "cmake-language-server",
    "cmakelang",
    "basedpyright",
    "ruff-lsp",
    "clangd",
    "dockerfile-language-server",
    "marksman",
    "json-lsp",
    "yaml-language-server",
    "hadolint",
    "stylua",
    "clang-format",
    "debugpy",
    "codelldb",
    "shfmt",
    "mdformat",
    "eslint-lsp",
    "ansible-lint",
    "prettier",
}

M.nulls_packages = {
    formatting = {
        "isort",
        "black",
        "prettier",
        "stylua",
        "clang_format",
        "shfmt",
        "mdformat",
        "cmake_format",
    },
    diagnostics = {
        "hadolint",
        "cmake_lint",
        "cppcheck",
        "ansiblelint",
    },
    code_actions = {},
    hover = {},
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
    "ftplugin",
}

-- Dashboard custom logo
M.logo = nil

-- Diagnostics icons
M.icons.diagnostics = {
    error = " ",
    warn = " ",
    info = " ",
    hint = " ",
}

-- Diff icons
M.icons.diff = {
    added = "+",
    modified = "~",
    removed = "-",
}

-- Syntax icons
M.icons.kinds = {
    Text = " ",
    Method = "󰆧 ",
    Function = "󰊕 ",
    Constructor = " ",
    Field = "󰇽 ",
    Variable = "󰂡 ",
    Class = "󰠱 ",
    Interface = " ",
    Module = " ",
    Property = "󰜢 ",
    Unit = " ",
    Value = "󰎠 ",
    Enum = " ",
    Keyword = "󰌋 ",
    Snippet = " ",
    Color = "󰏘 ",
    File = "󰈙 ",
    Reference = " ",
    Folder = "󰉋 ",
    EnumMember = " ",
    Constant = "󰏿 ",
    Struct = " ",
    Event = " ",
    Operator = "󰆕 ",
    TypeParameter = "󰅲 ",
    Namespace = " ",
    Table = " ",
    Object = "󰙞 ",
    Tag = " ",
    Array = "[] ",
    Boolean = " ",
    Number = " ",
    Null = "󰟢 ",
    String = " ",
    Calendar = " ",
    Watch = "󰖉 ",
    Package = " ",
    Copilot = " ",
}

-- stylua: ignore start
vim.fn.sign_define( "DiagnosticSignError", { text = "", numhl = "DiagnosticError", linehl = "DiagnosticLineError" })
vim.fn.sign_define( "DiagnosticSignWarn", { text = "", numhl = "DiagnosticWarn", linehl = "DiagnosticLineWarn" })
vim.fn.sign_define( "DiagnosticSignInfo", { text = "", numhl = "DiagnosticInfo", linehl = "DiagnosticLineInfo" })
vim.fn.sign_define( "DiagnosticSignHint", { text = "", numhl = "DiagnosticHint", linehl = "DiagnosticLineHint" })
vim.fn.sign_define( "DapBreakpoint", { text = "", numhl = "DapBreakpoint", linehl = "DapBreakpoint" })
vim.fn.sign_define( "DagLogPoint", { text = "", numhl = "DapLogPoint", linehl = "DapLogPoint" })
vim.fn.sign_define( "DapStopped", { text = "", numhl = "DapStopped", linehl = "DapStopped" })

vim.api.nvim_set_hl(0, "DapBreakpoint", { bg = "#454545" })
vim.api.nvim_set_hl(0, "DapLogPoint", { bg = "#31353f" })
vim.api.nvim_set_hl(0, "DapStopped", { fg = "white", bg = "#B14238" })
-- stylua: ignore end

M.diagnostics = {
    underline = true,
    update_in_insert = false,
    virtual_text = { spacing = 2, prefix = "●" },
    severity_sort = true,
    float = { border = "rounded" },
    virtual_lines = false,
}

return M
