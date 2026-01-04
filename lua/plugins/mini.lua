return { -- Collection of various small independent plugins/modules
	"echasnovski/mini.nvim",
	config = function()
		-- Better Around/Inside textobjects
		--
		-- Examples:
		--  - va)  - [V]isually select [A]round [)]parenthen
		--  - yinq - [Y]ank [I]nside [N]ext [']quote
		--  - ci'  - [C]hange [I]nside [']quote
		require("mini.ai").setup({ n_lines = 500 })

		-- Add/delete/replace surroundings (brackets, quotes, etc.)
		--
		-- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
		-- - sd'   - [S]urround [D]elete [']quotes
		-- - sr)'  - [S]urround [R]eplace [)] [']
		require("mini.surround").setup()

		-- Simple and easy statusline.
		--  You could remove this setup call if you don't like it,
		--  and try some other statusline plugin
		-- local statusline = require("mini.statusline")
		-- statusline.setup()
		--
		-- -- You can confiure sections in the statusline by overriding their
		-- -- default behavior. For example, here we disable the section for
		-- -- cursor information because line numbers are already enabled
		-- ---@diagnostic disable-next-line: duplicate-set-field
		-- statusline.section_location = function()
		-- 	return ""
		-- end

		-- ... and there is more!
		--  Check out: https://github.com/echasnovski/mini.nvim
		require("mini.pairs").setup()

		-- require("mini.snippets").setup({
		-- 	snippets = {
		-- 		-- Load custom file with global snippets first (adjust for Windows)
		-- 		-- gen_loader.from_file("~/.config/nvim/snippets/global.json"),
		--
		-- 		require("mini.snippets").gen_loader.from_lang(),
		-- 	},
		-- 	mappings = {
		-- 		expand = "<C-j>",
		-- 	},
		-- })

		require("mini.sessions").setup({
			autoread = false,
			autowrite = true,
			directory = vim.fn.stdpath("data") .. "/sessions",
		})
		local function project()
			return vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
		end

		vim.keymap.set("n", "<leader>ss", function()
			require("mini.sessions").write(project())
		end, { desc = "[S]ession [S]ave" })

		vim.keymap.set("n", "<leader>sr", function()
			require("mini.sessions").read(project())
		end, { desc = "[S]ession [R]esume" })

		vim.keymap.set("n", "<leader>sR", function()
			require("mini.sessions").select("read")
		end, { desc = "[S]ession [R]esume (pick)" })

		vim.keymap.set("n", "<leader>sd", function()
			require("mini.sessions").delete(project())
		end, { desc = "[S]ession [D]elete" })

		vim.keymap.set("n", "<leader>sD", function()
			require("mini.sessions").select("delete")
		end, { desc = "[S]ession [D]elete (pick)" })
	end,
}
