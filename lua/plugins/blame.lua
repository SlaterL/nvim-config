-- return {
-- 	"f-person/git-blame.nvim",
-- 	keys = {
-- 		{ "<leader>Gb", "<cmd>GitBlameToggle<cr>", desc = "Toggle Git Blame" },
-- 	},
-- }

return {
	"FabijanZulj/blame.nvim",
	config = function()
		require("blame").setup()
	end,
	keys = {
		{ "<leader>Gb", "<cmd>BlameToggle virtual<cr>", desc = "Toggle Git Blame" },
	},
}
