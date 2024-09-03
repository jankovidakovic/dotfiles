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
    return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
  end

  -- default mappings
  api.config.mappings.default_on_attach(bufnr)

  -- custom mappings
  vim.keymap.set("n", "<C-n>", function ()
	  print("i got toggled by the mapping")
	  api.tree.toggle()
  end, opts("Toggle"))

  vim.keymap.set("n", "<leader>e", function ()
	  print("i got focused by the mapping, bitch")
	  api.tree.focus()
  end, opts("Focus"))
  -- TODO -- why are these not working? they should kinda be working, no?
end

return {
	"nvim-tree/nvim-tree.lua",
	opts = {
		on_attach = my_on_attach
	}
}
