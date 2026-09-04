-- todo-comments.nvim (migrated from lazy.nvim to vim.pack)
vim.pack.add({
	"https://github.com/nvim-lua/plenary.nvim",
	"https://github.com/folke/todo-comments.nvim",
})

require("todo-comments").setup({ signs = false })
