---@type vim.lsp.Config
return {
    cmd = { "ruff", "server" },
    filetypes = { "python" },
    root_markers = { "pyproject.toml", "ruff.toml", ".ruff.toml", ".git" },
    init_options = {
        settings = {
            logLevel = "warn",
            showSyntaxErrors = true, -- show syntax error diagnostics
            codeAction = {
                disableRuleComment = { enable = false }, -- show code action about rule disabling
                fixViolation = { enable = false }, -- show code action for autofix violation
            },
            format = { preview = false },
            lint = { enable = true },
        },
    },
    on_attach = function(client, bufnr)
        client.server_capabilities.hoverProvider = false
    end,
    single_file_support = true,
}
