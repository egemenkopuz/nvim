return {
    { "folke/lazy.nvim" },

    { "MunifTanjim/nui.nvim" },

    { "nvim-lua/plenary.nvim" },

    {
        "folke/which-key.nvim",
        opts = {
            icons = { rules = false },
            disable = { bt = {}, ft = { "TelescopePrompt" } },
        },
        config = function(_, opts)
            local wk = require "which-key"
            wk.setup(opts)
            wk.add {
                mode = { "n", "v" },
                { "]", group = "+next" },
                { "[", group = "+prev" },
                { "<leader>q", group = "+quit" },
                { "<leader>b", group = "+buffer" },
                { "<leader><tab>", group = "+tab" },
                { "<leader>bs", group = "+sort" },
                { "<leader>bc", group = "+close" },
                { "<leader>d", group = "+debug" },
                { "<leader>c", group = "+code" },
                { "<leader>f", group = "+find" },
                { "<leader>s", group = "+search" },
                { "<leader>g", group = "+git" },
                { "<leader>h", group = "+help" },
                { "<leader>t", group = "+toggle" },
                { "<leader>w", group = "+workspace" },
                { "<leader>u", group = "+ui" },
                { "<leqder>q", group = "+quit" },
                { "<leader>x", group = "+diagnostics/quickfix" },
                { "<leader>ut", group = "+terminal" },
                { "<leader>cv", group = "+venv" },
                { "<leader>m", group = "+multicursor" },
                { "<leader>a", group = "+ai" },
                { "<leader>gh", group = "+hunk" },
                { "<leader>gt", group = "+toggle" },
                { "<leader>G", group = "+grug" },
                { "<leader>n", group = "+tests" },
            }
        end,
    },

    {
        "echasnovski/mini.icons",
        version = false,
        lazy = false,
        priority = 999,
        config = function(_, opts)
            require("mini.icons").setup(opts)
            MiniIcons.mock_nvim_web_devicons()
        end,
    },

    {
        "olimorris/persisted.nvim",
        cmd = { "SessionLoad", "SessionLoadLast" },
        lazy = true,
        opts = {
            autoload = false,
            should_autosave = function()
                for _, value in pairs { "alpha", "minifiles", "dashboard" } do
                    if vim.bo.filetype == value then
                        return false
                    end
                end
                return true
            end,
            telescope = {
                reset_prompt = true,
                mappings = {
                    change_branch = "<c-b>",
                    copy_session = "<c-c>",
                    delete_session = "<c-d>",
                },
                icons = { branch = " ", dir = " ", selected = " " },
            },
        },
        config = function(_, opts)
            require("persisted").setup(opts)
        end,
    },

    {
        "ahmedkhalf/project.nvim",
        lazy = false,
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
