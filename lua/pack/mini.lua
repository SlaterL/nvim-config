-- mini.nvim (migrated from lazy.nvim to vim.pack)
vim.pack.add({ "https://github.com/echasnovski/mini.nvim" })

-- Better Around/Inside textobjects (va), yinq, ci', ...)
require("mini.ai").setup({ n_lines = 500 })

-- Add/delete/replace surroundings (saiw), sd', sr)', ...)
require("mini.surround").setup()

require("mini.pairs").setup()

require("mini.sessions").setup({
	autoread = false,
	autowrite = true,
	directory = vim.fn.stdpath("data") .. "/sessions",
})

local function project()
	return vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
end

vim.keymap.set("n", "<leader>Ss", function()
	require("mini.sessions").write(project())
end, { desc = "[S]ession [S]ave" })

vim.keymap.set("n", "<leader>sr", function()
	require("mini.sessions").read(project())
end, { desc = "[S]ession [R]esume" })

vim.keymap.set("n", "<leader>SR", function()
	require("mini.sessions").select("read")
end, { desc = "[S]ession [R]esume (pick)" })

vim.keymap.set("n", "<leader>Sd", function()
	require("mini.sessions").delete(project())
end, { desc = "[S]ession [D]elete" })

vim.keymap.set("n", "<leader>SD", function()
	require("mini.sessions").select("delete")
end, { desc = "[S]ession [D]elete (pick)" })
