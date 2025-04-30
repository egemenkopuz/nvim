local utils = require "user.utils"
local methods = vim.lsp.protocol.Methods

local M = {}

---@param client vim.lsp.Client
---@param bufnr integer
function M.on_attach(client, bufnr)
    client.server_capabilities.documentFormattingProvider = false
    client.server_capabilities.documentRangeFormattingProvider = false

    -- load lsp keymaps
    utils.load_keymap("lsp", { buffer = bufnr })

    if vim.g.lsp_highlight_cursor_enabled then
        if client.server_capabilities.documentHighlightProvider then
            local hl_augroup = vim.api.nvim_create_augroup("lsp-highlight", { clear = false })
            vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
                buffer = bufnr,
                group = hl_augroup,
                callback = vim.lsp.buf.document_highlight,
            })
            vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
                buffer = bufnr,
                group = hl_augroup,
                callback = vim.lsp.buf.clear_references,
            })
            vim.api.nvim_create_autocmd("LspDetach", {
                group = vim.api.nvim_create_augroup("lsp-detach", { clear = true }),
                callback = function(event_d)
                    vim.lsp.buf.clear_references()
                    vim.api.nvim_clear_autocmds {
                        group = "lsp-highlight",
                        buffer = event_d.buf,
                    }
                end,
            })
        end
    end

    ---@diagnostic disable-next-line
    if client.supports_method(methods.textDocument_documentHighlight) then
        vim.api.nvim_create_autocmd({ "CursorHold", "InsertLeave" }, {
            desc = "Highlight references under the cursor",
            buffer = bufnr,
            callback = vim.lsp.buf.document_highlight,
        })
        vim.api.nvim_create_autocmd({ "CursorMoved", "InsertEnter", "BufLeave" }, {
            desc = "Clear highlight references",
            buffer = bufnr,
            callback = vim.lsp.buf.clear_references,
        })
    end

    if client.server_capabilities.inlayHintProvider and vim.lsp.inlay_hint then
        utils.load_keymap "lsp_inlay_hints"
        if vim.g.lsp_inlay_hints_enabled then
            vim.lsp.inlay_hint.enable(true)
        end
    end

    vim.diagnostics = require("user.config").diagnostics

    local hover = vim.lsp.buf.hover
    ---@diagnostic disable-next-line: duplicate-set-field
    vim.lsp.buf.hover = function()
        return hover {
            max_height = math.floor(vim.o.lines * 0.5),
            max_width = math.floor(vim.o.columns * 0.4),
        }
    end

    -- Update when registering dynamic capabilities.
    local register_capability = vim.lsp.handlers[methods.client_registerCapability]
    vim.lsp.handlers[methods.client_registerCapability] = function(err, res, ctx)
        ---@diagnostic disable-next-line: redefined-local
        local client = vim.lsp.get_client_by_id(ctx.client_id)

        if not client then
            return
        end

        M.on_attach(client, vim.api.nvim_get_current_buf())

        return register_capability(err, res, ctx)
    end
end

return M
