vim.g.mapleader = " "

vim.opt.guicursor = ""

vim.opt.fileencoding = "utf-8"
vim.opt.spelllang = { "en", "cs" }

vim.opt.scrolloff = 8
vim.opt.sidescrolloff = 8

vim.opt.autoindent = true
vim.opt.cindent = true

vim.opt.expandtab = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4

vim.opt.wrap = false
vim.opt.linebreak = true -- wraps lines smartly

vim.opt.mouse = "a"

vim.opt.number = true
vim.opt.relativenumber = true

vim.opt.incsearch = true
vim.opt.ignorecase = true

vim.opt.smartcase = true

vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.winminwidth = 5

vim.opt.termguicolors = true
vim.opt.pumblend = 20 -- transparency
vim.opt.laststatus = 3
vim.opt.showmode = false
vim.opt.cursorline = true
vim.opt.conceallevel = 3

vim.opt.signcolumn = "yes"
vim.opt.colorcolumn = "80"

vim.opt.updatetime = 25 -- 4000ms default

vim.opt.hidden = true
vim.opt.swapfile = false

vim.opt.undofile = true
vim.opt.undolevels = 1000
vim.opt.undoreload = 10000

if vim.fn.executable "rg" == 1 then
	vim.opt.grepprg = "rg --vimgrep"
end

vim.opt.completeopt = "menu,menuone,noinsert"
vim.opt.wildmode = "longest:full,full"

vim.opt.list = true
vim.opt.listchars:append {
	eol = "↲",
	tab = "» ",
	space = " ",
	trail = "·",
	extends = "<",
	precedes = ">",
	conceal = "┊",
	nbsp = "␣",
}

vim.opt.fillchars:append {
	foldopen = "-",
	foldclose = "+",
	foldsep = " ",
}

vim.opt.shortmess:append {
	I = true,
	c = true,
}