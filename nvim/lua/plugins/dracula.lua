-- Tema: https://github.com/Mofiqul/dracula.nvim (mesmas cores do Dracula do VS Code)
-- A paleta do gnome-terminal (gnome/terminal-dracula.dconf) é a oficial do dracula/gnome-terminal.
return {
  "Mofiqul/dracula.nvim",
  lazy = false,
  priority = 1000,
  opts = {
    transparent_bg = true,       -- fundo NONE: deixa o blur do terminal aparecer
    italic_comment = true,
  },
  config = function(_, opts)
    require("dracula").setup(opts)
    vim.cmd.colorscheme("dracula")
  end,
}
