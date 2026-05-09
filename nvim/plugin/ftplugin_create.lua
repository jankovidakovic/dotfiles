-- usage: run :FtpluginCreate inside nvim
-- installs the treesitter parser if available, starts treesitter, and
-- 	saves the ftplugin file that automatically starts treesitter for the filetype
-- 	the purpose is not having to do this manually every time we encounter
-- 	a filetype for which we didnt yet configure treesitter.

vim.api.nvim_create_user_command('FtpluginCreate', function()
	-- detect filetype
	local ft = vim.bo.filetype
	if ft == '' then
		vim.notify('No filetype detected', vim.log.levels.WARN)
		return
	end
	-- if ftplugin that sources treesitter already exists, we have nothing to do
	local path = vim.fn.expand('~/dotfiles/dotfiles/nvim/ftplugin/') .. ft .. '.lua'
	if vim.uv.fs_stat(path) then
		vim.notify(path .. ' already exists', vim.log.levels.WARN)
		return
	end

	-- check if the treesitter grammar actually exists for the file
	local lang = vim.treesitter.language.get_lang(ft)
	local parsers = require('nvim-treesitter.parsers')
	if not parsers[lang] then
		vim.notify('No treesitter grammar available for ' .. lang, vim.log.levels.WARN)
		return
	end


	-- capture bufnr now because install is async and user may switch buffers
	local bufnr = vim.api.nvim_get_current_buf()
	-- async treesitter install parser
	local task = require('nvim-treesitter.install').install({ lang }, { summary = true })
	task:await(function(err, success)
		-- parser install failed -> nothing to do
		if err or not success then
			return
		end
		vim.schedule(function()
			-- save the treesitter start to a ftplugin file
			vim.fn.mkdir(vim.fn.fnamemodify(path, ':h'), 'p')
			local f = io.open(path, 'w')
			f:write('vim.treesitter.start()\n')
			f:close()
			vim.notify('Created ' .. path)

			-- buffer may have been closed during install
			if not vim.api.nvim_buf_is_valid(bufnr) then
				return
			end
			vim.treesitter.start(bufnr)
		end)
	end)
end, {})
