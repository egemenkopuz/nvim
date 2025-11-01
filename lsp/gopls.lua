return {
    cmd = { "gopls" },
    filetypes = { "go", "gomod", "gowork", "gotmpl" },
    root_markers = { "go.work", "go.mod", ".git" },
    -- single_file_support = true,
    settings = {
        gopls = {
            gofumpt = true,
            analyses = {
                nilness = true, -- Check for nil pointer dereferences
                unusedparams = true, -- Find unused function parameters
                unusedwrite = true, -- Find unused writes to variables
                useany = true, -- Suggest using 'any' instead of 'interface{}'
                unreachable = true, -- Find unreachable code
                unusedresult = true, -- Check for unused results of calls to certain functions
                simplifyslice = true, -- Simplify slice expressions
                simplifyrange = true, -- Simplify range loops
                simplifycompositelit = true, -- Simplify composite literals

                QF1006 = true, -- Lift if+break into loop condition
                QF1007 = true, -- Merge conditional assignment into variable declaration
                S1001 = true, -- Replace for loop with call to copy
                S1002 = true, -- Omit comparison with boolean constant
                S1005 = true, -- Drop unnecessary use of the blank identifier

                -- Performance-intensive analyzers (disabled for better performance)
                -- shadow = false, -- Check for shadowed variables (can be slow)
                -- printf = false, -- Check printf-style functions (can be slow)
                -- structtag = false, -- Check struct tags (can be slow)
                -- fieldalignment = false,  -- Check struct field alignment (very slow)
                -- unusedvariable = false,  -- Can be slow on large codebases
            },
            usePlaceholders = true,
            completeUnimported = true,
            staticcheck = true,
            semanticTokens = true,
            directoryFilters = { "-.git" },
            hints = {
                -- Ref: https://github.com/golang/tools/blob/master/gopls/doc/inlayHints.md
                constantValues = true,
                parameterNames = true,
                rangeVariableTypes = true,
                assignVariableTypes = true,
                compositeLiteralFields = false,
                compositeLiteralTypes = false,
                functionTypeParameters = false,
            },
        },
    },
}
