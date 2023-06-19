return {
	{
		"catppuccin/nvim",
		priority = 1000,
		lazy = false,
		name = "catppuccin",

		config = function()
			require("catppuccin").setup {
				flavour = "mocha",

				background = {
					light = "latte",
					dark = "mocha",
				},

				styles = {
					comments = { "italic" },
					functions = { "bold" },
				},

				integrations = {
					fidget = true,
					harpoon = true,
					notify = true,
					which_key = true,
					treesitter_context = true,

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
					},
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
		"rcarriga/nvim-notify",
		config = function()
			local notify = require "notify"

			notify.setup {
				fps = 60,
			}

			vim.notify = notify
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
		config = true,
	},

	{
		"crispgm/nvim-tabline",
		event = "VimEnter",

		config = function()
			require("tabline").setup {}
			vim.opt.showtabline = 1
		end,
	},

	{
		"j-hui/fidget.nvim",
		event = { "BufReadPre", "BufNewFile" },

		config = function()
			require("fidget").setup {
				text = {
					spinner = "flip",
				},

				align = {
					bottom = true,
				},

				window = {
					relative = "editor",
				},
			}
		end,
	},

	"stevearc/dressing.nvim",
}
