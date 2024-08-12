local ffi = require("ffi")

-- Specify the library name based on the platform
--- TOOD Make this work without absolute path
local lib_path = os.getenv("Flashcard_Nvim_Path") or "./target/release/libmy_plugin_lib.so"

-- Load the Rust library
local rust_lib = ffi.load(lib_path)

ffi.cdef([[
    const char* greeting();
    bool add_card(const char* title, const char* description, const char* file_name);
    const char* get_cards(const char* file_name);
    void free_string(const char* s);
]])

local get_file_name = function(path)
	-- Extract the file name from the path
	local file_name = path:match("([^/]+)$")
	-- Remove the extension from the file name, if it exists
	local name_without_extension = file_name:match("(.+)%..+") or file_name
	return name_without_extension
end

local popup = require("plenary.popup")
local title = ""
local description = ""
local window_title = ""
local json_array = {}

-- pick random card
local get_random_card = function(tables)
	-- Check if the table is not empty
	if #tables == 0 then
		return nil
	end

	-- Pick a random index
	local random_index = math.random(1, #tables)

	-- Store the randomly selected table
	local selected_table = tables[random_index]

	-- Remove the selected table from the original table
	table.remove(tables, random_index)

	-- Return the selected table
	return selected_table
end

-- Simple JSON parser for this specific use case
local parse_json = function(json_str)
	local function parse_object()
		local obj = {}
		assert(json_str:sub(1, 1) == "{", "Expected {")
		json_str = json_str:sub(2)
		while json_str:sub(1, 1) ~= "}" do
			assert(json_str:sub(1, 1) == '"', 'Expected "')
			json_str = json_str:sub(2)
			local key = json_str:match('^[^"]+')
			json_str = json_str:sub(#key + 3)
			local value = parse_value()
			obj[key] = value
			if json_str:sub(1, 1) == "," then
				json_str = json_str:sub(2)
			end
		end
		json_str = json_str:sub(2)
		return obj
	end

	local parse_array = function()
		local arr = {}
		assert(json_str:sub(1, 1) == "[", "Expected [")
		json_str = json_str:sub(2)
		while json_str:sub(1, 1) ~= "]" do
			local value = parse_value()
			table.insert(arr, value)
			if json_str:sub(1, 1) == "," then
				json_str = json_str:sub(2)
			end
		end
		json_str = json_str:sub(2)
		return arr
	end

	function parse_value()
		local char = json_str:sub(1, 1)
		if char == '"' then
			json_str = json_str:sub(2)
			local value = json_str:match('^[^"]+')
			json_str = json_str:sub(#value + 2)
			return value
		elseif char == "{" then
			return parse_object()
		elseif char == "[" then
			return parse_array()
		else
			error("Unexpected character: " .. char)
		end
	end

	return parse_value()
end

local M = {}

M.start_study = function()
	local api = vim.api
	local bufnr = api.nvim_win_get_buf(0)
	local file_name = get_file_name(api.nvim_buf_get_name(bufnr))
	local file_path = require("flashcard").get_file_path() .. file_name .. ".json"
	local c_str = rust_lib.get_cards(file_path)
	local json_str = ffi.string(c_str)
	rust_lib.free_string(c_str)
	json_array = parse_json(json_str)
	local first_card = get_random_card(json_array)
	if first_card ~= nil then
		M.open_study_title_popup(first_card.title, first_card.description)
	end
end

M.open_study_title_popup = function(study_title, study_description)
	local buf = vim.api.nvim_create_buf(false, true)
	window_title = study_title

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

	-- print(study_description)

	vim.api.nvim_buf_set_keymap(
		buf,
		"n",
		"<CR>",
		-- ':lua require("flashcard.popup").close_popup_enter(' .. win_id .. ", '..buf..')<CR>",
		':lua require("flashcard.popup").close_popup_study('
			.. win_id
			.. ", "
			.. vim.inspect(study_description)
			.. ")<CR>",
		{ noremap = true, silent = true }
	)
end

M.close_popup_study = function(win_id, study_description)
	vim.api.nvim_win_close(win_id, true)
	if tostring(study_description) ~= "nil" then
		M.open_study_description_popup(study_description)
	else
		local result = get_random_card(json_array)
		if result ~= nil then
			print(result.title .. ": " .. result.description)
			M.open_study_title_popup(result.title, result.description)
		end
	end
end

M.open_study_description_popup = function(study_description)
	local buf = vim.api.nvim_create_buf(false, true)
	window_title = study_description

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

	local str = "nil"

	vim.api.nvim_buf_set_keymap(
		buf,
		"n",
		"<CR>",
		-- ':lua require("flashcard.popup").close_popup_enter(' .. win_id .. ", '..buf..')<CR>",
		':lua require("flashcard.popup").close_popup_study('
			.. win_id
			.. ", "
			.. tostring(str)
			.. ")<CR>",
		{ noremap = true, silent = true }
	)
end

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
		local file_name = get_file_name(api.nvim_buf_get_name(bufnr))
		local file_path = require("flashcard").get_file_path() .. file_name .. ".json"
		-- print(file_path)
		local result = rust_lib.add_card(title, description, file_path)
		if result then
			print("Success")
		end
	end
end

return M
