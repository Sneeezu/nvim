return {
	{
		"L3MON4D3/LuaSnip",
		lazy = true,

		dependencies = {
			{
				"rafamadriz/friendly-snippets",
				config = function()
					require("luasnip.loaders.from_vscode").lazy_load()
				end,
			},
		},

		config = function()
			local ls = require "luasnip"
			local types = require "luasnip.util.types"

			ls.config.set_config {
				history = true,
				enable_autosnippets = true,

				-- Dynamic snippets, updates as you type
				updateevents = "TextChanged,TextChangedI",

				ext_opts = {
					[types.choiceNode] = {
						active = {
							virt_text = { { " <- Current Choice", "NonTest" } },
						},
					},
				},
			}

			local s = ls.snippet
			-- local sn = ls.snippet_node
			-- local t = ls.text_node
			local i = ls.insert_node
			-- local c = ls.choice_node
			-- local d = ls.dynamic_node
			-- local r = ls.restore_nodelocal
			local fmt = require("luasnip.extras.fmt").fmt

			ls.add_snippets(nil, {
				go = {
					s(
						"init",
						fmt(
							[[
					func init() {{
						{}
					}}
				]],
							{ i(1) }
						)
					),
					s(
						"err",
						fmt(
							[[
					if err != nil {{
						{}
					}}
				]],
							{ i(1, "log.Fatal(err)") }
						)
					),
				},
			})
		end,
	},

	{
		"hrsh7th/nvim-cmp",
		event = "InsertEnter",

		dependencies = {
			"hrsh7th/cmp-path",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-nvim-lsp",
			"f3fora/cmp-spell",

			{
				"saadparwaiz1/cmp_luasnip",
				dependencies = { "L3MON4D3/LuaSnip" },
			},

			{
				"windwp/nvim-autopairs",
				opts = {
					check_ts = true,
					map_c_h = true,
					map_c_w = true,
				},
			},
		},

		config = function()
			local cmp = require "cmp"
			local ls = require "luasnip"

			local cmp_autopairs = require "nvim-autopairs.completion.cmp"
			cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())

			local kind_icons = {
				Text = "",
				Method = "",
				Function = "",
				Constructor = "",
				Field = "ﰠ",
				Variable = "",
				Class = "",
				Interface = "",
				Module = "",
				Property = "",
				Unit = "",
				Value = "",
				Enum = "",
				Keyword = "",
				Snippet = "",
				Color = "",
				File = "",
				Reference = "",
				Folder = "",
				EnumMember = "",
				Constant = "",
				Struct = "פּ",
				Event = "",
				Operator = "",
				TypeParameter = "",
			}

			local source_mapping = {
				luasnip = "[Snip]",
				nvim_lsp = "[LSP]",
				path = "[Path]",
				buffer = "[Buffer]",
				spell = "[Spell]",
			}

			cmp.setup {
				snippet = {
					expand = function(args)
						ls.lsp_expand(args.body)
					end,
				},

				window = {
					completion = {
						col_offset = 1,
						scrolloff = 3,
						winhighlight = "Normal:NormalFloat,FloatBorder:NormalFloat,CursorLine:Visual,Search:None",
					},

					documentation = {
						winhighlight = "Normal:NormalFloat,FloatBorder:NormalFloat,CursorLine:Visual,Search:None",
					},
				},

				mapping = cmp.mapping.preset.insert {
					["<C-p>"] = cmp.mapping.select_prev_item(),
					["<C-n>"] = cmp.mapping.select_next_item(),
					["<C-u>"] = cmp.mapping(cmp.mapping.scroll_docs(-4), { "i", "c" }),
					["<C-d>"] = cmp.mapping(cmp.mapping.scroll_docs(4), { "i", "c" }),
					["<C-Space>"] = cmp.mapping(cmp.mapping.complete(), { "i", "c" }),

					["<CR>"] = cmp.mapping.confirm {
						behavior = cmp.ConfirmBehavior.insert,
						select = true,
					},

					["<C-c>"] = cmp.mapping {
						i = cmp.mapping.abort(),
						c = cmp.mapping.close(),
					},

					["<C-j>"] = cmp.mapping(function()
						if ls.jumpable(1) then
							ls.jump(1)
						end
					end, { "s", "i" }),

					["<C-k>"] = cmp.mapping(function()
						if ls.jumpable(-1) then
							ls.jump(-1)
						end
					end, { "s", "i" }),

					["<C-l>"] = cmp.mapping(function()
						if require("luasnip").choice_active() then
							require("luasnip").change_choice(1)
						end
					end, { "s", "i" }),
				},

				formatting = {
					format = function(entry, item)
						item.menu = source_mapping[entry.source.name]
						item.kind = kind_icons[item.kind]

						local content = item.abbr
						local win_width = vim.api.nvim_win_get_width(0)
						local max_content_width = fixed_width and fixed_width - 10 or math.floor(win_width * 0.25)

						if #content > max_content_width then
							item.abbr = vim.fn.strcharpart(content, 0, max_content_width - 1) .. "…"
						else
							item.abbr = content .. (" "):rep(max_content_width - #content)
						end

						return item
					end,
				},

				preselect = cmp.PreselectMode.None,

				sources = {
					{ name = "luasnip" },
					{ name = "nvim_lsp" },
					{ name = "path" },
					{ name = "buffer" },
					{
						name = "spell",
						option = {
							keep_all_entries = false,
							enable_in_context = function()
								return vim.opt.spell
							end,
						},
					},
				},

				completion = {
					completeopt = "menu,menuone,noinsert",
				},
			}
		end,
	},
}
