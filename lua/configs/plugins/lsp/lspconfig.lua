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

			utils.setup_diagnostics()

			require("lspconfig.ui.windows").default_options = {
				border = "rounded",
			}

			local capabilities = vim.tbl_deep_extend(
				"force",
				vim.lsp.protocol.make_client_capabilities(),
				require("cmp_nvim_lsp").default_capabilities()
			)

			local on_attach = function(client, buffer)
				local function map(mode, l, r, desc)
					vim.keymap.set(mode, l, r, { buffer = buffer, remap = false, desc = desc })
				end

				map("n", "K", vim.lsp.buf.hover, "Show documentation")
				map("n", "gD", vim.lsp.buf.declaration, "Go to declaration")
				map("n", "gd", require("telescope.builtin").lsp_definitions, "Go to definition(s)")
				map("n", "gr", require("telescope.builtin").lsp_references, "Go to reference(s)")
				map("n", "gi", require("telescope.builtin").lsp_implementations, "Go to implementation(s)")
				map("n", "<leader>va", require("telescope.builtin").diagnostics, "Show all diagnostics")
				map("n", "<leader>vd", vim.diagnostic.open_float, "Open diagnostic in float")
				map("n", "]d", vim.diagnostic.goto_next, "Go to next diagnostic")
				map("n", "[d", vim.diagnostic.goto_prev, "Go to previous diagnostic")
				map("n", "<leader>cr", vim.lsp.buf.rename, "Rename")
				map("n", "<leader>ca", vim.lsp.buf.code_action, "Code action")
				map("n", "<leader>lf", utils.format, "Format")
				map({ "i", "s" }, "<C-s>", vim.lsp.buf.signature_help, "Signature help")

				if client.server_capabilities.inlayHintProvider then
					vim.lsp.inlay_hint(buffer, true)
				end

				utils.format_on_save(client, buffer)
			end

			for server, config in pairs(utils.servers) do
				config.capabilities = capabilities

				local custom_on_attach = config.on_attach
				config.on_attach = function(client, buffer)
					if config.on_attach and type(custom_on_attach) == "function" then
						custom_on_attach(client, buffer)
					end

					on_attach(client, buffer)
				end

				lspconfig[server].setup(config)
			end
		end,
	},
}
