local ffi = require("ffi")

-- Specify the library name based on the platform
--- TOOD Make this work without absolute path
local lib_path = os.getenv("Flashcard_Nvim_Path") or "./target/release/libmy_plugin_lib.so"

-- Load the Rust library
local rust_lib = ffi.load(lib_path)

ffi.cdef([[
    const char* greeting();
    bool add_card(const char* title, const char* description, const char* file_name);
]])

print(rust_lib.greeting())

local popup = require("plenary.popup")
local title = ""
local description = ""
local window_title = ""

local M = {}

M.open_input_popup = function(window_title_input)
	local buf = vim.api.nvim_create_buf(false, true)
	window_title = window_title_input

	local win_id = popup.create(buf, {
		title = window_title,
		highlight = "Normal",
		line = math.floor((vim.o.lines - 10) / 2),
		col = math.floor((vim.o.columns - 40) / 2),
		minwidth = 40,
		minheight = 10,
		border = true,
	})

	-- Set input box
	vim.api.nvim_buf_set_lines(buf, 0, 10, false, { "" })

	-- Set keymap to close the popup with 'q'
	vim.api.nvim_buf_set_keymap(
		buf,
		"n",
		"q",
		':lua require("flashcard.popup").close_popup(' .. win_id .. ")<CR>",
		{ noremap = true, silent = true }
	)

	-- Set keymap to close the popup with 'q'
	vim.api.nvim_buf_set_keymap(
		buf,
		"n",
		"q",
		-- "<enter>",
		':lua require("flashcard.popup").close_popup_q('
			.. win_id
			.. ")<CR>",
		{ noremap = true, silent = true }
	)
	vim.api.nvim_buf_set_keymap(
		buf,
		"n",
		"<CR>",
		-- ':lua require("flashcard.popup").close_popup_enter(' .. win_id .. ", '..buf..')<CR>",
		':lua require("flashcard.popup").close_popup_enter('
			.. win_id
			.. ", "
			.. buf
			.. ")<CR>",
		{ noremap = true, silent = true }
	)
	-- Focus the popup window
	vim.api.nvim_set_current_win(win_id)
end

M.close_popup_q = function(win_id)
	vim.api.nvim_win_close(win_id, true)
	title = ""
	description = ""
end

M.close_popup_enter = function(win_id, buf)
	local lines = vim.api.nvim_buf_get_lines(buf, 0, 10, false)
	if window_title == "Enter Title" then
		title = lines[1]
	else
		description = lines[1]
	end

	vim.api.nvim_win_close(win_id, true)
	if window_title == "Enter Title" then
		M.open_input_popup("Enter Description")
	else
		local api = vim.api
		local bufnr = api.nvim_win_get_buf(0)
		local file_name = api.nvim_buf_get_name(bufnr)
		local result = rust_lib.add_card(title, description, file_name)
		if result then
			print("Success")
		end
	end
end

M.get_title = function()
	local result = title
	title = ""
	return result
end

M.get_description = function()
	local result = description
	description = ""
	return result
end

return M
