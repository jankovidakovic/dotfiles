return {
	"danymat/neogen",
	opts = {
		enabled = true,
		languages = {
			python = {
				template = {
					annotation_convention = "google_docstrings"
				}
			}
		}
	},
	config = function(opts)
		local neogen = require("neogen")
		neogen.setup(opts)

		vim.keymap.set("n", "<leader>ds", neogen.generate)

		-- jumping
		-- TODO -- decide whether insert or normal
		vim.keymap.set({"i", "n"}, "<C-h>", neogen.jump_prev)
		vim.keymap.set({"i", "n"}, "<C-l>", neogen.jump_next)

	end
}
