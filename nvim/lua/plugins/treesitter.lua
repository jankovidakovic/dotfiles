return {
	"nvim-treesitter/nvim-treesitter",
	build = ":TSUpdate",
	opts = {
		ensure_installed = {
			"lua",
			"vimdoc",
			"python",
			"markdown",
			"markdown_inline",
			"bash",
			"javascript",
			"typescript",
			"html",
			"css",
			"scss",
			"json",
		},
		sync_install = true,
		highlight = { enable = true },
		indent = { enable = true },
	},
}
