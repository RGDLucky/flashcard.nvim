local M = {}

-- Function to set key mappings
function M.setup()
	local map = vim.api.nvim_set_keymap
	local options = { noremap = true, silent = true }

	-- Example key mappings
	--StudyCards
	map("n", "<leader>mf", ":CreateCard<CR>", options)
	map("n", "<leader>sc", ":StudyCards<CR>", options)
end

return M
