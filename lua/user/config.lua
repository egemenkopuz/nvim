local M = { icons = {}, colors = {} }

M.colorscheme = "kanagawa"
M.transparent = true
M.lsp_highlight_cursor = false
M.lsp_inlay_hints = true

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
    "black",
    "isort",
    "cmakelint",
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

-- Colors for diagnostics
M.colors.diagnostics = {
    info = "#78a5a3",
    hint = "#82a0aa",
    warn = "#e1b16a",
    error = "#ce5a57",
}

-- Colors for diffs
M.colors.diff = {
    added = "#78a5a3",
    modified = "#e1b16a",
    removed = "#ce5a57",
}

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

M.icons.clangd = {
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
}

M.diagnostics = {
    underline = true,
    update_in_insert = false,
    virtual_text = { spacing = 2, prefix = "●" },
    severity_sort = true,
    float = { border = "rounded" },
    virtual_lines = false,
}

-- remap macro recording to qq
vim.api.nvim_set_keymap("n", "q", "<Nop>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "qq", "q", { noremap = true, silent = true })

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

return M
