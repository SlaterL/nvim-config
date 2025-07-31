local state = {
	floating = {
		buf = -1,
		win = -1,
	},
}
local job_id = 0

local create_floating_window = function(opts)
	opts = opts or {}
	local width = opts.width or math.floor(vim.o.columns * 0.4)
	local height = opts.height or math.floor(vim.o.lines * 0.95)

	local col = math.floor((vim.o.columns - width) - 6)
	local row = math.floor((vim.o.lines - height) / 2)

	local buf = nil
	if vim.api.nvim_buf_is_valid(opts.buf) then
		buf = opts.buf
	else
		buf = vim.api.nvim_create_buf(false, true)
	end

	local win_config = {
		relative = "editor",
		width = width,
		height = height,
		col = col,
		row = row,
		style = "minimal",
		border = "rounded",
	}

	local win = vim.api.nvim_open_win(buf, true, win_config)

	return { buf = buf, win = win }
end

local toggle_terminal = function()
	if not vim.api.nvim_win_is_valid(state.floating.win) then
		state.floating = create_floating_window({ buf = state.floating.buf })
		if vim.bo[state.floating.buf].buftype ~= "terminal" then
			vim.cmd.terminal()
			job_id = vim.bo.channel
		end
		vim.cmd("startinsert")
	else
		vim.api.nvim_win_hide(state.floating.win)
	end
end

vim.api.nvim_create_user_command("Floaterminal", toggle_terminal, {})

vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })
vim.keymap.set({ "n", "t" }, "<C-t>", toggle_terminal, { desc = "[R]un new t[e]rminal" })

-- Function to send a command to the terminal
function SendToTerminal(job, cmd)
	vim.fn.chansend(job, cmd .. "\n")
end

local run_tests = function()
	SendToTerminal(job_id, "gt")
end
local run_precommit = function()
	SendToTerminal(job_id, "pcra")
end
local run_mod_tidy = function()
	SendToTerminal(job_id, "gmt")
end

vim.keymap.set("n", "<leader>rt", run_tests, { desc = "[R]un [t]ests" })
vim.keymap.set("n", "<leader>rm", run_mod_tidy, { desc = "[R]un [t]ests" })
vim.keymap.set("n", "<leader>rp", run_precommit, { desc = "[R]un [t]ests" })
