local M = {}

local black = require "efmls-configs.formatters.black"
local prettier = require "efmls-configs.formatters.prettier"
local rustfmt = require "efmls-configs.formatters.rustfmt"
local shellcheck = require "efmls-configs.linters.shellcheck"
local shfmt = require "efmls-configs.formatters.shfmt"
local stylua = require "efmls-configs.formatters.stylua"

M.languages = {
	bash = { shfmt, shellcheck },
	sh = { shfmt, shellcheck },

	lua = { stylua },
	lau = { stylua },

	python = { black },
	rust = { rustfmt },

	css = { prettier },
	markdown = { prettier },
	javascript = { prettier },
	typescript = { prettier },
}

M.filetypes = vim.tbl_keys(M.languages)

-- TODO: make a function which will check if buffer has efm with formatting
M.buf_has_efm = function(buffer)
	return M.languages[vim.bo[buffer].filetype] ~= nil
end

return M
