-- alpha-nvim dashboard (migrated from lazy.nvim to vim.pack).
vim.pack.add({ "https://github.com/goolord/alpha-nvim" })

local dashboard = require("alpha.themes.dashboard")
local logo = [[
┌─────────────────────────────────────────────────────────┐
│ ┌─────────────────────────────────────────────────────┐ │
│ │                                                     │ │
│ │                                    .-----.          │ │
│ │         .----------------------.   | === |          │ │
│ │         |.-""""""""""""""""""-.|   |-----|          │ │
│ │         ||                    ||   | === |          │ │
│ │         ||     SLATER.NVIM    ||   |-----|          │ │
│ │         ||                    ||   | === |          │ │
│ │         ||                    ||   |-----|          │ │
│ │         ||                    ||   |:::::|          │ │
│ │         |'-..................-'|   |____o|          │ │
│ │         `"")----------------(""`   ___________      │ │
│ │        /::::::::::|  |::::::::::\  \ no mouse \     │ │
│ │       /:::========|  |==hjkl==:::\  \ required \    │ │
│ │      '""""""""""""'  '""""""""""""'  '""""""""""'   │ │
│ │                                                     │ │
│ └─────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────┘
    ]]
dashboard.section.header.val = vim.split(logo, "\n")
-- stylua: ignore
dashboard.section.buttons.val = {
  dashboard.button("f", " " .. " Find file",       "<cmd> Telescope find_files <cr>"),
  dashboard.button("s", "󰁯  Resume last session", function()
    local project = vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
    require("mini.sessions").read(project)
  end),
  dashboard.button("S", "󰁯  Pick session", function()
    require("mini.sessions").select("read")
  end),
  dashboard.button("n", " " .. " New file",        "<cmd> ene <BAR> startinsert <cr>"),
  dashboard.button("r", " " .. " Recent files",    "<cmd> Telescope oldfiles <cr>"),
  dashboard.button("g", " " .. " Find text",       "<cmd> Telescope live_grep <cr>"),
  dashboard.button("u", "󰚰 " .. " Update plugins",  "<cmd> lua vim.pack.update() <cr>"),
  dashboard.button("q", " " .. " Quit",            "<cmd> qa <cr>"),
}
for _, button in ipairs(dashboard.section.buttons.val) do
	button.opts.hl = "AlphaButtons"
	button.opts.hl_shortcut = "AlphaShortcut"
end
dashboard.section.header.opts.hl = "AlphaHeader"
dashboard.section.buttons.opts.hl = "AlphaButtons"
dashboard.section.footer.opts.hl = "AlphaFooter"
dashboard.opts.layout[1].val = 8

dashboard.section.footer.val = "⚡ slater.nvim"

require("alpha").setup(dashboard.opts)
