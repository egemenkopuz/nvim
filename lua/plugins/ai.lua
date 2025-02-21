return {
    {
        "CopilotC-Nvim/CopilotChat.nvim",
        branch = "main",
        cmd = { "CopilotChat", "CopilotChatModels" },
        build = "make tiktoken",
        dependencies = { "MeanderingProgrammer/render-markdown.nvim" },
        opts = function()
            local icons = require "user.icons"
            local user = vim.env.USER or "User"
            user = user:sub(1, 1):upper() .. user:sub(2)
            return {
                allow_insecure = false,
                model = "gpt-4o",
                agent = "copilot",
                temperature = 0.1,
                chat_autocomplete = true,
                auto_insert_mode = false,
                auto_follow_cursor = false,
                show_help = true,
                highlight_headers = false,
                question_header = "## " .. icons.custom.user .. " " .. user .. " ",
                answer_header = "## " .. icons.custom.copilot .. " Copilot ",
                error_header = "> [!ERROR] Error",
                window = {
                    layout = "float",
                    relative = "cursor",
                    width = 1,
                    height = 0.45,
                    row = 1,
                    zindex = 40,
                },
                selection = function(source)
                    local select = require "CopilotChat.select"
                    return select.visual(source) or select.buffer(source)
                end,
                mappings = {
                    complete = { detail = "Use @<Tab> or /<Tab> for options.", insert = "<Tab>" },
                    close = { normal = "q", insert = "<C-c>" },
                    reset = { normal = "<leader>ar" },
                    submit_prompt = { detail = "", normal = "<CR>" },
                    accept_diff = { normal = "<leader>aD" },
                    yank_diff = { normal = "<leader>ay" },
                    show_diff = { normal = "<leader>ad" },
                    show_info = { normal = "<leader>as" },
                    show_context = { normal = "<leader>au" },
                },
            }
        end,
        init = function()
            require("user.utils").load_keymap "copilot_chat"
        end,
        config = function(_, opts)
            local chat = require "CopilotChat"
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
        end,
    },

    {
        "zbirenbaum/copilot.lua",
        init = function()
            require("user.utils").load_keymap "copilot"
        end,
        event = "BufReadPost",
        opts = {
            suggestion = {
                enabled = true,
                auto_trigger = true,
                keymap = {
                    accept = false,
                    dismiss = false,
                    next = "<C-]>",
                    prev = "<C-[>",
                },
            },
            panel = { enabled = false },
            filetypes = {
                markdown = true,
                yaml = function()
                    if string.find(vim.fs.basename(vim.api.nvim_buf_get_name(0)), "secret") then
                        return false
                    end
                    return true
                end,
                sh = function()
                    if string.match(vim.fs.basename(vim.api.nvim_buf_get_name(0)), "^%.env.*") then
                        return false
                    end
                    return true
                end,
            },
        },
    },
}
