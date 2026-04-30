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
		end,
	},
}
