local signs = {
	{ texthl = "DiagnosticSignError", text = "E" },
	{ texthl = "DiagnosticSignWarn", text = "W" },
	{ texthl = "DiagnosticSignHint", text = "H" },
	{ texthl = "DiagnosticSignInfo", text = "I" },
}

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

for _, sign in ipairs(signs) do
	vim.fn.sign_define(sign.texthl, {
		icon = "",
		texthl = sign.texthl,
		text = sign.text,
	})
end
