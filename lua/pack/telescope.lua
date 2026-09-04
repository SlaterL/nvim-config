-- telescope.nvim + deps (migrated from lazy.nvim to vim.pack)

local has_make = vim.fn.executable("make") == 1

-- Replaces lazy `build = "make"` for telescope-fzf-native: compile on install/update.
-- Non-blocking: PackChanged fires inside vim.pack's async loop, so we must not
-- block there. Schedule the build, then load the fzf extension once it succeeds.
vim.api.nvim_create_autocmd("PackChanged", {
	callback = function(ev)
		if ev.data.spec.name == "telescope-fzf-native.nvim" and ev.data.kind ~= "delete" then
			local path = ev.data.path
			vim.schedule(function()
				vim.system({ "make" }, { cwd = path }, function(out)
					if out.code == 0 then
						vim.schedule(function()
							pcall(require("telescope").load_extension, "fzf")
						end)
					end
				end)
			end)
		end
	end,
})

local specs = {
	-- Hard dependency. Other plugins still lazy-load their own plenary; providing
	-- it here puts it on rtp so telescope (no longer lazy-managed) can require it.
	"https://github.com/nvim-lua/plenary.nvim",
	{ src = "https://github.com/nvim-telescope/telescope.nvim", version = "0.1.x" },
	"https://github.com/nvim-telescope/telescope-ui-select.nvim",
	-- Was lazy `version = "^1.0.0"` (no breaking major bumps).
	{
		src = "https://github.com/nvim-telescope/telescope-live-grep-args.nvim",
		version = vim.version.range("1"),
	},
}
-- Was lazy `cond = executable("make")`.
if has_make then
	table.insert(specs, "https://github.com/nvim-telescope/telescope-fzf-native.nvim")
end

vim.pack.add(specs)

-- [[ Configure Telescope ]] See `:help telescope` and `:help telescope.setup()`
require("telescope").setup({
	defaults = {
		-- Disable treesitter highlighting in the preview window.
		-- Workaround for an intermittent crash on Neovim 0.12 with the EOL
		-- nvim-treesitter `master` branch: fast preview updates race the async
		-- injection parse and hand the highlighter a nil node
		-- (treesitter.lua:197 "attempt to call method 'range' (a nil value)").
		preview = { treesitter = { disable = { "markdown" } } },
	},
	extensions = {
		["ui-select"] = {
			require("telescope.themes").get_dropdown(),
		},
		fzf = {},
	},
})

-- Enable telescope extensions, if they are installed
pcall(require("telescope").load_extension, "fzf")
pcall(require("telescope").load_extension, "ui-select")
pcall(require("telescope").load_extension, "live_grep_args")

-- See `:help telescope.builtin`
local builtin = require("telescope.builtin")
vim.keymap.set("n", "<leader>sh", builtin.help_tags, { desc = "[S]earch [H]elp" })
vim.keymap.set("n", "<leader>sk", builtin.keymaps, { desc = "[S]earch [K]eymaps" })
vim.keymap.set("n", "<leader>sf", builtin.find_files, { desc = "[S]earch [F]iles" })
vim.keymap.set("n", "<leader>sw", builtin.grep_string, { desc = "[S]earch current [W]ord" })
vim.keymap.set(
	"n",
	"<leader>sg",
	require("telescope").extensions.live_grep_args.live_grep_args,
	{ desc = "[S]earch by [G]rep" }
)
vim.keymap.set("n", "<leader>sd", builtin.diagnostics, { desc = "[S]earch [D]iagnostics" })
vim.keymap.set("n", "<leader>sr", builtin.resume, { desc = "[S]earch [R]esume" })

-- Git
vim.keymap.set("n", "<leader>Gc", "<cmd>Telescope git_commits<CR>", { desc = "[G]it [C]ommits" })
vim.keymap.set("n", "<leader>Gs", "<cmd>Telescope git_status<CR>", { desc = "[G]it [S]tatus" })

-- Slightly advanced example of overriding default behavior and theme
vim.keymap.set("n", "<leader>si", function()
	builtin.current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
		winblend = 10,
		previewer = true,
	}))
end, { desc = "[S]earch [I]nside the current file" })
