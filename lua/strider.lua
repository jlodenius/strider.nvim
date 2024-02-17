local M = {}

-- global variable to keep track of the hover window ID
_G.hover_win_id = nil

vim.api.nvim_create_autocmd("CursorMoved", {
	callback = function()
		if _G.hover_win_id and vim.api.nvim_win_is_valid(_G.hover_win_id) then
			vim.api.nvim_win_close(_G.hover_win_id, true)
			_G.hover_win_id = nil -- Reset the global variable
		end
	end,
})

local function show_custom_hover(message)
	-- close the existing hover window if open
	if _G.hover_win_id and vim.api.nvim_win_is_valid(_G.hover_win_id) then
		vim.api.nvim_win_close(_G.hover_win_id, true)
	end

	-- create a buffer to show in hover
	local bufnr = vim.api.nvim_create_buf(false, true)
	local lines = { message }
	local width = #message
	local height = 1
	local opts = {
		style = "minimal",
		border = "single",
		relative = "cursor",
		width = width,
		height = height,
		row = 1,
		col = 0,
	}
	vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)

	-- display buffer and save the window ID to a global variable
	_G.hover_win_id = vim.api.nvim_open_win(bufnr, false, opts)
end

local function to_binary(num)
	local bin = {}
	while num > 0 do
		local rest = num % 2
		table.insert(bin, 1, rest)
		num = math.floor(num / 2)
	end
	return table.concat(bin)
end

-- check if the cursor is on a number and display its binary representation
function M.dec_to_bin()
	local current_word = vim.fn.expand("<cword>")
	local num = tonumber(current_word)
	if num then
		local binary_repr = to_binary(num)
		show_custom_hover(current_word .. " as binary: " .. binary_repr)
	else
		-- default to the LSP hover to enable using the same hotkey
		vim.lsp.buf.hover()
	end
end

return M
