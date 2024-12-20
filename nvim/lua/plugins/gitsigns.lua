return {
	"lewis6991/gitsigns.nvim",
	opts = {
		on_attach = function(bufnr)
			local gitsigns = require("gitsigns")
			local function map(mode, l, r, opts)
				opts = opts or {}
				opts.buffer = bufnr
				vim.keymap.set(mode, l, r, opts)
			end

			-- Navigation
			map('n', '<leader>gj', function()
				if vim.wo.diff then
					vim.cmd.normal({ ']c', bang = true })
				else
					gitsigns.nav_hunk('next')
				end
			end)

			map('n', '<leader>gk', function()
				if vim.wo.diff then
					vim.cmd.normal({ '[c', bang = true })
				else
					gitsigns.nav_hunk('prev')
				end
			end)
		end
	}
}
