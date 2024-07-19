--- TOOD Make this work....
local ffi = require("ffi")
-- local path_to_lib = package.searchpath("lua/rust_flashcard/release/librust_flashcard", package.cpath)
-- local path_to_lib = "../../rust_flashcard/target/release/librust_flashcard.dylib"
-- print("sheeshhh", path_to_lib)
-- local rustlib = ffi.load(path_to_lib)
-- local lib_extension = package.cpath:match("%p[\\|/]?%p(%a+)")
-- local lib_name = ("../../rust_flashcard/target/release/librust_flashcard." .. lib_extension)
-- local lib_name = "../../lua/rust_flashcard/target/release/librust_flashcard.dylib"
--
-- local rust_lib = ffi.load(lib_name)

-- Specify the library name based on the platform
--[[
local platform = jit.os:lower() -- Get the current platform (lowercased)
local lib_name = nil

if platform == "linux" then
	lib_name = "../../rust_flashcard/target/release/librust_flashcard.so"
elseif platform == "macosx" or platform == "osx" then
	lib_name = "../../rust_flashcard/target/release/librust_flashcard.dylib"
elseif platform == "windows" then
	lib_name = "../../rust_flashcard/target/release/librust_flashcard.dll"
else
	error("Unsupported platform: " .. platform)
end

-- Load the Rust library
local rust_lib = ffi.load(lib_name)

ffi.cdef([[
    String greeting();

--]]
-- ]])

-- print(rust_lib.greeting())

local M = {}
-- TODO

M.addCard = function()
	--local title = require("flashcard.popup").open_input_popup("Enter Title")
	-- local descricption = require("flashcard.popup").open_input_popup("Enter Descricption")
	--TODO: need to have the window popup after the fist one
	require("flashcard.popup").open_input_popup("Enter Title")
	-- print(title)
	-- print(descricption)
	return "TODO add things"
end

M.study = function()
	--TODO
	return "TODO study things"
end

return M
