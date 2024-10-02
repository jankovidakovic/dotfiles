--  this file was crated by referencing the documentation at : https://lazy.folke.io/installation
--
-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
	spec = {
		import = "plugins"  -- this will import the `plugins` 
	},
	install = { colorscheme = { "gruvbox" } },
	-- disable the checker (annoyingly checks for updates on every startup)
	-- checker = { enabled = true },  -- this doesnt install the updates, only checks for updates (which is fine)
	-- its also possible that we wanna commit lazy-lock.json in order to lock the plugin versions
})
