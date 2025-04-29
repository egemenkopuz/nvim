---@type vim.lsp.Config
return {
    cmd = { "basedpyright-langserver", "--stdio" },
    filetypes = { "python" },
    root_markers = {
        "pyproject.toml",
        "pyrightconfig.json",
        "setup.cfg",
        "setup.py",
        "Pipfile",
        "requirements.txt",
        ".git",
    },
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
    single_file_support = true,
}
