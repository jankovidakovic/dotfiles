-- Set <space> as the leader key
-- See `:help mapleader`
--  NOTE: Must happen before plugins are loaded (otherwise wrong leader will be used)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

require("config.basicOptions")
require("config.keymaps")
require("config.autocmds")
require("config.lazy") -- this kinda requires and installs all the plugins

-- okay lets set up a colorscheme next
vim.o.background = "dark"
vim.cmd "colorscheme gruvbox"
