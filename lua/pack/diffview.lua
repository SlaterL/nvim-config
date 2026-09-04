-- diffview.nvim (migrated from lazy.nvim to vim.pack)
vim.pack.add({ "https://github.com/sindrets/diffview.nvim" })

vim.keymap.set("n", "<leader>Gdm", "<cmd>DiffviewOpen master<cr>", { desc = "Open Git Diffview" })
vim.keymap.set("n", "<leader>Gdc", "<cmd>DiffviewClose<cr>", { desc = "Close Git Diffview" })
