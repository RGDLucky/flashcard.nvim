-- local ffi = require("ffi")

-- -- Specify the library name based on the platform
-- --- TOOD Make this work without absolute path
-- local lib_path = os.getenv("Flashcard_Nvim_Path") or "./target/release/libmy_plugin_lib.so"
--
-- -- Load the Rust library
-- local rust_lib = ffi.load(lib_path)
--
-- ffi.cdef([[
--     const char* greeting();
--     bool add_card(const char* title, const char* description, const char* file_name);
-- ]])
--
-- print(rust_lib.greeting())

local file_path = ""

local M = {}

-- TODO: fix this
M.setup = function(config)
	file_path = config.file_path or "./"
end

M.addCard = function()
	-- Get file name
	-- local api = vim.api
	-- local bufnr = api.nvim_win_get_buf(0)
	-- local file_name = api.nvim_buf_get_name(bufnr)
	-- print("Current file: " .. file_name)

	-- Use gui to get title and description
	require("flashcard.popup").open_input_popup("Enter Title")
	print(file_path)
	-- print(title)
	-- print(descricption)

	-- TODO: get the title and description and use rust to store it
	-- TODO: figure out how to make the passing of strings work
	-- local title = "" -- TODO get title
	-- local description = "" -- TODO get description
	-- local c_string_title = ffi.new("char[?]", #title + 1)
	-- local c_string_description = ffi.new("char[?]", #description + 1)
	--
	-- local result = rust_lib.add_card(c_string_title, c_string_description, file_name)

	-- local title = require("flashcard.popup").get_title()
	-- local description = require("flashcard.popup").get_title()
	-- local result = rust_lib.add_card(title, description, file_name)
	-- if result then
	-- 	print("Success")
	-- end
	return "TODO add things"
end

M.study = function()
	--TODO
	return "TODO study things"
end

return M
