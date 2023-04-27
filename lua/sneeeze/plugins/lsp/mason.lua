return {
	{
		"williamboman/mason.nvim",
		cmd = "Mason",

		keys = {
			{ "<leader>lm", "<cmd>Mason<cr>", desc = "Mason" },
		},

		config = function()
			require("mason").setup {
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
			}

			local ensure_installed = {
				"black",
				"rustfmt",
				"stylua",
			}

			for _, tool in ipairs(ensure_installed) do
				local package = require("mason-registry").get_package(tool)
				if not package:is_installed() then
					package:install()
				end
			end
		end,
	},
}
