local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system {
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable",
		lazypath,
	}
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup {
	spec = {
		{ import = "configs.plugins" },
		{ import = "configs.plugins.lsp" },
	},

	ui = {
		wrap = false,
		border = "rounded",
		size = {
			width = 0.9,
			height = 0.85,
		},
	},

	defaults = {
		lazy = false,
		version = false, -- always use the latest git commit
		-- version = "*", -- try installing the latest stable version for plugins that support semver
	},

	checker = {
		enabled = true,
		frequency = 604800,
	},

	install = {
		colorscheme = { "catppuccin", "lunaperche" },
	},

	performance = {
		rtp = {
			disabled_plugins = {
				"gzip",
				-- "matchit",
				-- "matchparen",
				-- "netrwPlugin",
				"tarPlugin",
				"tohtml",
				"tutor",
				"zipPlugin",
			},
		},
	},
}
