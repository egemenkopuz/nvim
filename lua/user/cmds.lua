-- add command TrimWSLPaste to trim ^M after pasting
vim.api.nvim_create_user_command("TrimWSLPaste", function()
    vim.cmd "%s/\\r//g"
end, { nargs = 0 })

-- add command to format given range
vim.api.nvim_create_user_command("Format", function(args)
    local range = nil
    if args.count ~= -1 then
        local end_line = vim.api.nvim_buf_get_lines(0, args.line2 - 1, args.line2, true)[1]
        range = {
            start = { args.line1, 0 },
            ["end"] = { args.line2, end_line:len() },
        }
    end
    require("conform").format { async = true, lsp_format = "fallback", range = range }
end, { range = true })

-- add command NoEndOfLine to remove end of line
vim.api.nvim_create_user_command("NoEndOfLine", function()
    vim.bo.binary = true
    vim.cmd "update"
end, { nargs = 0 })
