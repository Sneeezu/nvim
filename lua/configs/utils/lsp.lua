local M = {}

local has_null_ls = function(buffer)
	return #require("null-ls.sources").get_available(vim.bo[buffer].filetype, "NULL_LS_FORMATTING") > 0
end

---@param async boolean|nil
M.format = function(async)
	if async == nil then
		async = false
	end

	local buffer = vim.api.nvim_get_current_buf()
	vim.lsp.buf.format {
		async = async,
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

	vim.keymap.set("n", "<leader>F", function()
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

	map("n", "gd", function()
		require("telescope.builtin").lsp_definitions()
	end, "Go to definition(s)")

	map("n", "gr", function()
		require("telescope.builtin").lsp_references()
	end, "Go to reference(s)")

	map("n", "gi", function()
		require("telescope.builtin").lsp_implementations()
	end, "Go to implementation(s)")

	map("n", "<leader>D", function()
		require("telescope.builtin").lsp_type_definitions()
	end, "Go to type definition")

	map("n", "K", vim.lsp.buf.hover, "Show documentation")
	map("n", "gD", vim.lsp.buf.declaration, "Go to declaration")
	map("n", "<leader>cr", vim.lsp.buf.rename, "Rename")
	map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, "Code action")
	map({ "i", "s" }, "<C-s>", vim.lsp.buf.signature_help, "Signature help")

	map("n", "<leader>wa", vim.lsp.buf.add_workspace_folder)
	map("n", "<leader>wr", vim.lsp.buf.remove_workspace_folder)
	map("n", "<leader>wl", function()
		print(vim.inspect(vim.lsp.buf.list_workleader_folders()))
	end)

	map("n", "<leader>f", function()
		M.format()
	end, "Format code")

	if client.supports_method "textDocument/inlayHint" then
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

	bashls = {
		settings = {
			bashIde = {
				shellcheckPath = "",
			},
		},
	},

	html = {},
	cssls = {},
	pyright = {},
	jsonls = {},
	taplo = {},
	clangd = {},
}

return M
