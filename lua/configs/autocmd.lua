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
	group = api.nvim_create_augroup("Folds", { clear = true }),
	command = "normal zx",
})
