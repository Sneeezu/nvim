local M = {}

local signs = {
	{ texthl = "DiagnosticSignError", text = "E" },
	{ texthl = "DiagnosticSignWarn", text = "W" },
	{ texthl = "DiagnosticSignHint", text = "H" },
	{ texthl = "DiagnosticSignInfo", text = "I" },
}

local function setup_signs()
	for _, sign in ipairs(signs) do
		vim.fn.sign_define(sign.texthl, { texthl = sign.texthl, text = sign.text })
	end
end

local has_null_ls = function(buffer)
	return #require("null-ls.sources").get_available(vim.bo[buffer].filetype, "NULL_LS_FORMATTING") > 0
end

M.setup_diagnostics = function()
	vim.diagnostic.config {
		signs = nil,
		virtual_text = true,
		underline = true,
		update_in_insert = true,
		severity_sort = true,

		float = {
			focusable = false,
			source = "always",
		},
	}

	setup_signs()
end

M.format = function()
	local buffer = vim.api.nvim_get_current_buf()
	vim.lsp.buf.format {
		async = true,
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
M.format_on_save = function(client, buffer)
	if not client.supports_method "textDocument/formatting" and not has_null_ls(buffer) then
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
				M.format()
			end
		end,
	})
end

M.servers = {
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

return M
