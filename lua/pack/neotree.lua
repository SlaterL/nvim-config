-- neo-tree.nvim (migrated from lazy.nvim to vim.pack)
vim.pack.add({
	"https://github.com/nvim-lua/plenary.nvim",
	"https://github.com/nvim-tree/nvim-web-devicons",
	"https://github.com/MunifTanjim/nui.nvim",
	{ src = "https://github.com/nvim-neo-tree/neo-tree.nvim", version = "v3.x" },
})

vim.keymap.set("n", "<leader>e", function()
	require("neo-tree.command").execute({ toggle = true, dir = vim.loop.cwd(), position = "right" })
end, { desc = "Explorer NeoTree (cwd)" })
