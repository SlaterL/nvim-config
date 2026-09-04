-- blame.nvim (migrated from lazy.nvim to vim.pack)
vim.pack.add({ "https://github.com/FabijanZulj/blame.nvim" })

require("blame").setup()

vim.keymap.set("n", "<leader>Gb", "<cmd>BlameToggle virtual<cr>", { desc = "Toggle Git Blame" })
