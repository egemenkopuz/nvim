---@type vim.lsp.Config
return {
    cmd = { "lua-language-server" },
    filetypes = { "lua" },
    root_markers = {
        ".luarc.json",
        ".luarc.jsonc",
        ".luacheckrc",
        ".stylua.toml",
        "stylua.toml",
        "selene.toml",
        "selene.yml",
        ".git",
    },
    on_init = function(client)
        if client.workspace_folders then
            local path = client.workspace_folders[1].name
            if
                path ~= vim.fn.stdpath "config"
                and (
                    vim.loop.fs_stat(path .. "/.luarc.json")
                    or vim.loop.fs_stat(path .. "/.luarc.jsonc")
                )
            then
                return
            end
        end

        client.config.settings.Lua = vim.tbl_deep_extend("force", client.config.settings.Lua, {
            workspace = {
                library = {
                    vim.env.VIMRUNTIME,
                    "${3rd}/luv/library",
                },
            },
        })
    end,
    settings = {
        Lua = {
            format = { enable = false },
            telemetry = { enable = false },
            workspace = {
                checkThirdParty = false,
                maxPreload = 100000,
                preloadFileSize = 10000,
            },
        },
    },
}
