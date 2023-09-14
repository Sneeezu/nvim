return {
	{
		"neovim/nvim-lspconfig",
		event = { "BufReadPre", "BufNewFile" },

		keys = {
			{ "<leader>li", "<cmd>LspInfo<CR>" },
			{ "<leader>lr", "<cmd>LspRestart<CR>" },
		},

		dependencies = {
			{
				"williamboman/mason-lspconfig.nvim",
				opts = {
					automatic_installation = true,
				},
			},

			"williamboman/mason.nvim",
			"hrsh7th/cmp-nvim-lsp",
			"nvim-telescope/telescope.nvim",

			{
				"folke/neodev.nvim",
				opts = {
					experimental = {
						pathStrict = true,
					},
				},
			},
		},

		config = function()
			local lspconfig = require "lspconfig"
			local utils = require "configs.utils.lsp"

			require("lspconfig.ui.windows").default_options = {
				border = "rounded",
			}

			local capabilities = vim.tbl_deep_extend(
				"force",
				vim.lsp.protocol.make_client_capabilities(),
				require("cmp_nvim_lsp").default_capabilities()
			)
			capabilities.textDocument.completion.completionItem.snippetSupport = true

			for server, config in pairs(utils.servers) do
				config.capabilities = capabilities

				local custom_on_attach = config.on_attach
				config.on_attach = function(client, buffer)
					if config.on_attach and type(custom_on_attach) == "function" then
						custom_on_attach(client, buffer)
					end

					utils.on_attach(client, buffer)
				end

				lspconfig[server].setup(config)
			end
		end,
	},
}
