-- disable netrw at the very start of your init.lua
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- optionally enable 24-bit colour
vim.opt.termguicolors = true

-- as per https://github.com/nvim-tree/nvim-tree.lua?tab=readme-ov-file#custom-mappings, this is the way to change the mappings
local function my_on_attach(bufnr)
	local api = require "nvim-tree.api"

	-- utility function to provide the default mapping options
	-- TODO -- optionally refactor this into a more general utility function (altho thats really not needed)
	local function opts(desc)
		return {
			desc = "nvim-tree: " .. desc,
			--  when we only attach a mapping to a buffer, then sometimes nvimtree attaches to itself
			--  and then the mappings dont work in other buffers.
			--  Without setting the buffer, mappings are on nvim-level and should work?
			--  buffer = bufnr,
			noremap = true,
			silent = true,
			nowait = true
		}
	end

	-- default mappings
	api.config.mappings.default_on_attach(bufnr)

	-- custom mappings
	vim.keymap.set("n", "<A-1>", api.tree.toggle, opts("Toggle"))

	vim.keymap.set("n", "<leader>e", api.tree.focus, opts("Focus"))
end

return {
	"nvim-tree/nvim-tree.lua",
	opts = {
		on_attach = my_on_attach
	}
}
