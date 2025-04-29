return {
    { "b0o/schemastore.nvim", lazy = true },

    {
        "williamboman/mason.nvim",
        cmd = "Mason",
        opts = {
            ensure_installed = require("user.config").mason_packages,
            ui = { border = require("user.config").borders },
        },
        config = function(_, opts)
            require("mason").setup(opts)
            local mr = require "mason-registry"
            for _, tool in ipairs(opts.ensure_installed) do
                local p = mr.get_package(tool)
                if not p:is_installed() then
                    p:install()
                end
            end
        end,
    },

    {
        "linux-cultist/venv-selector.nvim",
        dependencies = {
            -- "neovim/nvim-lspconfig",
            "mfussenegger/nvim-dap-python",
        },
        branch = "regexp",
        ft = "python",
        cmd = { "VenvSelect" },
        opts = { picker = "native" },
        init = function()
            require("user.utils").load_keymap "venv"
        end,
        config = function(_, opts)
            require("venv-selector").setup(opts)
        end,
    },
}
