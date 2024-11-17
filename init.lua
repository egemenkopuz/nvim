if vim.fn.has "nvim" and vim.fn.executable "nvr" then
    vim.env.GIT_EDITOR = "nvr -cc split --remote-wait +'set bufhidden=wipe'"
end

require "user.options"
require "user.utils"

local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system {
        "git",
        "clone",
        "--filter=blob:none",
        "--single-branch",
        "https://github.com/folke/lazy.nvim.git",
        lazypath,
    }
end
vim.opt.runtimepath:prepend(lazypath)

require("lazy").setup("plugins", {
    defaults = { lazy = true },
    lockfile = vim.fn.stdpath "config" .. "/plugin-lock.json",
    ui = { size = { width = 0.9, height = 0.9 }, border = "single" },
    performance = {
        cache = { enabled = true },
        rtp = { disabled_plugins = require("user.config").disabled_plugins },
    },
    change_detection = { notify = false },
})

require "user.autocmds"
require "user.filetype"
require("user.utils").load_keymap "general"
