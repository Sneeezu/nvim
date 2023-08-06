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

M.on_attach = function(client, buffer)
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
	map("n", "<leader>lf", M.format, "Format")
	map({ "i", "s" }, "<C-s>", vim.lsp.buf.signature_help, "Signature help")

	if client.server_capabilities.inlayHintProvider then
		vim.lsp.inlay_hint(buffer, true)
	end

	M.format_on_save(client, buffer)
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

	emmet_ls = {
		filetypes = {
			"css",
			"eruby",
			"html",
			"javascript",
			"javascriptreact",
			"less",
			"sass",
			"scss",
			"svelte",
			"pug",
			"typescriptreact",
			"vue",
		},

		init_options = {
			html = {
				options = {
					["bem.enabled"] = true,
				},
			},
		},
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
