return {
	{
		"nvim-treesitter/nvim-treesitter",

		build = ":TSUpdate",
		event = { "BufReadPost", "BufNewFile" },

		dependencies = {
			"nvim-treesitter/nvim-treesitter-textobjects",
		},

		config = function()
			require("nvim-treesitter.configs").setup {
				ensure_installed = "all",
				sync_install = false,

				highlight = {
					enable = true,
					additional_vim_regex_highlighting = false,
				},

				context_commentstring = {
					enable = true,
					enable_autocmd = false,
				},

				textobjects = {
					move = {
						enable = true,
						set_jumps = true,

						goto_next_start = {
							["]a"] = "@parameter.inner",
							["]f"] = "@function.outer",
							["]c"] = "@class.outer",
						},
						goto_next_end = {
							["]F"] = "@function.outer",
							["]C"] = "@class.outer",
						},
						goto_previous_start = {
							["[a"] = "@parameter.inner",
							["[f"] = "@function.outer",
							["[c"] = "@class.outer",
						},
						goto_previous_end = {
							["[F"] = "@function.outer",
							["[C"] = "@class.outer",
						},
					},
				},
			}
		end,
	},

	{
		"nvim-treesitter/nvim-treesitter-context",
		event = { "BufEnter", "BufNewFile" },

		dependencies = {
			"nvim-treesitter/nvim-treesitter",
		},
	},

	{
		"echasnovski/mini.ai",
		event = { "BufEnter", "BufNewFile" },

		dependencies = {
			"nvim-treesitter/nvim-treesitter-textobjects",
		},

		config = function()
			local ai = require "mini.ai"
			ai.setup {
				n_lines = 500,
				silent = true,

				custom_textobjects = {
					f = ai.gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }, {}),
					c = ai.gen_spec.treesitter({ a = "@class.outer", i = "@class.inner" }, {}),
					a = ai.gen_spec.treesitter({ a = "@parameter.outer", i = "@parameter.inner" }, {}),
					o = ai.gen_spec.treesitter({
						a = { "@block.outer", "@conditional.outer", "@loop.outer" },
						i = { "@block.inner", "@conditional.inner", "@loop.inner" },
					}, {}),
				},
			}
		end,
	},
}
