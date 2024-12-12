-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
vim.keymap.set("x", "<leader>p", '"_dP"')
vim.keymap.set("n", ";", ":")
-- vim.keymap.set("n", "<F5>", ":CMakeRun<CR>")

-- Move terminal toggle to CTRL+SHIFT+/
-- Unmap the default terminal toggle
-- vim.keymap.del({ "n", "t" }, "<C-/>")
-- Map CTRL+/ for single line comment
-- vim.keymap.set("n", "<C-/>", "gcc", { remap = true }) -- Normal mode
-- vim.keymap.set("v", "<C-/>", "gc", { remap = true }) -- Visual mode
