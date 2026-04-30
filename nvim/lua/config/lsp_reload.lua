local config_patterns = {
	'tsconfig.json',
	'jsconfig.json',
	'package.json',
	'package-lock.json',
	'pyproject.toml',
	'setup.py',
	'setup.cfg',
	'requirements.txt',
	'Cargo.toml',
	'Cargo.lock',
	'.eslintrc',
	'.eslintrc.js',
	'.eslintrc.json',
	'eslint.config.js',
	'eslint.config.mjs',
	'.luarc.json',
	'.luarc.jsonc',
	'ruff.toml',
	'.ruff.toml',
	'ansible.cfg',
	'.ansible-lint',
	'settings.gradle',
	'settings.gradle.kts',
	'build.gradle',
	'build.gradle.kts',
	'pom.xml',
}

local function restart_lsp_clients()
	local clients = vim.lsp.get_clients()
	if #clients == 0 then
		return
	end
	for _, client in ipairs(clients) do
		client:stop()
	end
	vim.defer_fn(function()
		for _, buf in ipairs(vim.api.nvim_list_bufs()) do
			if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].buflisted then
				vim.api.nvim_exec_autocmds('FileType', { buffer = buf })
			end
		end
	end, 500)
end

local augroup = vim.api.nvim_create_augroup('lsp-auto-reload', { clear = true })

vim.api.nvim_create_autocmd('BufWritePost', {
	group = augroup,
	pattern = config_patterns,
	callback = restart_lsp_clients,
	desc = 'Restart LSP clients when project config files are saved',
})

local last_reload = 0

vim.api.nvim_create_autocmd('FocusGained', {
	group = augroup,
	callback = function()
		local now = vim.uv.now()
		if now - last_reload < 5000 then
			return
		end
		last_reload = now
		restart_lsp_clients()
	end,
	desc = 'Restart LSP clients when Neovim regains focus (debounced 5s)',
})

vim.api.nvim_create_autocmd('TermClose', {
	group = augroup,
	callback = function()
		last_reload = vim.uv.now()
		restart_lsp_clients()
	end,
	desc = 'Restart LSP clients when a terminal closes',
})
