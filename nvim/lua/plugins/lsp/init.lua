return {
	{ 'williamboman/mason.nvim', config = true },
	{
		'WhoIsSethDaniel/mason-tool-installer.nvim',
		dependencies = { 'williamboman/mason.nvim' },
		opts = {
			ensure_installed = {
				'basedpyright',
				'lua-language-server',
				'ruff',
				'bash-language-server',
				'typescript-language-server',
				'vue-language-server',
				'eslint-lsp',
				'ansible-language-server',
				'stylua',
				'shfmt',
				'ormolu',
				'hlint',
				'prettier',
				'hadolint',
			},
		},
	},
	{ 'j-hui/fidget.nvim', opts = {} },
	{
		'hrsh7th/cmp-nvim-lsp',
		config = function()
			require("plugins.lsp.augroups")()

			vim.lsp.config('*', {
				capabilities = vim.tbl_deep_extend(
					'force',
					vim.lsp.protocol.make_client_capabilities(),
					require('cmp_nvim_lsp').default_capabilities()
				),
			})

			vim.lsp.enable({
				'basedpyright',
				'lua_ls',
				'ruff',
				'bashls',
				'ts_ls',
				'volar',
				'eslint',
				'ansiblels',
				'kotlin_lsp',
			})

			vim.api.nvim_create_user_command('LspInfo', function()
				local clients = vim.lsp.get_clients({ bufnr = 0 })
				if #clients == 0 then
					print("No LSP clients attached to this buffer")
					return
				end
				local lines = {}
				for _, client in ipairs(clients) do
					table.insert(lines, string.format("%s (id=%d, root=%s)",
						client.name, client.id, client.root_dir or "nil"))
				end
				print(table.concat(lines, "\n"))
			end, {})
		end,
	},
}
