--[[

=====================================================================
=====================================================================
=====================================================================
========                                    .-----.          ========
========         .----------------------.   | === |          ========
========         |.-""""""""""""""""""-.|   |-----|          ========
========         ||                    ||   | === |          ========
========         ||     SLATER.NVIM    ||   |-----|          ========
========         ||                    ||   | === |          ========
========         ||                    ||   |-----|          ========
========         ||                    ||   |:::::|          ========
========         |'-..................-'|   |____o|          ========
========         `"")----------------(""`   ___________      ========
========        /::::::::::|  |::::::::::\  \ no mouse \     ========
========       /:::========|  |==hjkl==:::\  \ required \    ========
========      '""""""""""""'  '""""""""""""'  '""""""""""'   ========
========                                                     ========
=====================================================================
=====================================================================

-- ]]
--  NOTE: Must happen before plugins are loaded (otherwise wrong leader will be used)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

require("configs.options")
require("configs.remaps")
require("configs.autocmds")

-- [[ vim.pack-managed plugins ]]
-- Plugins live in lua/pack/, one file per plugin, and are loaded below.

-- Load timing-sensitive plugins eagerly: the colorscheme must be on rtp before
-- the :colorscheme command below, and the dashboard must load before VimEnter so
-- it renders on the startup buffer. (These don't need deferred plugin/ sourcing.)
require("pack.colorscheme")
vim.cmd([[colorscheme moonfly]])
require("pack.dashboard")

-- Load the remaining pack plugins after startup so :packadd sources each
-- plugin's plugin/ files (skipped during startup, which breaks user commands).
-- Already-required modules (colorscheme, dashboard) are cached no-ops here.
vim.schedule(function()
	for _, file in ipairs(vim.fn.globpath(vim.fn.stdpath("config") .. "/lua/pack", "*.lua", false, true)) do
		local mod = "pack." .. vim.fn.fnamemodify(file, ":t:r")
		-- Isolate failures so one broken plugin can't abort loading the rest.
		local ok, err = pcall(require, mod)
		if not ok then
			vim.schedule(function()
				vim.notify(("[pack] failed to load %s: %s"):format(mod, err), vim.log.levels.ERROR)
			end)
		end
	end
end)

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
