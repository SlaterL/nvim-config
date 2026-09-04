-- grapple.nvim (migrated from lazy.nvim to vim.pack)
vim.pack.add({
	"https://github.com/cbochs/grapple.nvim",
})

require("grapple").setup({
	scope = "git",
})

local map = vim.keymap.set
map("n", "<leader>ha", "<cmd>Grapple toggle<cr>", { desc = "Grapple toggle tag" })
map("n", "<leader>hs", "<cmd>Grapple toggle_tags<cr>", { desc = "Grapple open tags window" })
map("n", "L", "<cmd>Grapple cycle_tags next<cr>", { desc = "Grapple cycle next tag" })
map("n", "H", "<cmd>Grapple cycle_tags prev<cr>", { desc = "Grapple cycle previous tag" })
