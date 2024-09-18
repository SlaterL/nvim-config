-- return {
-- 	"ThePrimeagen/harpoon",
-- 	lazy = false,
-- 	dependencies = {
-- 		"nvim-lua/plenary.nvim",
-- 	},
-- 	keys = {
-- 		{ "<leader>ha", "<cmd>lua require('harpoon.mark').add_file()<cr>", desc = "[A]ppend file to harpoon list" },
-- 		{ "L", "<cmd>lua require('harpoon.ui').nav_next()<cr>", desc = "Go to next harpoon mark" },
-- 		{ "H", "<cmd>lua require('harpoon.ui').nav_prev()<cr>", desc = "Go to previous harpoon mark" },
-- 		{ "<leader>hs", "<cmd>lua require('harpoon.ui').toggle_quick_menu()<cr>", desc = "[S]how harpoon list" },
-- 	},
-- 	config = function()
-- 		vim.cmd("highlight! HarpoonActive guibg=NONE")
-- 		vim.cmd("highlight! HarpoonNumberActive guibg=NONE")
-- 		require("harpoon").setup({
-- 			tabline = true,
-- 			tabline_prefix = " ",
-- 			tabline_suffix = " |",
-- 			menu = {
-- 				width = 90,
-- 			},
-- 		})
-- 	end,
-- }

return {
	"cbochs/grapple.nvim",
	opts = {
		scope = "git",
	},
	event = { "BufReadPost", "BufNewFile" },
	cmd = "Grapple",
	keys = {
		{ "<leader>ha", "<cmd>Grapple toggle<cr>", desc = "Grapple toggle tag" },
		{ "<leader>hs", "<cmd>Grapple toggle_tags<cr>", desc = "Grapple open tags window" },
		{ "L", "<cmd>Grapple cycle_tags next<cr>", desc = "Grapple cycle next tag" },
		{ "H", "<cmd>Grapple cycle_tags prev<cr>", desc = "Grapple cycle previous tag" },
	},
}
