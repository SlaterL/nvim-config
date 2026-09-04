-- which-key.nvim (migrated from lazy.nvim to vim.pack)
vim.pack.add({ "https://github.com/folke/which-key.nvim" })

require("which-key").setup()

-- Document existing key chains
local wk = require("which-key")
wk.add({
	{ "<leader>s", group = "Search" },
	{ "<leader>c", group = "Code" },
	{ "<leader>p", group = "Replace" },
	{ "<leader>d", group = "Document" },
	{ "<leader>r", group = "Rename" },
	{ "<leader>h", group = "Harpoon" },
	{ "<leader>G", group = "Git" },
	{ "<leader>j", group = "Jump" },
	{ "<leader>w", group = "Workspace" },
})
