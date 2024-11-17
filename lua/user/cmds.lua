-- add command TrimWSLPaste to trim ^M after pasting
vim.cmd [[command! -nargs=0 TrimWSLPaste :%s/\r//g]]
