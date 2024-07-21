local ffi = require("ffi")

-- Specify the library name based on the platform
--- TOOD Make this work without absolute path
local lib_path = os.getenv("Flashcard_Nvim_Path") or "./target/release/libmy_plugin_lib.so"

-- Load the Rust library
local rust_lib = ffi.load(lib_path)

ffi.cdef([[
    const char* greeting();
]])

print(rust_lib.greeting())

local M = {}
-- TODO

M.addCard = function()
	require("flashcard.popup").open_input_popup("Enter Title")
	-- TODO: get the title and description and use rust to store it
	-- print(title)
	-- print(descricption)
	return "TODO add things"
end

M.study = function()
	--TODO
	return "TODO study things"
end

return M
