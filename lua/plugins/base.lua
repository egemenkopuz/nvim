return {
    { "folke/lazy.nvim" },

    { "MunifTanjim/nui.nvim" },

    { "nvim-lua/plenary.nvim" },

    {
        "folke/which-key.nvim",
        opts = {
            icons = { breadcrumb = "»", separator = "  ", group = "+" },
            hidden = { "<silent>", "<cmd>", "<Cmd>", "<CR>", "call", "lua", "^:", "^ " },
            triggers_blacklist = { i = { "j", "k" }, v = { "j", "k" } },
            key_labels = { ["<leader>"] = "SPC" },
            disable = { buftypes = {}, filetypes = { "TelescopePrompt" } },
        },
        config = function(_, opts)
            local wk = require "which-key"
            wk.setup(opts)
            wk.register {
                mode = { "n", "v" },
                ["]"] = { name = "+next" },
                ["["] = { name = "+prev" },
                ["<leader>b"] = { name = "+buffer" },
                ["<leader>bs"] = { name = "+sort" },
                ["<leader>bc"] = { name = "+close" },
                ["<leader>d"] = { name = "+debug" },
                ["<leader>c"] = { name = "+code" },
                ["<leader>f"] = { name = "+find" },
                ["<leader>s"] = { name = "+search" },
                ["<leader>g"] = { name = "+git" },
                ["<leader>h"] = { name = "+help" },
                ["<leader>t"] = { name = "+toggle" },
                ["<leader>w"] = { name = "+workspace" },
                ["<leader>u"] = { name = "+ui" },
                ["<leader>q"] = { name = "+quit" },
                ["<leader>tg"] = { name = "+git" },
                ["<leader>x"] = { name = "+diagnostics/quickfix" },
                ["<leader>n"] = { name = "+notes" },
                ["<leader>ut"] = { name = "+terminal" },
                ["<leader>cv"] = { name = "+venv" },
            }
        end,
    },

    {
        "nvim-tree/nvim-web-devicons",
        opts = {
            color_icons = false,
            override_by_extension = { ["txt"] = { icon = "", name = "Txt" } },
            override_by_filename = {
                ["dockerfile"] = { icon = "", name = "Dockerfile" },
                ["Dockerfile"] = { icon = "", name = "Dockerfile" },
                [".dockerignore"] = { icon = "", name = "Dockerfile" },
                ["docker-compose.yaml"] = { icon = "", name = "Dockerfile" },
                ["docker-compose.yml"] = { icon = "", name = "Dockercompose" },
            },
        },
        config = true,
    },

    {
        "olimorris/persisted.nvim",
        cmd = { "SessionLoad", "SessionLoadLast" },
        lazy = true,
        config = true,
    },

    {
        "ahmedkhalf/project.nvim",
        lazy = true,
        opts = { manual_mode = true },
        config = function()
            require("project_nvim").setup()
        end,
    },

    {
        "karb94/neoscroll.nvim",
        lazy = false,
        config = function(_, opts)
            require("neoscroll").setup(opts)
        end,
    },
}
