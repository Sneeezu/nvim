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
		end,
	},
}
