-- Creating commands and keymaps for the plugin
local commands = require("flashcard")
-- local dependencies = require("flashcard.dependencies")

vim.api.nvim_create_user_command("CreateCard", commands.addCard, {})
vim.api.nvim_create_user_command("StudyCards", commands.study, {})

local keymaps = require("flashcard.keymaps")
keymaps.setup()
-- dependencies.setup()

--- TOOD Make this work....
-- local ffi = require("ffi")
-- -- local path_to_lib = package.searchpath("lua/rust_flashcard/release/librust_flashcard", package.cpath)
-- local path_to_lib = "lua/rust_flashcard/release/librust_flashcard.dylib"
-- print("sheeshhh", path_to_lib)
-- local rustlib = ffi.load(path_to_lib)
--
-- ffi.cdef([[
--     String greeting();
-- ]])
--
-- print(rustlib.greeting())
