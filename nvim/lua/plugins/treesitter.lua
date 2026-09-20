-- Realce de sintaxe real (parser, não regex). É o que faz o tokyonight ficar
-- com as cores das screenshots: sem isso o nvim usa o syntax antigo do vim.
return {
  "nvim-treesitter/nvim-treesitter",
  branch = "master",             -- main exige nvim 0.11; o apt do Debian 13 traz 0.10
  build = ":TSUpdate",
  event = { "BufReadPost", "BufNewFile" },
  main = "nvim-treesitter.configs",
  opts = {
    ensure_installed = {
      "typescript", "tsx", "javascript", "html", "css", "scss", "json", "yaml",
      "java", "python", "bash", "lua", "vim", "vimdoc", "markdown", "markdown_inline",
      "regex", "dockerfile", "sql",
    },
    auto_install = true,          -- abriu um tipo novo? baixa o parser sozinho (precisa de gcc)
    highlight = { enable = true },
    indent = { enable = true },
  },
}
