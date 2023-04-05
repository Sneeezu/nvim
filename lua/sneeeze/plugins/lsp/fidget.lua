return {
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
}
