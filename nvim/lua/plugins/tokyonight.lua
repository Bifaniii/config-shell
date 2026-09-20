-- Tema: https://github.com/folke/tokyonight.nvim
-- Estilos: "night" | "storm" | "moon" | "day"
-- A paleta do gnome-terminal (gnome/terminal.dconf) foi gerada a partir do mesmo estilo.
return {
  "folke/tokyonight.nvim",
  lazy = false,
  priority = 1000,
  opts = {
    style = "night",
    transparent = true,          -- fundo NONE: deixa o blur do terminal aparecer
    styles = {
      comments = { italic = true },
      keywords = { italic = false },
      sidebars = "transparent",
      floats = "transparent",
    },
  },
  config = function(_, opts)
    require("tokyonight").setup(opts)
    vim.cmd.colorscheme("tokyonight")
  end,
}
