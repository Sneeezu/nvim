return {
	{
		"nvim-telescope/telescope.nvim",

		cmd = "Telescope",

		keys = {
			{
				"<leader>E",
				function()
					require("telescope.builtin").diagnostics()
				end,
				desc = "Show all diagnostics",
			},
			{
				"<C-p>",
				function()
					require("telescope.builtin").find_files()
				end,
				desc = "Find files",
			},
			{
				"z=",
				function()
					require("telescope.builtin").spell_suggest()
				end,
				desc = "Spell suggest",
			},
			{
				"<leader>/",
				function()
					require("telescope.builtin").live_grep()
				end,
				desc = "Live grep",
			},
			{
				"<leader>o",
				function()
					require("telescope.builtin").oldfiles()
				end,
				desc = "Old files",
			},
			{
				"<leader>ba",
				function()
					require("telescope.builtin").buffers()
				end,
				desc = "Buffers",
			},
			{
				"<leader>h",
				function()
					require("telescope.builtin").help_tags()
				end,
				desc = "Help tags",
			},
			{
				"<leader>bc",
				function()
					require("telescope.builtin").git_bcommits()
				end,
				desc = "Git BCommits",
			},
		},

		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-tree/nvim-web-devicons",
			{
				"nvim-telescope/telescope-fzf-native.nvim",
				build = "make",
			},
		},

		config = function()
			local telescope = require "telescope"
			local actions = require "telescope.actions"

			telescope.setup {
				defaults = {
					path_display = { "truncate" },
					file_ignore_patterns = { ".git/", "target/" },

					multi_icon = " *",
					sorting_strategy = "ascending",
					layout_config = {
						prompt_position = "top",
						height = 30,
						width = 140,
					},

					mappings = {
						i = {
							["<C-s>"] = actions.select_horizontal,
							["<C-j>"] = actions.cycle_history_next,
							["<C-k>"] = actions.cycle_history_prev,
						},
					},
				},

				pickers = {
					find_files = {
						no_ignore = true,
						hidden = true,
					},
				},

				extensions = {
					fzf = {
						fuzzy = true,
						override_generic_sorter = true,
						override_file_sorter = true,
						case_mode = "smart_case",
					},
				},
			}

			require("telescope").load_extension "fzf"
		end,
	},

	{
		"ThePrimeagen/harpoon",

		keys = {
			{
				"<leader>a",
				function()
					require("harpoon.mark").add_file()
				end,
				desc = "Add file to harpoon",
			},
			{
				"<leader>m",
				function()
					require("harpoon.ui").toggle_quick_menu()
				end,
				desc = "Open harpoon quick menu",
			},
			{
				"<C-h>",
				function()
					require("harpoon.ui").nav_file(1)
				end,
				desc = "Navigate to first harpoon file",
			},
			{
				"<C-t>",
				function()
					require("harpoon.ui").nav_file(2)
				end,
				desc = "Navigate to second harpoon file",
			},
			{
				"<C-n>",
				function()
					require("harpoon.ui").nav_file(3)
				end,
				desc = "Navigate to third harpoon file",
			},
			{
				"<C-s>",
				function()
					require("harpoon.ui").nav_file(4)
				end,
				desc = "Navigate to fourth harpoon file",
			},
		},

		dependencies = {
			"nvim-lua/plenary.nvim",
		},
	},
}
