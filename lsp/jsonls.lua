---@type vim.lsp.Config
return {
    cmd = { "vscode-json-language-server", "--stdio" },
    filetypes = { "json", "jsonc" },
    root_markers = { ".git" },
    init_options = {
        provideFormatter = true,
    },
    settings = {
        json = {
            validate = { enable = true },
            schemas = require("schemastore").json.schemas(),
        },
    },
}
