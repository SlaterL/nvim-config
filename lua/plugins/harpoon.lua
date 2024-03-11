return {
	"ThePrimeagen/harpoon",
	lazy = false,
	dependencies = {
		"nvim-lua/plenary.nvim",
	},
	keys = {
		{ "<leader>ha", "<cmd>lua require('harpoon.mark').add_file()<cr>", desc = "Append file to harpoon list" },
		{ "L", "<cmd>lua require('harpoon.ui').nav_next()<cr>", desc = "Go to next harpoon mark" },
		{ "H", "<cmd>lua require('harpoon.ui').nav_prev()<cr>", desc = "Go to previous harpoon mark" },
		{ "<leader>hs", "<cmd>lua require('harpoon.ui').toggle_quick_menu()<cr>", desc = "Show harpoon list" },
	},
	config = function()
		vim.cmd("highlight! HarpoonActive guibg=NONE")
		vim.cmd("highlight! HarpoonNumberActive guibg=NONE")
		require("harpoon").setup({
			tabline = true,
			tabline_prefix = " ",
			tabline_suffix = " |",
			menu = {
				width = 90,
			},
		})
	end,
}
