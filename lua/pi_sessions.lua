-- Interactive picker for Claude Code sessions in the current working directory.
-- Selecting a session replaces the running claude session in the <C-e> floating
-- terminal via require("piterm").open_session(id).

local M = {}

local SESSIONS_ROOT = vim.fn.expand("~/.claude/projects")

-- Claude Code encodes a session's cwd as the directory name by replacing every
-- non-alphanumeric character with "-".
-- e.g. /Users/me/.config/nvim -> -Users-me--config-nvim
local function encoded_dir(cwd)
	return (cwd:gsub("[^%w]", "-"))
end

-- Human-friendly age of a unix timestamp (e.g. a session file's mtime).
local function relative_time(t)
	local now = os.time()
	local diff = now - t
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

-- Text of a real (human-typed) user or assistant message record, or nil for
-- tool results, meta/injected messages, and slash-command echoes.
local function message_text(rec)
	if (rec.type ~= "user" and rec.type ~= "assistant") or rec.isMeta or rec.isSidechain then
		return nil
	end
	local txt = rec.message and first_text(rec.message.content)
	if not txt or txt:match("^%s*<") then
		return nil
	end
	return txt
end

-- Parse a session .jsonl file: return { id, name, summary }.
-- Sessions without any real user message (e.g. only slash commands) return nil.
local function parse_session(path)
	local info = { path = path, id = vim.fn.fnamemodify(path, ":t:r") }
	local ok, lines = pcall(vim.fn.readfile, path)
	if not ok then
		return nil
	end
	local custom_title, ai_title
	for _, line in ipairs(lines) do
		-- Cheap string checks before decoding; session files can be large.
		local want = line:find('"type":"custom-title"', 1, true)
			or line:find('"type":"ai-title"', 1, true)
			or (not info.summary and line:find('"type":"user"', 1, true))
		if want then
			local decoded, rec = pcall(vim.json.decode, line)
			if decoded and type(rec) == "table" then
				if rec.type == "custom-title" and rec.customTitle then
					custom_title = rec.customTitle
				elseif rec.type == "ai-title" and rec.aiTitle then
					ai_title = rec.aiTitle
				elseif not info.summary and rec.type == "user" then
					local txt = message_text(rec)
					if txt then
						info.summary = txt:gsub("%s+", " "):gsub("^%s+", "")
					end
				end
			end
		end
	end
	if not info.summary then
		return nil
	end
	info.name = custom_title or ai_title
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
	return string.format("%-9s  %s", relative_time(s.mtime), title)
end

-- Build a human-readable preview of a session's first several messages.
local function preview_lines(path)
	local out = {}
	local ok, lines = pcall(vim.fn.readfile, path, "", 400)
	if not ok then
		return { "Could not read session file." }
	end
	local count = 0
	for _, line in ipairs(lines) do
		if count >= 10 then
			break
		end
		if line:find('"type":"user"', 1, true) or line:find('"type":"assistant"', 1, true) then
			local decoded, rec = pcall(vim.json.decode, line)
			local txt = decoded and type(rec) == "table" and message_text(rec)
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
	if #out == 0 then
		out = { "(no messages in this session)" }
	end
	return out
end

-- snacks.nvim picker for Claude sessions.
-- Each item carries a pre-rendered preview so snacks can display it with the
-- built-in "preview" shorthand (same pattern used by codecompanion.nvim).
function M.pick()
	local sessions = M.list()
	if #sessions == 0 then
		vim.notify("No Claude sessions found for " .. vim.fn.getcwd(), vim.log.levels.WARN)
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
		title   = "Claude Sessions (" .. vim.fn.fnamemodify(vim.fn.getcwd(), ":~") .. ")",
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

vim.api.nvim_create_user_command("ClaudeSessions", M.pick, {})
vim.keymap.set("n", "<leader>ps", M.pick, { desc = "Claude [S]ession picker" })
-- Also available inside the claude float (terminal mode).
vim.keymap.set("t", "<C-s>", pick_from_terminal, { desc = "Claude [S]ession picker" })

return M
