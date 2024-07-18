local popup = require("plenary.popup")

local M = {}

M.open_popup = function()
	local buf = vim.api.nvim_create_buf(false, true)

	local win_id = popup.create(buf, {
		title = "My Popup",
		highlight = "Normal",
		line = math.floor((vim.o.lines - 10) / 2),
		col = math.floor((vim.o.columns - 40) / 2),
		minwidth = 40,
		minheight = 10,
		border = true,
	})

	-- Set the buffer content
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "This is a popup window!", "", "Press 'q' to close." })

	-- Set keymap to close the popup with 'q'
	vim.api.nvim_buf_set_keymap(
		buf,
		"n",
		"q",
		':lua require("flashcard.popup").close_popup(' .. win_id .. ")<CR>",
		{ noremap = true, silent = true }
	)

	-- Focus the popup window
	vim.api.nvim_set_current_win(win_id)
end

M.close_popup = function(win_id)
	vim.api.nvim_win_close(win_id, true)
end
return M
