local api = vim.api

-- NOTE: if no pattern is set, pattern will be set to "*"

---@param name string
local augroup = function(name)
	api.nvim_create_augroup(name, { clear = true })
end

-- FIXME
api.nvim_create_autocmd("TextYankPost", {
	group = augroup "YankHighlight",
	callback = function()
		vim.highlight.on_yank {
			higroup = "Substitute",
		}
	end,
})

api.nvim_create_autocmd("FileType", {
	group = augroup "Spell",
	pattern = { "markdown", "text", "gitcommit" },
	command = "setlocal spell!",
})

-- :help fo-table
api.nvim_create_autocmd("FileType", {
	group = augroup "FormatOptions",
	callback = function()
		vim.opt.fo = vim.opt.fo - "a" - "t" - "o" + "c" + "q" + "r" - "n" + "j"
	end,
})

api.nvim_create_autocmd("BufWritePre", {
	group = augroup "AutoCreateDirectory",
	callback = function(event)
		local file = vim.loop.fs_realpath(event.match) or event.match
		vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
	end,
})

-- NOTE: fixes folds for buffers opened via telescope
api.nvim_create_autocmd("BufRead", {
	group = augroup "Folds",
	command = "normal zx",
})

api.nvim_create_autocmd("BufReadPost", {
	group = augroup "LastLocation",
	callback = function()
		local exclude = { "gitcommit" }
		local buf = api.nvim_get_current_buf()
		if vim.tbl_contains(exclude, vim.bo[buf].filetype) then
			return
		end

		local mark = api.nvim_buf_get_mark(buf, '"')
		local lcount = api.nvim_buf_line_count(buf)
		if mark[1] > 0 and mark[1] <= lcount then
			pcall(api.nvim_win_set_cursor, 0, mark)
		end
	end,
})
