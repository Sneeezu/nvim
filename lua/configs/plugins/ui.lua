return {
	{
		"catppuccin/nvim",
		priority = 1000,
		lazy = false,
		name = "catppuccin",

		config = function()
			require("catppuccin").setup {
				flavour = "mocha",
				show_end_of_buffer = true,

				background = {
					light = "latte",
					dark = "mocha",
				},

				styles = {
					comments = { "italic" },
					functions = { "bold" },
				},

				integrations = {
					cmp = true,
					gitsigns = true,
					harpoon = true,
					mason = true,
					native_lsp = {
						enabled = true,
						virtual_text = {
							errors = {},
							hints = {},
							warnings = {},
							information = {},
						},
						underlines = {
							errors = { "undercurl" },
							hints = { "undercurl" },
							warnings = { "undercurl" },
							information = { "undercurl" },
						},
						inlay_hints = {
							background = false,
						},
					},
					noice = true,
					notify = true,
					semantic_tokens = true,
					telescope = true,
					treesitter_context = true,
					treesitter = true,
					which_key = true,
				},

				custom_highlights = function(colors)
					return {
						TabLine = { fg = colors.overlay1, bg = colors.mantle },
						TabLineSel = { fg = colors.text, bg = colors.surface0 },
						TabLineFill = { bg = colors.mantle },

						ElInsert = { fg = colors.yellow, bg = colors.base },

						ElGitAdded = { fg = colors.teal, bg = colors.mantle },
						ElGitChanged = { fg = colors.yellow, bg = colors.mantle },
						ElGitRemoved = { fg = colors.red, bg = colors.mantle },

						-- TODO: use statusline bg color
						ElDiagnosticHint = { fg = colors.teal, bg = colors.mantle },
						ElDiagnosticInfo = { fg = colors.sky, bg = colors.mantle },
						ElDiagnosticWarn = { fg = colors.yellow, bg = colors.mantle },
						ElDiagnosticError = { fg = colors.red, bg = colors.mantle },

						DiagnosticVirtualTextHint = { bg = colors.none },
						DiagnosticVirtualTextInfo = { bg = colors.none },
						DiagnosticVirtualTextWarn = { bg = colors.none },
						DiagnosticVirtualTextError = { bg = colors.none },

						TreesitterContextLineNumber = { fg = colors.surface1, bg = colors.mantle },

						-- classic catppuccin
						Special = { fg = colors.blue },
						WhichKey = { fg = colors.flamingo },
						WhichKeyBorder = { fg = colors.blue },
						TelescopeNormal = { link = "Normal" },
						MatchParen = { fg = colors.peach, bg = colors.none, style = { "bold" } },
					}
				end,
			}

			vim.cmd.colorscheme "catppuccin"
		end,
	},

	{
		"tjdevries/express_line.nvim",
		event = "VimEnter",

		dependencies = {
			"nvim-lua/plenary.nvim",
			-- FIXME
			-- "lewis6991/gitsigns.nvim",
		},

		config = function()
			local subscribe = require "el.subscribe"
			local extensions = require "el.extensions"

			local modes = setmetatable({
				n = "Normal",
				no = "N·OpPd",
				v = "Visual",
				V = "V·Line",
				[""] = "V·Blck",
				s = "Select",
				S = "S·Line",
				[""] = "S·Block",
				i = "Insert",
				niI = "I·Norm",
				ic = "I·Comp",
				R = "Rplace",
				Rv = "VRplce",
				c = "Cmmand",
				cv = "Vim Ex",
				ce = "Ex (r)",
				r = "Prompt",
				rm = "More  ",
				["r?"] = "Cnfirm",
				["!"] = "Shell ",
				t = "Term  ",
				nt = "Normal",
			}, {
				__index = function()
					return "Unknown"
				end,
			})

			local modes_highlights = setmetatable({
				n = "ElNormal",
				no = "ElNormalOperatorPending",
				v = "ElVisual",
				V = "ElVisualLine",
				[""] = "ElVisualBlock",
				s = "ElSelect",
				S = "ElSLine",
				[""] = "ElSBlock",
				i = "ElInsert",
				niI = "ElNormal",
				ic = "ElInsertCompletion",
				R = "ElReplace",
				Rv = "ElVirtualReplace",
				c = "ElCommand",
				cv = "ElCommandCV",
				ce = "ElCommandEx",
				r = "ElPrompt",
				rm = "ElMore",
				["r?"] = "ElConfirm",
				["!"] = "ElShell",
				t = "ElTerm",
				nt = "ElNormal",
			}, {
				__index = function()
					return "ElNormal"
				end,
			})

			local mode = function()
				local nvim_mode = vim.api.nvim_get_mode().mode
				local mode = modes[nvim_mode]
				local highlight = modes_highlights[nvim_mode]

				return string.format("%%#%s#[%s]%%*", highlight, mode)
			end

			local git_branch = subscribe.buf_autocmd("el_git_branch", "BufEnter", function(window, buffer)
				local branch = extensions.git_branch(window, buffer)

				if branch then
					return "  " .. branch
				end
			end)

			---@diagnostic disable-next-line: unused-local
			local git_changes = function(window, buffer)
				local stats = {}
				if buffer and buffer.bufnr > 0 then
					local ok, res = pcall(vim.api.nvim_buf_get_var, buffer.bufnr, "gitsigns_status_dict")
					if ok then
						stats = res
					end
				end

				local items = {}
				if stats.added > 0 then
					table.insert(items, string.format("%%#ElGitAdded#+%s%%*", stats.added))
				end

				if stats.changed > 0 then
					table.insert(items, string.format("%%#ElGitChanged#~%s%%*", stats.changed))
				end

				if stats.removed > 0 then
					table.insert(items, string.format("%%#ElGitRemoved#-%s%%*", stats.removed))
				end

				if next(items) == nil then
					return ""
				end

				return string.format("[%s]", table.concat(items, ", "))
			end

			local file_type = function()
				local ft = vim.bo.filetype

				if ft == "" then
					ft = "None"
				end

				return string.format("[%s]", ft)
			end

			local diagnostics = require("el.diagnostic").make_buffer(function(_, _, counts)
				local items = {}
				if counts.errors > 0 then
					table.insert(items, string.format("%%#ElDiagnosticError#E:%s%%*", counts.errors))
				end

				if counts.warnings > 0 then
					table.insert(items, string.format("%%#ElDiagnosticWarn#W:%s%%*", counts.warnings))
				end

				if counts.infos > 0 then
					table.insert(items, string.format("%%#ElDiagnosticInfo#I:%s%%*", counts.infos))
				end

				if counts.hints > 0 then
					table.insert(items, string.format("%%#ElDiagnosticHint#H:%s%%*", counts.hints))
				end

				if next(items) == nil then
					return ""
				end

				return string.format("[%s]", table.concat(items, ", "))
			end)

			require("el").setup {
				generator = function()
					return {
						mode,
						git_branch,
						" %f %m%h%r",
						"%=",
						diagnostics,
						git_changes,
						"[%-03l:%-02c]",
						file_type,
					}
				end,
			}
		end,
	},

	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		config = true,
	},

	{
		"crispgm/nvim-tabline",
		event = "VeryLazy",

		config = function()
			require("tabline").setup {}
			vim.opt.showtabline = 1
		end,
	},

	{
		"folke/noice.nvim",
		event = "VeryLazy",

		cmd = "Noice",

		keys = {
			{
				"<C-u>",
				function()
					if not require("noice.lsp").scroll(-4) then
						return "<C-u>zz"
					end
				end,
				desc = "Scroll up",
				mode = { "i", "n", "s" },
				expr = true,
				silent = true,
			},

			{
				"<C-d>",
				function()
					if not require("noice.lsp").scroll(4) then
						return "<C-d>zz"
					end
				end,
				desc = "Scroll down",
				mode = { "i", "n", "s" },
				expr = true,
				silent = true,
			},
		},

		dependencies = {
			"MunifTanjim/nui.nvim",

			{
				"rcarriga/nvim-notify",
				event = "VimEnter",

				opts = {
					fps = 60,
				},
			},
		},

		opts = {
			cmdline = {
				enabled = false,
			},

			messages = {
				enabled = false,
			},

			popupmenu = {
				enabled = false,
			},

			notify = {
				enabled = true,
			},

			lsp = {
				progress = {
					enabled = true,
					format = "lsp_progress",
					format_done = "lsp_progress_done",
					throttle = 1000 / 30,
				},

				override = {
					["vim.lsp.util.convert_input_to_markdown_lines"] = true,
					["vim.lsp.util.stylize_markdown"] = true,
					["cmp.entry.get_documentation"] = true,
				},

				hover = {
					enabled = true,
					silent = true,
				},

				signature = {
					enabled = true,

					auto_open = {
						enabled = true,
						trigger = true,
						luasnip = true,
						throttle = 50,
					},
				},

				message = {
					enabled = false,
				},
			},

			health = {
				checker = false,
			},

			smart_move = {
				enabled = true,
			},

			presets = {
				bottom_search = true, -- use a classic bottom cmdline for search
				command_palette = true, -- position the cmdline and popupmenu together
				long_message_to_split = true, -- long messages will be sent to a split
				inc_rename = true, -- enables an input dialog for inc-rename.nvim
				lsp_doc_border = false, -- add a border to hover docs and signature help
			},

			throttle = 1000 / 30,

			views = {
				mini = {
					position = {
						row = -2,
					},
				},

				hover = {
					border = {
						padding = {
							0,
							1,
						},
					},

					position = {
						row = 1,
						col = 1,
					},
				},
			},
		},
	},

	"stevearc/dressing.nvim",
}
