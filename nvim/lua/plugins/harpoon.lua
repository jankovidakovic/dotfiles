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

		-- how to remove from list tho

		-- list all buffers
		vim.keymap.set("n", "<leader><Tab>", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end)

		vim.keymap.set("n", "<C-h>", function() harpoon:list():select(1) end)
		vim.keymap.set("n", "<C-t>", function() harpoon:list():select(2) end)
		vim.keymap.set("n", "<C-n>", function() harpoon:list():select(3) end)
		vim.keymap.set("n", "<C-s>", function() harpoon:list():select(4) end)

		-- Toggle previous & next buffers stored within Harpoon list
		vim.keymap.set("n", "<A-h>", function() harpoon:list():prev() end)
		vim.keymap.set("n", "<A-l>", function() harpoon:list():next() end)
	end
}
