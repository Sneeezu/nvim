return {
	{
		"iamcco/markdown-preview.nvim",
		ft = { "markdown" },
		build = "cd app && npm install",

		init = function()
			vim.g.mkdp_filetypes = { "markdown" }
		end,
	},

	{
		"andweeb/presence.nvim",
		event = { "BufReadPost", "BufNewFile" },

		config = function()
			require("presence"):setup {
				neovim_image_text = "Neovim",
				main_image = "file",
			}
		end,
	},

	{
		"mbbill/undotree",

		keys = {
			{ "<leader>u", "<cmd>UndotreeToggle<CR>", desc = "Toggle undotree" },
		},
	},

	{
		"tpope/vim-eunuch",
		event = "VeryLazy",

		keys = {
			{
				"<leader>r",
				function()
					local old_name = vim.fn.expand "%:t"
					local new_name = vim.fn.input("New file name: ", old_name)

					if new_name == "" or new_name == old_name then
						print()
						return
					end

					vim.cmd("Rename " .. new_name)
				end,
				desc = "Rename current file",
			},
		},
	},

	{
		"brenoprata10/nvim-highlight-colors",
		event = "VeryLazy",

		opts = {
			render = "background",
			enable_named_colors = true,
			enable_tailwind = true,
		},
	},
}
