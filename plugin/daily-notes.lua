local M = {}

local state = {
	floating = {
		buf = -1,
		win = -1,
	},
}

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

-- ====== CONFIG ======
local VAULT_PATH = vim.fn.expand("~/Documents/Obsidian/main")
local DAILY_FOLDER = "daily"

-- ====== HELPERS ======
local function get_today_filename()
	return os.date("%Y-%m-%d") .. ".md"
end

local function ensure_daily_note_exists(filepath)
	if vim.fn.filereadable(filepath) == 0 then
		vim.fn.mkdir(vim.fn.fnamemodify(filepath, ":h"), "p")

		local header = {
			"# " .. os.date("%A, %B %d, %Y"),
			"",
			"## Tasks",
			"",
			"- [ ] ",
			"",
			"## Notes",
			"",
		}

		vim.fn.writefile(header, filepath)
	end
end

-- ====== MAIN FUNCTION ======
function M.open_daily()
	local filename = get_today_filename()
	local filepath = VAULT_PATH .. "/" .. DAILY_FOLDER .. "/" .. filename

	ensure_daily_note_exists(filepath)

	-- Reuse window if valid
	if vim.api.nvim_win_is_valid(state.floating.win) then
		vim.api.nvim_set_current_win(state.floating.win)
		vim.cmd("edit " .. filepath)
		return
	end

	local floating = create_floating_window({
		buf = state.floating.buf,
	})

	state.floating.buf = floating.buf
	state.floating.win = floating.win

	vim.api.nvim_win_set_option(floating.win, "wrap", true)

	vim.api.nvim_buf_set_option(floating.buf, "bufhidden", "wipe")
	vim.api.nvim_buf_set_option(floating.buf, "filetype", "markdown")

	vim.cmd("edit " .. filepath)
end

vim.keymap.set("n", "<leader>N", function()
	M.open_daily()
end, { desc = "Open Daily Note" })
