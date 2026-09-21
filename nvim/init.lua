-- ~/.config/nvim/init.lua  (symlink -> ~/config-shell/nvim)

-- ---------- Opções (mesmo comportamento do .vimrc) ----------
local o = vim.opt
o.number = true            -- número das linhas
o.termguicolors = true     -- True Color
o.tabstop = 4
o.shiftwidth = 4
o.expandtab = true
o.smarttab = true
o.showmatch = true
o.incsearch = true
o.hlsearch = true
o.showcmd = true
o.mouse = "a"
o.clipboard = "unnamedplus"  -- yank/paste direto no clipboard do sistema

-- ---------- Atalhos ----------
vim.g.mapleader = " "          -- <leader> = Espaço (tem que vir antes do lazy)
local map = vim.keymap.set
map("n", "<C-h>", "<C-w>h", { desc = "Janela à esquerda" })
map("n", "<C-j>", "<C-w>j", { desc = "Janela abaixo" })
map("n", "<C-k>", "<C-w>k", { desc = "Janela acima" })
map("n", "<C-l>", "<C-w>l", { desc = "Janela à direita" })
map("n", "<Esc>", "<cmd>nohlsearch<cr>", { desc = "Limpa destaque da busca" })
map("n", "<leader>w", "<cmd>w<cr>", { desc = "Salvar" })
map("n", "<leader>q", "<cmd>q<cr>", { desc = "Fechar" })

-- ---------- lazy.nvim (gerenciador de plugins) ----------
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none", "--branch=stable",
    "https://github.com/folke/lazy.nvim.git", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup("plugins", {
  install = { colorscheme = { "dracula" } },
  change_detection = { notify = false },
})
