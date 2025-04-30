return {
    {
        "stevearc/conform.nvim",
        event = "BufWritePre",
        opts = function()
            local formatting_config = require("user.config").formatting
            local opts = {
                notify_on_error = false,
                format_on_save = function()
                    -- Don't format when minifiles is open, since that triggers the "confirm without
                    -- synchronization" message.
                    if vim.g.minifiles_active then
                        return nil
                    end

                    -- Stop if we disabled auto-formatting.
                    if not vim.g.autoformat then
                        return nil
                    end

                    return {}
                end,
            }
            opts = vim.tbl_deep_extend("force", opts, formatting_config)
            return opts
        end,
        init = function()
            -- Use conform for gq.
            vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
        end,
    },
}
