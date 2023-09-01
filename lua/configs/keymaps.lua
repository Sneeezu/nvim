local map = vim.keymap.set

map({ "n", "v" }, "<leader>y", [["+y]])
map({ "n", "v" }, "<leader>Y", [["+y$]])
map({ "n", "v" }, "<leader>p", [["+p]])
map({ "n", "v" }, "<leader>P", [["+P]])
map({ "n", "v" }, "<leader>d", [["_d]])

map("n", "<A-u>", "<cmd>vertical resize -2<CR>")
map("n", "<A-i>", "<cmd>resize +2<CR>")
map("n", "<A-o>", "<cmd>resize -2<CR>")
map("n", "<A-p>", "<cmd>vertical resize +2<CR>")

-- nice for deleting snippet placeholders
map("s", "<C-h>", [[<C-g>"_c]])
map("s", "<BS>", [[<C-g>"_c]])

map("n", "J", "mzJ`z")
map("n", "n", "nzzzv")
map("n", "N", "Nzzzv")
map("n", "<C-u>", "<C-u>zz")
map("n", "<C-d>", "<C-d>zz")

map("n", "]b", "<cmd>bnext<CR>")
map("n", "[b", "<cmd>bprevious<CR>")
map("n", "<C-j>", "<cmd>cnext<CR>zz")
map("n", "<C-k>", "<cmd>cprevious<CR>zz")

map("v", "J", ":m '>+1<CR>gv=gv")
map("v", "K", ":m '<-2<CR>gv=gv")

map("n", "<leader>e", vim.diagnostic.open_float, { desc = "Open diagnostic in float" })
map("n", "]d", vim.diagnostic.goto_next, { desc = "Go to next diagnostic" })
map("n", "[d", vim.diagnostic.goto_prev, { desc = "Go to previous diagnostic" })
map("n", "<leader>q", vim.diagnostic.setqflist, { desc = "Set quickfix list with diagnostics" })

map("n", "<leader>t", vim.cmd.Ex, { desc = "Open netrw" })
map("n", "<leader>s", "<cmd>set spell!<CR>", { desc = "Toggle spell" })
map("n", "<leader><leader>s", "<cmd>source %<CR>", { desc = "Source current file" })
map("n", "<leader>i", vim.show_pos, { desc = "Inspect Pos" })
