return {
    cmd = { "gopls" },
    filetypes = { "go", "gomod", "gowork", "gotmpl" },
    root_markers = { "go.work", "go.mod", ".git" },
    -- single_file_support = true,
    settings = {
        gopls = {
            hints = {
                -- Ref: https://github.com/golang/tools/blob/master/gopls/doc/inlayHints.md
                constantValues = true,
                parameterNames = true,
                rangeVariableTypes = true,
                assignVariableTypes = true,
            },
        },
    },
}
