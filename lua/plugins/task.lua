return {
    {
        "stevearc/overseer.nvim",
        ft = { "cmake", "cpp", "python" },
        opts = {},
        config = function()
            require("overseer").setup()
        end,
    },

    {
        "Civitasv/cmake-tools.nvim",
        depends = { "nvim-lua/plenary.nvim", "stevearc/overseer.nvim" },
        ft = { "cmake", "cpp" },
        opts = {},
        config = function(_, opts)
            require("cmake-tools").setup(opts)
        end,
    },

    {
        "kawre/leetcode.nvim",
        build = ":TSUpdate html",
        lazy = "leetcode.nvim" ~= vim.fn.argv()[1],
        dependencies = {
            "nvim-telescope/telescope.nvim",
            "MunifTanjim/nui.nvim",
            "nvim-treesitter/nvim-treesitter",
        },
        opts = {
            storage = {
                home = vim.fn.expand "~/workspace/competitive-programming/answers/leetcode/",
                cache = vim.fn.stdpath "cache" .. "/leetcode",
            },
            injector = {
                ["cpp"] = {
                    before = { "#include <bits/stdc++.h>", "using namespace std;" },
                    after = {},
                },
            },
        },
    },

    --     {
    --         "nvim-neotest/neotest",
    --         dependencies = {
    --             "nvim-lua/plenary.nvim",
    --             "antoinemadec/FixCursorHold.nvim",
    --             "nvim-treesitter/nvim-treesitter",
    --             "alfaix/neotest-gtest",
    --         },
    --         config = function()
    --             require("neotest").setup {
    --                 adapters = {
    --                     require "neotest-python" {
    --                         dap = { justMyCode = false },
    --                     },
    --                     require("neotest-gtest").setup {},
    --                 },
    --             }
    --         end,
    --     },
}
