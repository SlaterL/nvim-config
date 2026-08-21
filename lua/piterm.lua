-- Reusable module that manages the floating "pi" terminal.
-- Used by plugin/termterm.lua (<C-e> toggle) and lua/pi_sessions.lua (session picker).

local M = {}

local state = {
	buf = -1,
	win = -1,
	job = 0,
}

local function win_config()
	local width = math.floor(vim.o.columns * 0.4)
	local height = math.floor(vim.o.lines * 0.95)
	local col = math.floor((vim.o.columns - width) - 6)
	local row = math.floor((vim.o.lines - height) / 2)
	return {
		relative = "editor",
		width = width,
		height = height,
		col = col,
		row = row,
		style = "minimal",
		border = "rounded",
	}
end

local function open_window(buf)
	return vim.api.nvim_open_win(buf, true, win_config())
end

-- Start pi in a fresh terminal buffer inside the current window.
local function start_pi(cmd)
	vim.cmd.terminal()
	state.buf = vim.api.nvim_get_current_buf()
	state.job = vim.bo.channel
	vim.fn.chansend(state.job, cmd .. "\n")
end

-- Toggle the pi terminal window (mirrors the original <C-e> behavior).
function M.toggle()
	if vim.api.nvim_win_is_valid(state.win) then
		vim.api.nvim_win_hide(state.win)
		return
	end

	if vim.api.nvim_buf_is_valid(state.buf) and vim.bo[state.buf].buftype == "terminal" then
		-- Reuse the existing pi terminal.
		state.win = open_window(state.buf)
	else
		state.win = open_window(vim.api.nvim_create_buf(false, true))
		start_pi("pi")
	end
	vim.cmd("startinsert")
end

-- Replace whatever is in the pi terminal with a fresh `pi` invocation.
-- `extra_args` is an optional string appended to the `pi` command.
function M.open_with(extra_args)
	if vim.api.nvim_win_is_valid(state.win) then
		vim.api.nvim_win_hide(state.win)
	end
	if vim.api.nvim_buf_is_valid(state.buf) then
		vim.api.nvim_buf_delete(state.buf, { force = true })
	end
	state.buf = -1

	state.win = open_window(vim.api.nvim_create_buf(false, true))
	local cmd = "pi"
	if extra_args and extra_args ~= "" then
		cmd = cmd .. " " .. extra_args
	end
	start_pi(cmd)
	vim.cmd("startinsert")
end

-- Replace the pi terminal with a specific resumed session.
function M.open_session(id)
	M.open_with("--session " .. vim.fn.shellescape(id))
end

return M
