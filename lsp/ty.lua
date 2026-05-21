---@type vim.lsp.Config
return {
    cmd = { "ty", "server" },
    filetypes = { "python" },
    settings = {
        ty = {
            inlayHints = {
                variableTypes = true,
                callArgumentNames = true,
            },
            completions = {
                autoImport = true,
            },
        },
    },
    root_markers = {
        "ty.toml",
        "pyproject.toml",
        "setup.py",
        "setup.cfg",
        "requirements.txt",
        ".git",
    },
}
