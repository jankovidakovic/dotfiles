return function()
	vim.api.nvim_create_autocmd('LspAttach', {
		group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
		callback = function(event)
			-- set mapping but only for that specific buffer
			require("plugins.lsp.mappings")()

			local client = vim.lsp.get_client_by_id(event.data.client_id)

			-- set document highlighting stuff
			if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
				local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
				vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
					buffer = event.buf,
					group = highlight_augroup,
					callback = vim.lsp.buf.document_highlight,
				})

				--
				vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
					buffer = event.buf,
					group = highlight_augroup,
					callback = vim.lsp.buf.clear_references,
				})
				-- TODO -- shouldnt this be outside of if?
				vim.api.nvim_create_autocmd('LspDetach', {
					group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
					callback = function(event2)
						vim.lsp.buf.clear_references()
						vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
					end,
				})
			end
			-- inlay hints
			-- if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
				-- map('<leader>th', function()
					-- vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
				-- end, '[T]oggle Inlay [H]ints')
			-- end
		end,
	})
end
