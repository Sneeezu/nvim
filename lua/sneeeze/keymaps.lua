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
map("n", "]q", "<cmd>cnext<CR>zz")
map("n", "[q", "<cmd>cprevious<CR>zz")

map("n", "<leader>t", vim.cmd.Ex, { desc = "Open netrw" })
map("n", "<leader>s", "<cmd>set spell!<CR>", { desc = "Toggle spell" })
map("n", "<leader><leader>s", "<cmd>source %<CR>", { desc = "Source current file" })
map("n", "<leader>i", vim.show_pos, { desc = "Inspect Pos" })
