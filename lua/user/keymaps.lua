local M = {}

local utils = require "user.utils"

M.general = {
    [{ "n", "x" }] = {
        ["j"] = { [[v:count == 0 ? 'gj' : 'j']], opts = { expr = true } },
        ["k"] = { [[v:count == 0 ? 'gk' : 'k']], opts = { expr = true } },
        ["x"] = { '"_x' },
        ["X"] = { '"_X' },
        ["d"] = { '"ad' },
        ["D"] = { '"aD' },
        ["c"] = { '"ac' },
        ["C"] = { '"aC' },
        ["gp"] = { '"ap', "Paste after cursor" },
        ["gP"] = { '"aP', "Paste before cursor" },
    },
    i = {
        -- to quit insert mode fast
        ["jk"] = { "<ESC>", "Leave insert mode" },
        ["kj"] = { "<ESC>", "Leave insert mode" },
        ["jj"] = { "<ESC>", "Leave insert mode" },
        -- go to beginning of line
        ["<C-b>"] = { "<ESC>^i", "Go to beginning of line" },
        -- go to end of line
        ["<C-e>"] = { "<End>", "Go to end of line" },
        -- save file
        ["<C-s>"] = { "<cmd> w <cr>", "Save file" },
        -- navigation
        ["<C-h>"] = { "<left>" },
        ["<C-j>"] = { "<down>" },
        ["<C-k>"] = { "<up>" },
        ["<C-l>"] = { "<right>" },
    },
    -- stylua: ignore
    n = {
        -- quit
        ["<leader>qa"] = {"<cmd> qall <cr>", "Quit all"},
        ["<leader>qA"] = {"<cmd> qall! <cr>", "Quit force all"},
        ["<leader>qq"] = {"<cmd> q <cr>", "Quit window"},
        ["<leader>qQ"] = {"<cmd> q! <cr>", "Quit force window"},
        -- save
        ["<leader>ws"] = {"<cmd> w <cr>", "Save"},
        ["<leader>wS"] = {"<cmd> wa <cr>", "Save all"},
        -- splits
        ["<leader>uv"] = {"<cmd> vsplit <cr>", "Vertical split"},
        ["<leader>ux"] = {"<cmd> split <cr>", "Horizontal split"},
        ["<leader>ue"] = {"<C-w>=", "Equalize splits"},
        -- ui reset
        ["<leader>ur"] = { "<cmd>nohlsearch<Bar>diffupdate<Bar>normal! <C-L><cr>", "Redraw / clear hlsearch / diff update"},
        -- go to last selected text
        ["gV"] = { '"`[" . strpart(getregtype(), 0, 1) . "`]"', "Visually select changed text", opts = { expr = true }, },
        -- emtpy lines
        ["go"] = { "<cmd>call append(line('.'),     repeat([''], v:count1))<cr>", "Put empty line below", },
        ["gO"] = { "<cmd>call append(line('.') - 1, repeat([''], v:count1))<cr>", "Put empty line below", },
        -- file operations
        ["<leader>wf"] = { "<cmd>enew<cr>", "Open a new file" },
        -- remove highlight
        ["<ESC>"] = { "<cmd> noh <cr>", "Remove highlight" },
        -- Resize with arrows
        ["<C-Up>"] = { ":resize +4<cr>", "Resize window up" },
        ["<C-Down>"] = { ":resize -4<cr>", "Resize window down" },
        ["<C-Left>"] = { ":vertical resize +4<cr>", "Resize window left" },
        ["<C-Right>"] = { ":vertical resize -4<cr>", "Resize window right" },
        -- save file
        ["<C-s>"] = { "<cmd> w <cr>", "Save file" },
        -- toggle line numbers
        ["<leader>tr"] = { "<cmd> set rnu! <cr>", "Relative line numbers" },
        -- toggle word wrap
        ["<leader>tw"] = { "<cmd> set wrap! <cr>", "Word wrap" },
        -- centered page navigation
        -- ["<C-u>"] = { "<C-u>zz", "Jump half-page up" },
        -- ["<C-d>"] = { "<C-d>zz", "Jump half-page down" },
        -- centered search navigation
        ["n"] = { "nzzzv", "Next searched" },
        ["N"] = { "Nzzzv", "Previous searched" },
        -- better pasting
        -- ["[p"] = { ":pu!<cr>" },
        -- ["]p"] = { ":pu<cr>" },
        -- toggle diagnostics
        ["<leader>td"] = { function() utils.toggle_diagnostics() end, "Diagnostics", },
        -- toggle format on save
        ["<leader>tf"] = { function() utils.toggle_autoformat() end, "Autoformat", },
        -- toggle color column
        ["<leader>tc"] = { function() utils.toggle_colorcolumn() end, "Colorcolumn", },
        -- toggle cursor lock
        ["<leader>tl"] = { function() vim.opt.scrolloff = 999 - vim.o.scrolloff end, "Cursorlock", },
        -- comment below/above
        ["gco"] = { "o<esc>Vcx<esc><cmd>normal gcc<cr>fxa<bs>",  "Add comment below" },
        ["gcO"] = { "O<esc>Vcx<esc><cmd>normal gcc<cr>fxa<bs>",  "Add comment above" },
        -- tab navigation
        ["<leader><tab><tab>"] = {":tabnext<cr>", "Tab next"},
        ["<leader><tab>q"] = {":tabclose<cr>", "Tab close"},
        ["<leader><tab>c"] = {":tabnew<cr>", "Tab create"},
        ["<leader><tab>["] = {":tabprevious<cr>", "Prev tab"},
        ["<leader><tab>]"] = {":tabnext<cr>", "Next tab"},
        ["<leader><tab>g"] = {":tabfirst<cr>", "First tab"},
        ["<leader><tab>G"] = {":tablast<cr>", "Last tab"},
    },
    -- v = {
    --     -- sorting
    --     ["<leader>s"] = { ":sort<cr>", "Sort ascending" },
    --     ["<leader>S"] = { ":sort!<cr>", "Sort descending" },
    -- },
}

M.clipboard = {
    [{ "n", "x" }] = {
        ["y"] = { '"+y' },
        ["Y"] = { '"+Y' },
        ["p"] = { '"+p' },
        ["P"] = { '"+P' },
    },
}

M.bufremove = {
    n = {
        ["<leader>bd"] = {
            function()
                local bd = require("mini.bufremove").delete
                if vim.bo.modified then
                    local choice = vim.fn.confirm(
                        ("Save changes to %q?"):format(vim.fn.bufname()),
                        "&Yes\n&No\n&Cancel"
                    )
                    if choice == 1 then -- Yes
                        vim.cmd.write()
                        bd(0)
                    elseif choice == 2 then -- No
                        bd(0, true)
                    end
                else
                    bd(0)
                end
            end,
            "Kill buffer",
        },
        ["<leader>bD"] = {
            function()
                require("mini.bufremove").delete(0, true)
            end,
            "Kill force buffer",
        },
    },
}

M.zenmode = {
    n = {
        ["<leader>tz"] = { "<cmd> ZenMode <cr>", "Zen mode" },
    },
}

M.treesitter_context = {
    n = {
        ["<leader>tt"] = { "<cmd> TSContextToggle <cr>", "Treesitter context" },
    },
}

M.telescope = {
    -- stylua: ignore
    v = {
        ["<leader>sw"] = { utils.telescope "grep_visual_selection", "Word (root dir)" },
        ["<leader>sW"] = { utils.telescope("grep_visual_selection", { cwd = false }), "Word (cwd)" },
    },
    -- stylua: ignore
    n = {
        ["<leader>f:"] = { "<cmd> Telescope command_history <cr>", "Command history" },
        ["<leader>ff"] = { utils.telescope "files", "Files (root)" },
        ["<leader>fF"] = { utils.telescope("files", { cwd = false }), "Files (cwd)" },
        ["<leader>fw"] = { utils.telescope "live_grep_args", "Live grep (root)" },
        ["<leader>fW"] = { utils.telescope("live_grep_args", { cwd = false }), "Live grep (cwd)" },
        ["<leader>fb"] = { "<cmd> Telescope buffers sort_mru=true sort_lastused=true<cr>", "Buffers" },
        ["<leader>fo"] = { "<cmd> Telescope oldfiles <cr>", "Recent files" },
        ["<leader>gc"] = { "<cmd> Telescope git_commits <cr>", "Git commits" },
        ["<leader>gg"] = { "<cmd> Telescope git_status <cr>", "Git status" },
        ["<leader>xf"] = { "<cmd> Telescope diagnostics <cr>", "Diagnostics" },
        ["<leader>sr"] = { "<cmd> Telescope resume <cr>", "Resume last picker" },
        ["<leader>sa"] = { "<cmd> Telescope autocommands <cr>", "Autocommands" },
        ['<leader>s"'] = { "<cmd> Telescope registers <cr>", "Registers" },
        ["<leader>sc"] = { "<cmd> Telescope command_history <cr>", "Command history" },
        ["<leader>sC"] = { "<cmd> Telescope commands <cr>", "Commands" },
        ["<leader>sd"] = { "<cmd> Telescope diagnostics <cr>", "Diagnostics" },
        ["<leader>sh"] = { "<cmd> Telescope help_tags<cr>", "Help Pages" },
        ["<leader>sH"] = { "<cmd> Telescope highlights<cr>", "Search highlight groups" },
        ["<leader>sk"] = { "<cmd> Telescope keymaps<cr>", "Key maps" },
        ["<leader>sM"] = { "<cmd> Telescope man_pages<cr>", "Man pages" },
        ["<leader>sm"] = { "<cmd> Telescope marks<cr>", "Jump to mark" },
        ["<leader>so"] = { "<cmd> Telescope vim_options<cr>", "Options" },
        ["<leader>sw"] = { utils.telescope "grep_word_under_cursor", "Word (root dir)" },
        ["<leader>sW"] = { utils.telescope("grep_word_under_cursor", { cwd = false }), "Word (cwd)" },
        ["<leader>xn"] = { "<cmd> Telescope notify <cr>", "Notifications" },
        ["<leader>ss"] = { utils.telescope("lsp_document_symbols", { symbols = { "Class", "Function", "Method", "Constructor", "Interface", "Module", "Struct", "Trait", "Field", "Property", }, }), "LSP symbols" },
        ["<leader>st"] = { "<cmd> Telescope terraform_doc full_name=hashicorp/aws<cr>", "Terraform AWS docs" },
        ["<leader><leader>"] = { function () require("telescope").extensions.smart_open.smart_open() end, "Quick navigate" }
    },
}

M.rename = {
    -- stylua: ignore
    n = {
        ["<leader>cr"] = { function() return ":IncRename " .. vim.fn.expand "<cword>" end, "Rename", opts = { expr = true }, },
    },
}

M.files = {
    n = {
        ["<C-g>"] = {
            function()
                require("mini.files").open()
            end,
        },
        ["<C-n>"] = {
            function()
                MiniFiles.open(vim.api.nvim_buf_get_name(0), false)
                MiniFiles.reveal_cwd()
            end,
        },
    },
}

M.lsp = {
    -- stylua: ignore
    n = {
        ["gD"] = { function() vim.lsp.buf.declaration() end, "Go to declaration", },
        -- ["<leader>ca"] = { function() vim.lsp.buf.code_action() end, "Code action", },
        ["<leader>cf"] = { function() vim.lsp.buf.format { async = true } end, "Format", },
        ["<leader>wa"] = { function() vim.lsp.buf.add_workspace_folder() end, "Add workspace folder", },
        ["<leader>wr"] = { function() vim.lsp.buf.remove_workspace_folder() end, "Remove workspace folder", },
        ["<leader>wl"] = { function() utils.notify(vim.inspect(vim.lsp.buf.list_workspace_folders())) end, "Workspace list", },
    },
}

M.lsp_inlay_hints = {
    n = {
        ["<leader>th"] = {
            function()
                vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
            end,
            "Inlay hints",
        },
    },
}

M.glance = {
    n = {
        ["gr"] = { "<cmd>Glance references<cr>", "References" },
        ["gM"] = { "<cmd>Glance implementations<cr>", "Implementations" },
        ["gd"] = { "<cmd>Glance definitions<cr>", "Definitions" },
        ["D"] = { "<cmd>Glance type_definitions<cr>", "Type definitions" },
    },
}

M.map = {
    n = {
        ["<leader>tm"] = {
            function()
                MiniMap.toggle()
            end,
            "Map",
        },
    },
}

M.gitsigns = {
    [{ "o", "x" }] = {
        ["ih"] = { ":<C-U> Gitsigns select_hunk <cr>", "Select hunk", { silent = true } },
    },
    -- stylua: ignore
    ["n"] = {
        ["[h"] = { function() require("gitsigns").nav_hunk("prev") end, "Prev hunk", },
        ["]h"] = { function() require("gitsigns").nav_hunk("next") end, "Next hunk", },
        ["[H"] = { function() require("gitsigns").nav_hunk("first") end, "First hunk", },
        ["]H"] = { function() require("gitsigns").nav_hunk("last") end, "Last hunk", },
        ["<leader>gl"] = { function() require("gitsigns").blame_line { full = true } end, "Blame line", },
        ["<leader>gb"] = { function() require("gitsigns").blame() end, "Blame buffer" },
        ["<leader>gs"] = { "<cmd> Gitsigns stage_hunk <cr>", "Stage hunk" },
        ["<leader>gr"] = { "<cmd> Gitsigns reset_hunk <cr>", "Reset hunk" },
        ["<leader>gu"] = { "<cmd> Gitsigns undo_stage_hunk <cr>", "Undo stage hunk" },
        ["<leader>gp"] = { "<cmd> Gitsigns preview_hunk <cr>", "Preview hunk" },
        ["<leader>gP"] = { "<cmd> Gitsigns preview_hunk_inline <cr>", "Preview hunk inline" },
        ["<leader>gS"] = { "<cmd> Gitsigns stage_buffer <cr>", "Stage buffer" },
        ["<leader>gR"] = { "<cmd> Gitsigns reset_buffer <cr>", "Reset buffer" },
        ["<leader>gtb"] = { "<cmd> Gitsigns toggle_current_line_blame <cr>", "Blame inlay" },
        ["<leader>gts"] = { "<cmd> Gitsigns toggle_signs <cr>", "Signs" },
        ["<leader>gtn"] = { "<cmd> Gitsigns toggle_numhl <cr>", "Numhl" },
        ["<leader>gtl"] = { "<cmd> Gitsigns toggle_linehl <cr>", "Linehl" },
        ["<leader>gtd"] = { "<cmd> Gitsigns toggle_word_diff <cr>", "Diff inlay" },
        -- ["<leader>gd"] = { function() require("gitsigns").diffthis("~") end, "Diff overlay" },
    },
}

M.illuminate = {
    -- stylua: ignore
    n = {
        ["]]"] = { function() require("illuminate").goto_next_reference(false) end, "Next reference", },
        ["[["] = { function() require("illuminate").goto_prev_reference(false) end, "Prev reference", },
    },
}

M.navigator = {
    [{ "n", "t" }] = {
        ["<C-h>"] = { "<cmd> NavigatorLeft <cr>", "Navigate left" },
        ["<C-j>"] = { "<cmd> NavigatorDown <cr>", "Navigate down" },
        ["<C-k>"] = { "<cmd> NavigatorUp <cr>", "Navigate up" },
        ["<C-l>"] = { "<cmd> NavigatorRight <cr>", "Navigate right" },
    },
}

M.trouble = {
    -- stylua: ignore
    n = {
        ["<leader>xd"] = { "<cmd> Trouble diagnostics toggle filter.buf=0 <cr>", "Buffer diagnostics", },
        ["<leader>xD"] = { "<cmd> Trouble diagnostics toggle <cr>", "Workspace diagnostics", },
        ["<leader>xl"] = { "<cmd> Trouble loclist toggle <cr>", "Loclist" },
        ["<leader>xq"] = { "<cmd> Trouble quickfix toggle <cr>", "Quickfix" },
        ["<leader>xs"] = { "<cmd> Trouble symbols toggle win.position=right <cr>", "Symbols"},
    },
}

M.toggleterm = {
    n = {
        ["<leader>g\\"] = { "<cmd>lua _LAZYGIT_TOGGLE()<cr>", "Lazygit" },
        ["<leader>utx"] = {
            "<cmd>ToggleTerm direction=horizontal<cr>",
            "Toggle horizontal terminal",
        },
        ["<leader>utv"] = { "<cmd>ToggleTerm direction=vertical<cr>", "Toggle vertical terminal" },
    },
    -- stylua: ignore
    t = {
        ["<C-x>"] = { vim.api.nvim_replace_termcodes("<C-\\><C-N>", true, true, true), "Close terminal", },

    },
}

M.dap = {
    -- stylua: ignore
    n = {
        ["<leader>dc"] = { function() require("dap").continue() end, "DAP continue", },
        ["<leader>dd"] = { function() require("dap").disconnect() end, "DAP disconnect", },
        ["<leader>dk"] = { function() require("dap").up() end, "DAP up", },
        ["<leader>dj"] = { function() require("dap").down() end, "DAP down", },
        ["<leader>du"] = { function() require("dap").step_over() end, "DAP step over", },
        ["<leader>di"] = { function() require("dap").step_into() end, "DAP step into", },
        ["<leader>do"] = { function() require("dap").step_out() end, "DAP step out", },
        ["<leader>ds"] = { function() require("dap").close() end, "DAP close", },
        ["<leader>dn"] = { function() require("dap").run_to_cursor() end, "DAP run to cursor", },
        ["<leader>de"] = { function() require("dap").set_exception_breakpoints() end, "DAP set exception breakpoints", },
        ["<leader>db"] = { function() require("dap").toggle_breakpoint() end, "DAP toggle breakpoint", },
        ["<leader>dD"] = { function() require("dap").clear_breakpoints() end, "DAP clear breakpoints", },
    },
}

M.dapui = {
    -- stylua: ignore
    n = {
        ["<leader>dt"] = { function() require("dapui").toggle() end, "DAP ui toggle", },
        ["<leader>dT"] = { function() require("dapui").close() end, "DAP ui close", },
        ["<leader>df"] = { function() require("dapui").float_element() end, "DAP ui float", },
    },
}

M.neotree = {
    n = {
        ["<C-n>"] = {
            function()
                require("neo-tree.command").execute { toggle = true, dir = vim.loop.cwd() }
            end,
            "Neotree",
        },
    },
}

M.spectre = {
    n = {
        ["<leader>cR"] = {
            function()
                require("spectre").open()
            end,
            "Replace in files (Spectre)",
        },
    },
}

M.grugfar = {
    [{ "n", "v" }] = {
        ["<leader>cs"] = {
            function()
                local is_visual = vim.fn.mode():lower():find "v"
                local v = {
                    transient = true,
                    prefills = { paths = vim.fn.expand "%" },
                }
                if is_visual then
                    require("grug-far").with_visual_selection(v)
                else
                    require("grug-far").open(v)
                end
            end,
            "Search and replace",
        },
        ["<leader>cS"] = {
            function()
                local is_visual = vim.fn.mode():lower():find "v"
                local v = {
                    transient = true,
                    prefills = { filesFilter = "*" },
                }
                if is_visual then
                    require("grug-far").with_visual_selection(v)
                else
                    require("grug-far").open(v)
                end
            end,
            "Search and replace (Project)",
        },
    },
}

M.window_picker = {
    n = {
        ["<leader>uw"] = {
            function()
                utils.pick_window()
            end,
            "Pick window",
        },
        ["<leader>us"] = {
            function()
                utils.swap_window()
            end,
            "Swap window",
        },
        ["<leader>uq"] = {
            function()
                local win = require("window-picker").pick_window()
                if not win or not vim.api.nvim_win_is_valid(win) then
                    return
                end
                local buf = vim.api.nvim_win_get_buf(win)
                local modified = vim.api.nvim_buf_get_option(buf, "modified")
                local bd = require("mini.bufremove").delete
                if modified then
                    local choice = vim.fn.confirm(
                        ("Save changes to %q?"):format(vim.fn.bufname(buf)),
                        "&Yes\n&No\n&Cancel"
                    )
                    if choice == 1 then -- Yes
                        bd(buf)
                        vim.api.nvim_win_close(win, true)
                    end
                else
                    bd(buf)
                    vim.api.nvim_win_close(win, true)
                end
            end,
            "Close buffer & window",
        },
    },
}

M.bufferline = {
    -- stylua: ignore
    n = {
        ["<leader>b1"] = { "<cmd> BufferLineGoToBuffer 1 <cr>", "Go to buffer 1" },
        ["<leader>b2"] = { "<cmd> BufferLineGoToBuffer 2 <cr>", "Go to buffer 2" },
        ["<leader>b3"] = { "<cmd> BufferLineGoToBuffer 3 <cr>", "Go to buffer 3" },
        ["<leader>b4"] = { "<cmd> BufferLineGoToBuffer 4 <cr>", "Go to buffer 4" },
        ["<leader>b5"] = { "<cmd> BufferLineGoToBuffer 5 <cr>", "Go to buffer 5" },
        ["<leader>b6"] = { "<cmd> BufferLineGoToBuffer 6 <cr>", "Go to buffer 6" },
        ["<leader>b7"] = { "<cmd> BufferLineGoToBuffer 7 <cr>", "Go to buffer 7" },
        ["<leader>b8"] = { "<cmd> BufferLineGoToBuffer 8 <cr>", "Go to buffer 8" },
        ["<leader>b9"] = { "<cmd> BufferLineGoToBuffer 9 <cr>", "Go to buffer 9" },
        ["<leader>b0"] = { "<cmd> BufferLineGoToBuffer 10 <cr>", "Go to buffer 10" },
        ["<leader>bb"] = { "<cmd>e # <cr>", "Go to other buffer"},
        ["<leader>b["] = { "<cmd> BufferLineMovePrev <cr>", "Move buffer left" },
        ["<leader>b]"] = { "<cmd> BufferLineMoveNext <cr>", "Move buffer right" },
        ["<leader>bw"] = { "<cmd> BufferLinePick <cr>", "Pick buffer" },
        ["<leader>bse"] = { "<cmd> BufferLineSortByExtension <cr>", "Sort buffers by extension" },
        ["<leader>bsd"] = { "<cmd> BufferLineSortByDirectory <cr>", "Sort buffers by directory" },
        ["<leader>bcr"] = { "<cmd> BufferLineCloseRight <cr>", "Close all visible buffers to the right" },
        ["<leader>bcl"] = { "<cmd> BufferLineCloseLeft <cr>", "Close all visible buffers to the left" },
        ["<leader>bp"] = { "<cmd> BufferLineTogglePin <cr>", "Pin buffer" },
        ["<leader>bcp"] = { "<cmd> BufferLineGroupClose ungrouped <cr>", "Close non-pinned buffers" },
        ["[b"] = { "<cmd>BufferLineCyclePrev<cr>", "Prev buffer" },
        ["]b"] = { "<cmd>BufferLineCycleNext<cr>", "Next buffer" },
        ["[B"] = { "<cmd>lua require('bufferline').go_to(1, true)<cr>", "First buffer" },
        ["]B"] = { "<cmd>lua require('bufferline').go_to(-1, true)<cr>", "Last buffer" },
    },
}

M.neogen = {
    n = {
        ["<leader>cg"] = {
            function()
                require("neogen").generate()
            end,
            "Generate doc",
        },
    },
}

M.undotree = {
    n = {
        ["<leader>tu"] = { "<cmd> UndotreeToggle <cr>", "Undotree" },
    },
}

M.symbols = {
    n = {
        ["<leader>ts"] = { "<cmd> Outline <cr>", "Symbols outline" },
    },
}

M.lsp_lines = {
    n = {
        ["<leader>tx"] = {
            function()
                require("user.utils").toggle_diagnostic_lines()
            end,
            "Diagnostics lines",
        },
    },
}

M.notify = {
    n = {
        ["<leader>un"] = {
            function()
                require("notify").dismiss { silent = true, pending = true }
            end,
            "Dismiss Notifications",
        },
    },
}

M.todo_comments = {
    n = {
        ["<leader>xt"] = { "<cmd>TodoTrouble <cr>", "Toggle Todo" },
        ["<leader>xT"] = {
            "<cmd>TodoTrouble keywords=TODO,FIX,FIXME <cr>",
            "Toggle Todo/Fix/Fixme",
        },
    },
}

M.venv = {
    n = {
        ["<leader>cv"] = { "<cmd> VenvSelect <cr>", "Select Python venv" },
    },
}

M.flash = {
    -- stylua: ignore start
    [{ "n", "x", "o" }] = {
        ["s"] = { function() require("flash").jump() end, "Flash" },
        ["S"] = { function() require("flash").treesitter() end, "Flash Treesitter" },
    },
    o = { ["r"] = { function() require("flash").remote() end, "Remote Flash" }, },
    [{ "o", "x" }] = { ["R"] = { function() require("flash").treesitter_search() end, "Treesitter search" }, },
    -- c = { ["<c-s>"] = { function() require("flash").toggle() end, "Toggle Flash Search" }, },
    -- stylua: ignore end
}

M.gitlinker = {
    n = {
        ["<leader>gy"] = {
            function()
                require("gitlinker").get_buf_range_url("n", {})
            end,
            "Yank link with line ranges",
            { silent = true },
        },
    },
    v = {
        ["<leader>gy"] = {
            function()
                require("gitlinker").get_buf_range_url("v", {})
            end,
            "Yank link with line ranges",
            { silent = true },
        },
    },
}

M.visual_multi = {
    n = {
        ["<leader>mj"] = { "<Plug>(VM-Add-Cursor-Down)", "Put Cursor Down" },
        ["<leader>mk"] = { "<Plug>(VM-Add-Cursor-Up)", "Put Cursor Up" },
        ["<leader>ma"] = { "<Plug>(VM-Select-All)<Tab>", "Select All" },
        ["<leader>mr"] = { "<Plug>(VM-Start-Regex-Search)", "Start Regex Search" },
        ["<leader>mp"] = { "<Plug>(VM-Add-Cursor-At-Pos)", "Add Cursor At Pos" },
        ["<leader>mo"] = { "<Plug>(VM-Toggle-Mappings)", "Toggle Mapping" },
    },
    v = {
        ["<leader>mv"] = {
            function()
                vim.cmd 'silent! execute "normal! \\<Plug>(VM-Visual-Cursors)"'
                vim.cmd "sleep 200m"
                vim.cmd 'silent! execute "normal! A"'
            end,
            "Visual Cursors",
        },
    },
}

M.copilot_chat = {
    [{ "n", "v" }] = {
        ["<leader>at"] = {
            function()
                return require("CopilotChat").toggle()
            end,
            "Toggle (CopilotChat)",
        },
        ["<leader>ax"] = {
            function()
                return require("CopilotChat").reset()
            end,
            "Clear (CopilotChat)",
        },
        ["<leader>ac"] = {
            function()
                local input = vim.fn.input "Quick Chat: "
                if input ~= "" then
                    require("CopilotChat").ask(input)
                end
            end,
            "Quick Chat (CopilotChat)",
        },
        ["<leader>ah"] = {
            function()
                local actions = require "CopilotChat.actions"
                require("CopilotChat.integrations.telescope").pick(actions.help_actions())
            end,
            "Diagnostic Help (CopilotChat)",
        },
        ["<leader>ap"] = {
            function()
                local actions = require "CopilotChat.actions"
                require("CopilotChat.integrations.telescope").pick(actions.prompt_actions())
            end,
            "Prompt Actions (CopilotChat)",
        },
    },
}

M.tiny_code_action = {
    n = {
        ["<leader>ca"] = {
            function()
                require("tiny-code-action").code_action()
            end,
            "Code Action",
        },
    },
}

M.diffview = {
    n = {
        ["<leader>gd"] = { "<cmd>DiffviewOpen<cr>", "Diffview" },
        -- ["<leader>gD"] = { "<cmd>DiffviewClose<cr>", "Diffview Close" },
    },
}

M.ufo = {
    n = {
        -- ["zr"] = {
        --     function()
        --         require("ufo").openFoldsExceptKinds()
        --     end,
        --     "Open fold except kinds",
        -- },
        -- ["zm"] = {
        --     function()
        --         require("ufo").closeFoldsWith()
        --     end,
        --     "Close fold except kinds",
        -- },
        ["zR"] = {
            function()
                require("ufo").openAllFolds()
            end,
            "Open all folds",
        },
        ["zM"] = {
            function()
                require("ufo").closeAllFolds()
            end,
            "Close all folds",
        },
        ["zp"] = {
            function()
                require("ufo.preview"):peekFoldedLinesUnderCursor()
            end,
            "Preview fold",
        },
    },
}

return M
