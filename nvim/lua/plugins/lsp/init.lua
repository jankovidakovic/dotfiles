local lsp_dependencies = {
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

local blacklist_lsp_servers = {
	-- "basedpyright"
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
		-- blacklist some servers
		for blacklist_server, _ in ipairs(blacklist_lsp_servers) do
			-- remove server from ensure_installed
			print("Blacklisting server " .. blacklist_server)
			ensure_installed[blacklist_server] = nil
		end

		-- install required tools
		require('mason-tool-installer').setup { ensure_installed = ensure_installed }
		-- TODO: find a way to ensure that only ensure_installed stuff are installed, and 
		-- other stuff is removed

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
