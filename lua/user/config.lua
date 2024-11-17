local M = { icons = {}, colors = {} }

M.colorscheme = "kanagawa"
M.transparent = false
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
    "terraform",
    "hcl",
    "rst",
    "ninja",
    "rust",
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
    "tfsec",
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
    -- cpp
    "clangd",
    "clang-format",
    -- debug
    "codelldb",
    -- docker
    "dockerfile-language-server",
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
}

M.nulls_packages = {
    formatting = {
        "isort",
        "black",
        "prettier",
        "stylua",
        "clang_format",
        "shfmt",
        "cmake_format",
        "terraform_fmt",
        "terragrunt_fmt",
    },
    diagnostics = {},
    code_actions = {},
    hover = {},
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

-- Dashboard custom logo
M.logo = {
    "   ███╗   ██╗ ██╗   ██╗ ██╗ ███╗   ███╗",
    "   ████╗  ██║ ██║   ██║ ██║ ████╗ ████║",
    "   ██╔██╗ ██║ ██║   ██║ ██║ ██╔████╔██║",
    "   ██║╚██╗██║ ╚██╗ ██╔╝ ██║ ██║╚██╔╝██║",
    "   ██║ ╚████║  ╚████╔╝  ██║ ██║ ╚═╝ ██║",
    "   ╚═╝  ╚═══╝   ╚═══╝   ╚═╝ ╚═╝     ╚═╝",
    "            Deus Est Machina           ",
}

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
    error = " ",
    warn = " ",
    info = " ",
    hint = " ",
}

-- Diff icons
M.icons.diff = {
    added = "+",
    modified = "~",
    removed = "-",
}

M.colors.branch_type = {
    default = "#E2DFD0",
    int = "#8DA9C4",
    dev = "#AD49E1",
    nightly = "#AD49E1",
    feat = "#90EE90",
    fix = "#ce5a57",
    release = "#e1b16a",
}

M.colors.custom = {
    light_red = "#ce5a57",
    light_green = "#90EE90",
    light_orange = "#e1b16a",
    light_cyan = "#82a0aa",
    light_purple = "#c792ea",
    light_gray = "#a0a1a7",
    sl_copilot = "#B7B7B7",
    sl_bg = "#181818",
    sl_filename = "#a0a1a7",
    sl_parent_path = "#545862",
    sl_lsp_progress = "#545862",
    sl_python_env = "#c4b28a",
}

M.icons.custom = {
    branch = "",
    copilot = "",
    macro_recording = " ",
    user = "",
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

M.borders = {
    none = { "", "", "", "", "", "", "", "" },
    invs = { " ", " ", " ", " ", " ", " ", " ", " " },
    thin = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" },
    sharp = { "┌", "─", "┐", "│", "┘", "─", "└", "│" },
}
M.borders.default = M.borders.sharp

M.diagnostics = {
    signs = {
        text = {
            [vim.diagnostic.severity.ERROR] = M.icons.diagnostics.error,
            [vim.diagnostic.severity.WARN] = M.icons.diagnostics.warn,
            [vim.diagnostic.severity.INFO] = M.icons.diagnostics.info,
            [vim.diagnostic.severity.HINT] = M.icons.diagnostics.hint,
        },
    },
    underline = true,
    update_in_insert = false,
    -- virtual_text = {
    --     spacing = 2,
    --     prefix = "■",
    --     format = function()
    --         return ""
    --     end,
    -- },
    virtual_text = false,
    severity_sort = true,
    float = {
        border = M.borders.default,
        header = " ",
        source = "if_many",
        severity_sort = true,
        title = { { " Diagnostics ", "FloatTitle" } },
        prefix = function(diag)
            local sym = M.icons.diagnostics.error
            if diag.severity == vim.diagnostic.severity.INFO then
                sym = M.icons.diagnostics.info
            elseif diag.severity == vim.diagnostic.severity.WARN then
                sym = M.icons.diagnostics.warn
            elseif diag.severity == vim.diagnostic.severity.HINT then
                sym = M.icons.diagnostics.hint
            end
            local prefix = string.format(" %s ", sym)
            local severity = vim.diagnostic.severity[diag.severity]
            local diag_hl_name = severity:sub(1, 1) .. severity:sub(2):lower()
            return prefix, "Diagnostic" .. diag_hl_name:gsub("^%l", string.upper)
        end,
    },
    virtual_lines = false,
}

M.lsp_to_status_name = {}

M.lsp_to_status_exclude = { "null-ls", "copilot" }

M.copilot_chat_window_alt_opts = { layout = "vertical", width = 0.5, height = 0.5 }

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
