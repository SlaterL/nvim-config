-- hop.nvim (migrated from lazy.nvim to vim.pack)
vim.pack.add({ "https://github.com/smoka7/hop.nvim" })

require("hop").setup()

vim.keymap.set("n", "<leader>jw", "<cmd>HopWord<cr>", { desc = "[J]ump [W]ord", noremap = true })
vim.keymap.set("n", "<leader>jl", "<cmd>HopLineStart<cr>", { desc = "[J]ump [L]ine", noremap = true })
