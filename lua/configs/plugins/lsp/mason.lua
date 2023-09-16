return {
	{
		"williamboman/mason.nvim",
		cmd = "Mason",

		keys = {
			{ "<leader>lm", "<cmd>Mason<CR>", desc = "Mason" },
		},

		opts = {
			ensure_installed = {
				"black",
				"prettier",
				-- "rustfmt", -- deprecated, install through rustup
				"shellcheck",
				"shfmt",
				"stylua",
			},

			ui = {
				border = "rounded",
				width = 0.9,
				height = 0.85,

				check_outdated_packages_on_open = true,
				icons = {
					package_installed = "✓",
					package_pending = "➜",
					package_uninstalled = "✗",
				},
			},
		},

		config = function(_, opts)
			require("mason").setup(opts)

			local registry = require "mason-registry"
			local function ensure_installed()
				if opts.ensure_installed == nil or next(opts.ensure_installed) == nil then
					return
				end

				for _, tool in ipairs(opts.ensure_installed) do
					local package = registry.get_package(tool)
					if not package:is_installed() then
						package:install()
					end
				end
			end

			ensure_installed()
		end,
	},
}
