return {
    {
        "CopilotC-Nvim/CopilotChat.nvim",
        branch = "canary",
        cmd = "CopilotChat",
        opts = function()
            local config = require "user.config"
            local user = vim.env.USER or "User"
            user = user:sub(1, 1):upper() .. user:sub(2)
            -- stylua: ignore
            local prompts = {
                Tests = { prompt = "/COPILOT_GENERATE Please explain how the selected code works, then generate unit tests for it." },
                Refactor = { prompt = "/COPILOT_GENERATE Please refactor the following code to improve its clarity and readability." },
                BetterNamings = { prompt = "Please provide better names for the following variables and functions." },
                Documentation = { prompt = "/COPILOT_GENERATE Please provide documentation for the following code." },
                Summarize = { prompt = "Please summarize the following text." },
                Spelling = { prompt = "Please correct any grammar and spelling errors in the following text." },
                Wording = { prompt = "Please improve the grammar and wording of the following text." },
                Concise = { prompt = "Please rewrite the following text to make it more concise." },
            }
            return {
                allow_insecure = false,
                model = "gpt-4o",
                temperature = 0.1,
                prompts = prompts,
                auto_insert_mode = false,
                auto_follow_cursor = false,
                show_help = true,
                question_header = config.icons.custom.user .. " " .. user .. " ",
                answer_header = config.icons.custom.copilot .. " Copilot ",
                error_header = config.icons.diagnostics.error .. " Error ",
                window = {
                    layout = "float",
                    relative = "cursor",
                    width = 1,
                    height = 0.45,
                    row = 1,
                    zindex = 999,
                },
                selection = function(source)
                    local select = require "CopilotChat.select"
                    return select.visual(source) or select.buffer(source)
                end,
                mappings = {
                    complete = { detail = "", insert = "" },
                    close = { normal = "q", insert = "<C-c>" },
                    reset = { normal = "<leader>ar" },
                    submit_prompt = { detail = "", normal = "<CR>" },
                    accept_diff = { normal = "<leader>aD" },
                    yank_diff = { normal = "<leader>ay" },
                    show_diff = { normal = "<leader>ad" },
                    show_system_prompt = { normal = "<leader>as" },
                    show_user_selection = { normal = "<leader>au" },
                },
            }
        end,
        init = function()
            require("user.utils").load_keymap "copilot_chat"
        end,
        config = function(_, opts)
            local chat = require "CopilotChat"
            vim.api.nvim_create_autocmd("BufEnter", {
                pattern = "copilot-chat",
                callback = function()
                    vim.opt_local.relativenumber = false
                    vim.opt_local.number = false
                end,
            })
            local wk = require "which-key"
            wk.add {
                { "<leader>ar", desc = "Reset Copilot" },
                { "<leader>as", desc = "Show System Prompt" },
                { "<leader>au", desc = "Show User Selection" },
                { "<leader>ad", desc = "Show Diff" },
                { "<leader>ay", desc = "Yank Diff" },
                { "<leader>aD", desc = "Accept Diff" },
            }
            chat.setup(opts)
            require("CopilotChat.integrations.cmp").setup()
        end,
    },

    {
        "Civitasv/cmake-tools.nvim",
        enabled = false,
        depends = { "nvim-lua/plenary.nvim", "stevearc/overseer.nvim" },
        ft = { "cmake", "cpp" },
        opts = {
            cmake_executor = {
                name = "overseer",
                default_opts = {
                    overseer = {
                        new_task_opts = {
                            strategy = {
                                "toggleterm",
                                direction = "horizontal",
                                autos_croll = true,
                                quit_on_exit = "success",
                            },
                        },
                    },
                    toggleterm = { direction = "horizontal" },
                },
            },
        },
        config = function(_, opts)
            require("cmake-tools").setup(opts)
        end,
    },

    {
        "kawre/leetcode.nvim",
        enabled = false,
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
