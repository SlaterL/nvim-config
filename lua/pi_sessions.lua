-- Interactive picker for pi sessions in the current working directory.
-- Selecting a session replaces the running pi session in the <C-e> floating
-- terminal via require("piterm").open_session(id).

local M = {}

local SESSIONS_ROOT = vim.fn.expand("~/.pi/agent/sessions")

-- pi encodes a session's cwd as the directory name by replacing "/" with "-"
-- and wrapping the whole thing in leading/trailing "--".
-- e.g. /Users/me/.config/nvim -> --Users-me-.config-nvim--
local function encoded_dir(cwd)
	return "-" .. cwd:gsub("/", "-") .. "--"
end

local function relative_time(ts)
	-- ts like 2026-08-21T16-25-02-323Z (from filename) or ISO with ":" (from record)
	local y, mo, d, h, mi = ts:match("(%d+)%D(%d+)%D(%d+)%D(%d+)%D(%d+)")
	if not y then
		return ts
	end
	local t = os.time({
		year = tonumber(y),
		month = tonumber(mo),
		day = tonumber(d),
		hour = tonumber(h),
		min = tonumber(mi),
		sec = 0,
	})
	local diff = os.time() - t
	if diff < 60 then
		return "just now"
	elseif diff < 3600 then
		return math.floor(diff / 60) .. "m ago"
	elseif diff < 86400 then
		return math.floor(diff / 3600) .. "h ago"
	elseif diff < 86400 * 7 then
		return math.floor(diff / 86400) .. "d ago"
	else
		return os.date("%Y-%m-%d", t)
	end
end

local function first_text(content)
	if type(content) == "string" then
		return content
	end
	if type(content) == "table" then
		for _, part in ipairs(content) do
			if part.type == "text" and part.text then
				return part.text
			end
		end
	end
	return nil
end

-- Parse a session .jsonl file: return { id, name, timestamp, summary }.
local function parse_session(path)
	local info = { path = path }
	local ok, lines = pcall(vim.fn.readfile, path, "", 60)
	if not ok then
		return nil
	end
	for _, line in ipairs(lines) do
		if line ~= "" then
			local decoded, rec = pcall(vim.json.decode, line)
			if decoded and type(rec) == "table" then
				if rec.type == "session" then
					info.id = rec.id
					info.timestamp = rec.timestamp
					info.name = rec.name
				elseif rec.name and not info.name then
					info.name = rec.name
				elseif not info.summary and rec.type == "message" and rec.message and rec.message.role == "user" then
					local txt = first_text(rec.message.content)
					if txt then
						txt = txt:gsub("%s+", " "):gsub("^%s+", "")
						info.summary = txt
					end
				end
			end
		end
	end
	if not info.id then
		-- Fall back to the UUID embedded in the filename.
		info.id = vim.fn.fnamemodify(path, ":t"):match("_([%x%-]+)%.jsonl$")
	end
	if not info.timestamp then
		info.timestamp = vim.fn.fnamemodify(path, ":t"):match("^([%dTZ%-]+)_") or ""
	end
	return info
end

-- Collect and sort (newest first) all sessions for the given cwd.
function M.list(cwd)
	cwd = cwd or vim.fn.getcwd()
	local dir = SESSIONS_ROOT .. "/" .. encoded_dir(cwd)
	local sessions = {}
	local files = vim.fn.glob(dir .. "/*.jsonl", true, true)
	for _, path in ipairs(files) do
		local info = parse_session(path)
		if info and info.id then
			info.mtime = vim.fn.getftime(path)
			table.insert(sessions, info)
		end
	end
	table.sort(sessions, function(a, b)
		return a.mtime > b.mtime
	end)
	return sessions
end

local function display_label(s)
	local title = s.name or s.summary or "(no messages)"
	return string.format("%-9s  %s", relative_time(s.timestamp), title)
end

-- Build a human-readable preview of a session's first several messages.
local function preview_lines(path)
	local out = {}
	local ok, lines = pcall(vim.fn.readfile, path, "", 200)
	if not ok then
		return { "Could not read session file." }
	end
	local count = 0
	for _, line in ipairs(lines) do
		if line ~= "" and count < 10 then
			local decoded, rec = pcall(vim.json.decode, line)
			if decoded and type(rec) == "table" and rec.type == "message" and rec.message then
				local txt = first_text(rec.message.content)
				if txt then
					table.insert(out, "### " .. tostring(rec.message.role))
					for _, l in ipairs(vim.split(txt, "\n", { plain = true })) do
						table.insert(out, l)
					end
					table.insert(out, "")
					count = count + 1
				end
			end
		end
	end
	if #out == 0 then
		out = { "(no messages in this session)" }
	end
	return out
end

-- snacks.nvim picker for pi sessions.
-- Each item carries a pre-rendered preview so snacks can display it with the
-- built-in "preview" shorthand (same pattern used by codecompanion.nvim).
function M.pick()
	local sessions = M.list()
	if #sessions == 0 then
		vim.notify("No pi sessions found for " .. vim.fn.getcwd(), vim.log.levels.WARN)
		return
	end

	local items = vim.tbl_map(function(s)
		return {
			-- 'text' drives fuzzy filtering in the picker.
			text    = display_label(s),
			session = s,
			-- snacks reads item.preview when preview = "preview" is set.
			preview = { text = table.concat(preview_lines(s.path), "\n"), ft = "markdown" },
		}
	end, sessions)

	Snacks.picker({
		title   = "Pi Sessions (" .. vim.fn.fnamemodify(vim.fn.getcwd(), ":~") .. ")",
		items   = items,
		preview = "preview",
		format  = function(item) return { { item.text } } end,
		confirm = function(picker, item)
			picker:close()
			if item then
				require("piterm").open_session(item.session.id)
			end
		end,
	})
end

-- Open the picker; when called from terminal mode, drop to normal mode first
-- so the snacks picker floating window behaves correctly.
local function pick_from_terminal()
	vim.cmd("stopinsert")
	vim.schedule(M.pick)
end

vim.api.nvim_create_user_command("PiSessions", M.pick, {})
vim.keymap.set("n", "<leader>ps", M.pick, { desc = "[P]i [S]ession picker" })
-- Also available inside the pi float (terminal mode).
vim.keymap.set("t", "<C-s>", pick_from_terminal, { desc = "[P]i [S]ession picker" })

return M
