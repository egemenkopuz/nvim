---@type vim.lsp.Config
return {
    settings = {
        cmd = {
            "clangd",
            "--background-index",
            "--clang-tidy",
            "--completion-style=detailed",
            -- "--completion-parse=always",
            -- "--cross-file-rename",
            "--header-insertion=iwyu",
            "--suggest-missing-includes",
            "--function-arg-placeholders",
            "--fallback-style=llvm",
            -- "-j=4", -- number of workers
        },
        init_options = {
            usePlaceholders = true,
            completeUnimported = true,
            clangdFileStatus = true,
        },
        root_dir = {
            "Makefile",
            "configure.ac",
            "configure.in",
            "config.h.in",
            "meson.build",
            "meson_options.txt",
            "build.ninja",
            "compile_commands.json",
            "compile_flags.txt",
        },
    },
}
