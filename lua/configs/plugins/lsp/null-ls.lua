return {
	{
		"jay-babu/mason-null-ls.nvim",
		event = { "BufReadPre", "BufNewFile" },

		dependencies = {
			"williamboman/mason.nvim",

			{
				"jose-elias-alvarez/null-ls.nvim",
				dependencies = {
					"nvim-lua/plenary.nvim",
				},
			},
		},

		config = function()
			local null_ls = require "null-ls"

			null_ls.setup {
				sources = {
					null_ls.builtins.diagnostics.shellcheck,
					null_ls.builtins.formatting.stylua,
					null_ls.builtins.formatting.black,

					null_ls.builtins.formatting.prettier.with {
						extra_args = { "--tab-width=4" },
					},

					null_ls.builtins.formatting.shfmt.with {
						extra_args = { "-i=4" },
					},

					null_ls.builtins.formatting.rustfmt.with {
						extra_args = function(params)
							local path = require "plenary.path"
							local cargo_toml = path:new(params.root .. "/" .. "Cargo.toml")

							-- Set default if Cargo.toml is not found
							if not cargo_toml:exists() and not cargo_toml:is_file() then
								return { "--edition=2021" }
							end

							for _, line in ipairs(cargo_toml:readlines()) do
								local edition = line:match [[^edition%s*=%s*%"(%d+)%"]]
								if edition then
									return { "--edition=" .. edition }
								end
							end
						end,
					},
				},
			}

			require("mason-null-ls").setup {
				automatic_installation = {
					exclude = { "rustfmt" },
				},
			}
		end,
	},
}
