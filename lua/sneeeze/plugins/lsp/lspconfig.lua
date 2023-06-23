return {
	{
		"williamboman/mason-lspconfig.nvim",
		event = { "BufReadPre", "BufNewFile" },

		dependencies = {
			"williamboman/mason.nvim",
			"nvim-telescope/telescope.nvim",
			"ray-x/lsp_signature.nvim",

			{
				"neovim/nvim-lspconfig",
				keys = {
					{ "<leader>li", "<cmd>LspInfo<CR>" },
					{ "<leader>lr", "<cmd>LspRestart<CR>" },
				},
			},

			{
				"folke/neodev.nvim",
				opts = {
					experimental = {
						pathStrict = true,
					},
				},
			},

			{
				"hrsh7th/cmp-nvim-lsp",
				cond = function()
					return require("lazy.core.config").plugins["nvim-cmp"] ~= nil
				end,
			},
		},

		config = function()
			require("mason-lspconfig").setup { automatic_installation = true }

			local lspconfig = require "lspconfig"
			local capabilities = vim.lsp.protocol.make_client_capabilities()
			local default_capabilities = require("cmp_nvim_lsp").default_capabilities()

			local signs = {
				{ texthl = "DiagnosticSignError", text = "E" },
				{ texthl = "DiagnosticSignWarn", text = "W" },
				{ texthl = "DiagnosticSignHint", text = "H" },
				{ texthl = "DiagnosticSignInfo", text = "I" },
			}

			for _, sign in ipairs(signs) do
				vim.fn.sign_define(sign.texthl, { texthl = sign.texthl, text = sign.text })
			end

			require("lspconfig.ui.windows").default_options = {
				border = "rounded",
			}

			vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
				border = "rounded",
			})

			vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
				border = "rounded",
			})

			vim.diagnostic.config {
				signs = nil,
				virtual_text = true,
				underline = true,
				update_in_insert = true,
				severity_sort = true,

				float = {
					focusable = false,
					style = "minimal",
					border = "rounded",
					source = "always",
					header = "",
					prefix = "",
					suffix = "",
				},
			}

			local servers = {
				lua_ls = {
					settings = {
						Lua = {
							runtime = {
								version = "LuaJIT",
								path = vim.split(package.path, ";"),
							},

							diagnostics = {
								globals = {
									"awesome",
									"client",
									"root",
									"screen",
								},
							},

							completion = {
								callSnippet = "Replace",
								autoRequire = false,
							},

							workspace = {
								checkThirdParty = false,
								library = {
									["/usr/share/awesome/lib"] = true,
								},
							},

							telemetry = {
								enable = false,
							},

							hint = {
								enable = true,
							},
						},
					},
				},

				gopls = {
					settings = {
						gopls = {
							staticcheck = true,
							deepCompletion = true,
							verboseOutput = true,
							usePlaceholders = true,
							completeUnimported = true,
							completionDocumentation = true,
							symbolStyle = "Full",

							hints = {
								assignVariableTypes = true,
								compositeLiteralFields = true,
								compositeLiteralTypes = true,
								constantValues = true,
								functionTypeParameters = true,
								parameterNames = true,
								rangeVariableTypes = true,
							},

							analyses = {
								unusedparams = true,
							},
						},
					},
				},

				rust_analyzer = {
					settings = {
						["rust-analyzer"] = {
							check = {
								command = "clippy",
							},
						},
					},
				},

				tsserver = {
					settings = {
						typescript = {
							inlayHints = {
								includeInlayParameterNameHints = "all",
								includeInlayParameterNameHintsWhenArgumentMatchesName = false,
								includeInlayFunctionParameterTypeHints = true,
								includeInlayVariableTypeHints = true,
								includeInlayVariableTypeHintsWhenTypeMatchesName = false,
								includeInlayPropertyDeclarationTypeHints = true,
								includeInlayFunctionLikeReturnTypeHints = true,
								includeInlayEnumMemberValueHints = true,
							},
						},
						javascript = {
							inlayHints = {
								includeInlayParameterNameHints = "all",
								includeInlayParameterNameHintsWhenArgumentMatchesName = false,
								includeInlayFunctionParameterTypeHints = true,
								includeInlayVariableTypeHints = true,
								includeInlayVariableTypeHintsWhenTypeMatchesName = false,
								includeInlayPropertyDeclarationTypeHints = true,
								includeInlayFunctionLikeReturnTypeHints = true,
								includeInlayEnumMemberValueHints = true,
							},
						},
					},
				},

				ruff_lsp = {
					on_attach = function(client)
						client.server_capabilities.hoverProvider = false
					end,
				},

				html = {},
				cssls = {},
				pyright = {},
				jsonls = {},
				taplo = {},
				bashls = {},
				clangd = {},
			}

			---@param buffer integer
			---@return boolean
			local has_null_ls = function(buffer)
				return #require("null-ls.sources").get_available(vim.bo[buffer].filetype, "NULL_LS_FORMATTING") > 0
			end

			local format = function()
				local buffer = vim.api.nvim_get_current_buf()

				vim.lsp.buf.format {
					bufnr = buffer,
					filter = function(client)
						if has_null_ls(buffer) then
							return client.name == "null-ls"
						end

						return client.name ~= "null-ls"
					end,
				}
			end

			vim.g.format_on_save = true
			local format_on_save = function(client, buffer)
				local has_formatting = client.supports_method "textDocument/formatting"

				if not has_formatting and not has_null_ls(buffer) then
					return
				end

				vim.keymap.set("n", "<leader>lF", function()
					if not vim.g.format_on_save then
						vim.g.format_on_save = true
						vim.notify "Enabled format on save"
					else
						vim.g.format_on_save = not vim.g.format_on_save
						vim.notify "Disabled format on save"
					end
				end, { buffer = buffer, desc = "Toggle format on save" })

				local group = vim.api.nvim_create_augroup("FormatOnSave." .. buffer, {})
				vim.api.nvim_create_autocmd("BufWritePre", {
					group = group,
					buffer = buffer,
					callback = function()
						if vim.g.format_on_save then
							format()
						end
					end,
				})
			end

			---@diagnostic disable-next-line: unused-local
			local function on_attach(client, buffer)
				local function map(mode, l, r, desc)
					vim.keymap.set(mode, l, r, { buffer = buffer, remap = false, desc = desc })
				end

				map("n", "K", vim.lsp.buf.hover, "Show documentation")
				map("n", "gD", vim.lsp.buf.declaration, "Go to declaration")
				map("n", "gd", require("telescope.builtin").lsp_definitions, "Go to definition(s)")
				map("n", "gr", require("telescope.builtin").lsp_references, "Go to reference(s)")
				map("n", "gi", require("telescope.builtin").lsp_implementations, "Go to implementation(s)")

				map("n", "]d", vim.diagnostic.goto_next, "Go to next diagnostic")
				map("n", "[d", vim.diagnostic.goto_prev, "Go to previous diagnostic")

				map("n", "<leader>vd", vim.diagnostic.open_float, "Open diagnostic in float")
				map("n", "<leader>vD", require("telescope.builtin").diagnostics, "Show all diagnostics")

				map("n", "<leader>cr", vim.lsp.buf.rename, "Rename")
				map("n", "<leader>ca", vim.lsp.buf.code_action, "Code action")
				map("n", "<leader>lf", format, "Format")
			end

			vim.tbl_deep_extend("force", capabilities, default_capabilities)
			capabilities.textDocument.completion.completionItem.snippetSupport = true

			for server, config in pairs(servers) do
				local custom_on_attach

				if config.on_attach then
					custom_on_attach = config.on_attach
				end

				config.on_attach = function(client, buffer)
					if client.server_capabilities.signatureHelpProvider then
						require("lsp_signature").on_attach({
							bind = true,
							noice = true,
							doc_lines = 4,
							max_height = 4,

							floating_window = true,
							floating_window_above_cur_line = true,
							transparency = 20,
							hint_enable = true,
							hint_prefix = " ■ ",
							fix_pos = false,

							timer_interval = 100,
							extra_trigger_chars = {},
						}, buffer)
					end

					if client.server_capabilities.inlayHintProvider then
						vim.lsp.buf.inlay_hint(buffer, true)
					end

					format_on_save(client, buffer)

					if type(custom_on_attach) == "function" then
						custom_on_attach(client, buffer)
					end

					on_attach(client, buffer)
				end

				config.capabilities = capabilities

				lspconfig[server].setup(config)
			end
		end,
	},
}
