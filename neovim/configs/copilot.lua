vim.g.copilot_filetypes = { xml = false, markdown = false }
vim.cmd [[highlight CopilotSuggestion guifg=#555555 ctermfg=8]]
vim.cmd [[imap <silent><script><expr> <C-a> copilot#Accept("\<CR>")]]
vim.g.copilot_on_tab_map = true

vim.api.nvim_set_keymap("i", "C-J", 'copilot#Accept("<CR>")', { silent = true, expr = true })
