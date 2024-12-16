local map = vim.keymap.set

map("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- Diagnostic keymaps
map("n", "[d", vim.diagnostic.goto_prev, { desc = "Go to previous [D]iagnostic message" })
map("n", "]d", vim.diagnostic.goto_next, { desc = "Go to next [D]iagnostic message" })
map("n", "<leader>e", vim.diagnostic.open_float, { desc = "Show diagnostic [E]rror messages" })
map("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfix list" })

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
-- is not what someone will guess without a bit more experience.
--
-- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
-- or just use <C-\><C-n> to exit terminal mode
map("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })
map("t", "<C-t>", "<cmd>ToggleTerm<CR>", { desc = "Exit terminal mode" })
-- TIP: Disable arrow keys in normal mode
-- vim.keymap.set('n', '<left>', '<cmd>echo "Use h to move!!"<CR>')
-- vim.keymap.set('n', '<right>', '<cmd>echo "Use l to move!!"<CR>')
-- vim.keymap.set('n', '<up>', '<cmd>echo "Use k to move!!"<CR>')
-- vim.keymap.set('n', '<down>', '<cmd>echo "Use j to move!!"<CR>')

-- Keybinds to make split navigation easier.
--  Use CTRL+<hjkl> to switch between windows
--
--  See `:help wincmd` for a list of all window commands
map("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
map("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })
map("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
map("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" })

-- Keybinds for saving a file
map({ "i", "x", "n", "s" }, "<C-s>", "<cmd>w<cr><esc>", { desc = "Save file" })

-- Move lines up or down by one
map("v", "J", ":m '>+1<CR>gv=gv")
map("v", "K", ":m '<-2<CR>gv=gv")

map("i", "<A-b>", "<ESC>^i", { desc = "Move Beginning of line" })
map("i", "<A-e>", "<End>", { desc = "Move End of line" })
map("i", "<A-h>", "<Left>", { desc = "Move Left", noremap = true })
map("i", "<A-l>", "<Right>", { desc = "Move Right" })
map("i", "<A-j>", "<Down>", { desc = "Move Down" })
map("i", "<A-k>", "<Up>", { desc = "Move Up" })

map("n", "J", "<cmd>lua vim.diagnostic.open_float()<cr>")
map("n", "<leader>st", "<cmd>TodoTelescope<cr>", { desc = "[S]earch [T]odo list" })

map("v", "<", "<gv")
map("v", ">", ">gv")

map("n", "_", "<cmd>LspRestart<cr>")

map("n", "<C-]>", "<cmd>cnext<CR>zz")
map("n", "<C-[>", "<cmd>cprev<CR>zz")

map("n", "<leader>pw", [[:%s/<C-r><C-w>//gc<Left><Left><Left>]], { desc = "Find and Re[p]lace" })
map("n", "<leader>pp", [[:%s///gc<Left><Left><Left><Left>]], { desc = "Find and Re[p]lace" })

map("n", "d", '"_d', { desc = "Better Del", noremap = true })
