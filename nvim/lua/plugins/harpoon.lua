return {
	"ThePrimeagen/harpoon",
	branch = "harpoon2",
	dependencies = { "nvim-lua/plenary.nvim" },
	config = function()
		local harpoon = require("harpoon")

		harpoon:setup()

		-- TODO -- filter out nvim_tree from the list
		-- TODO -- make these searchable (figure out how searching even works)
		-- TODO -- make which-key work

		-- add current buffer to the list
		vim.keymap.set("n", "<leader>a", function() harpoon:list():add() end)

		-- list all buffers
		vim.keymap.set("n", "<leader><Tab>", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end)

		-- Toggle previous & next buffers stored within Harpoon list
		vim.keymap.set("n", "<A-h>", function() harpoon:list():prev() end)
		vim.keymap.set("n", "<A-l>", function() harpoon:list():next() end)
	end
}
