-- nvim-treesitter (migrated from lazy.nvim to vim.pack)
-- NOTE: pinned to the `master` branch. The default branch is now `main`, a
-- rewrite with a different API that lacks `nvim-treesitter.configs.setup`.

-- Replaces lazy `build = ":TSUpdate"`: run TSUpdate on install/update.
-- Registered before vim.pack.add so it fires for a fresh install.
vim.api.nvim_create_autocmd("PackChanged", {
	callback = function(ev)
		if ev.data.spec.name == "nvim-treesitter" and ev.data.kind ~= "delete" then
			vim.schedule(function()
				if vim.fn.exists(":TSUpdate") == 2 then
					vim.cmd("TSUpdate")
				end
			end)
		end
	end,
})

vim.pack.add({
	{ src = "https://github.com/nvim-treesitter/nvim-treesitter", version = "master" },
})

-- [[ Configure Treesitter ]] See `:help nvim-treesitter`
---@diagnostic disable-next-line: missing-fields
require("nvim-treesitter.configs").setup({
	ensure_installed = { "bash", "c", "html", "lua", "markdown", "markdown_inline", "vim", "vimdoc", "go" },
	-- Autoinstall languages that are not installed
	auto_install = true,
	highlight = { enable = true, disable = { "dockerfile" } },
	indent = { enable = true },
})

-- Neovim 0.12 + nvim-treesitter `master` ship conflicting markdown queries.
-- nvim-treesitter's `queries/markdown/injections.scm` shadows Neovim's and uses
-- a custom directive `(#set-lang-from-info-string! @_lang)` whose handler
-- (query_predicates.lua) crashes on 0.12 parsers with
--   treesitter.lua:197 "attempt to call method 'range' (a nil value)".
-- Any fenced code block (e.g. the ```go block in a gopls `K` hover) triggers it,
-- aborting markdown highlighting so hovers render plain/uncolored.
-- Fix: override only the injections query with Neovim's own bundled,
-- directive-free version (highlights are left to nvim-treesitter).
for _, lang in ipairs({ "markdown", "markdown_inline" }) do
	local rel = "queries/" .. lang .. "/injections.scm"
	for _, f in ipairs(vim.api.nvim_get_runtime_file(rel, true)) do
		if vim.env.VIMRUNTIME and f:find(vim.env.VIMRUNTIME, 1, true) then
			vim.treesitter.query.set(lang, "injections", table.concat(vim.fn.readfile(f), "\n"))
			break
		end
	end
end
