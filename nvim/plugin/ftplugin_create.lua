vim.api.nvim_create_user_command('FtpluginCreate', function()
	local ft = vim.bo.filetype
	if ft == '' then
		vim.notify('No filetype detected', vim.log.levels.WARN)
		return
	end
	local path = vim.fn.expand('~/dotfiles/dotfiles/nvim/ftplugin/') .. ft .. '.lua'
	if vim.uv.fs_stat(path) then
		vim.notify(path .. ' already exists', vim.log.levels.WARN)
		return
	end
	vim.fn.mkdir(vim.fn.fnamemodify(path, ':h'), 'p')
	local f = io.open(path, 'w')
	f:write('vim.treesitter.start()\n')
	f:close()
	vim.cmd.source(path)
	vim.notify('Created ' .. path)
end, {})
