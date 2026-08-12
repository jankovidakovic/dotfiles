local function yank_path()
	vim.fn.setreg('+', vim.fn.expand('%:.'))
end

vim.api.nvim_create_user_command('YankPath', yank_path, {})
vim.keymap.set('n', '<leader>yp', yank_path, { desc = '[Y]ank [P]ath' })
