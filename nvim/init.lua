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
  install = { colorscheme = { "tokyonight" } },
  change_detection = { notify = false },
})
