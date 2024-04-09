-- return {
-- 	"f-person/git-blame.nvim",
-- 	keys = {
-- 		{ "<leader>Gb", "<cmd>GitBlameToggle<cr>", desc = "Toggle Git Blame" },
-- 	},
-- }

return {
	"FabijanZulj/blame.nvim",
	keys = {
		{ "<leader>Gb", "<cmd>ToggleBlame virtual<cr>", desc = "Toggle Git Blame" },
	},
}
