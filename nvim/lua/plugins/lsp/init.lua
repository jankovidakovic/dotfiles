lsp_dependencies = {
	-- Automatically install LSPs and related tools to stdpath for Neovim
	{ 'williamboman/mason.nvim', config = true }, -- NOTE: Must be loaded before dependants
	'williamboman/mason-lspconfig.nvim',
	'WhoIsSethDaniel/mason-tool-installer.nvim',

	-- Useful status updates for LSP.
	-- NOTE: `opts = {}` is the same as calling `require('fidget').setup({})`
	{ 'j-hui/fidget.nvim',       opts = {} },

	-- Allows extra capabilities provided by nvim-cmp
	'hrsh7th/cmp-nvim-lsp',
}

return {
	-- Main LSP Configuration
	'neovim/nvim-lspconfig',
	dependencies = lsp_dependencies,
	config = function()
		-- set up the autogroups
		require("plugins.lsp.augroups")()

		local capabilities = vim.lsp.protocol.make_client_capabilities()
		capabilities = vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())

		require('mason').setup()

		local servers = require("plugins.lsp.servers")

		local ensure_installed = vim.tbl_keys(servers or {})
		require('mason-tool-installer').setup { ensure_installed = ensure_installed }
		--
		require('mason-lspconfig').setup {
			handlers = {
				function(server_name)
					local server = servers[server_name] or {}
					-- this kinda modifies the global variable, no?
					server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
					require('lspconfig')[server_name].setup(server)
				end,
			},
		}
	end,
}
