-- Navegação de projeto pelo teclado
--   <Space>e   abre/fecha a árvore de arquivos (nvim-tree)
--   <Space>ff  busca arquivo por nome (telescope)
--   <Space>fg  busca texto dentro do projeto (precisa do ripgrep)
--   <Space>fb  lista buffers abertos
--   <Space>fr  arquivos recentes
return {
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    keys = {
      { "<leader>e", "<cmd>NvimTreeToggle<cr>",   desc = "Árvore de arquivos" },
      { "<leader>E", "<cmd>NvimTreeFindFile<cr>", desc = "Árvore: ir pro arquivo atual" },
    },
    opts = {
      view = { width = 32 },
      renderer = { indent_markers = { enable = true }, group_empty = true },
      filters = { dotfiles = false, custom = { "^.git$" } },
      update_focused_file = { enable = true },
    },
  },
  {
    "nvim-telescope/telescope.nvim",
    branch = "0.1.x",              -- master exige nvim 0.11; o apt do Debian 13 traz 0.10
    dependencies = { "nvim-lua/plenary.nvim" },
    cmd = "Telescope",
    keys = {
      { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Buscar arquivo" },
      { "<leader>fg", "<cmd>Telescope live_grep<cr>",  desc = "Buscar texto" },
      { "<leader>fb", "<cmd>Telescope buffers<cr>",    desc = "Buffers" },
      { "<leader>fr", "<cmd>Telescope oldfiles<cr>",   desc = "Recentes" },
    },
    opts = {
      defaults = { file_ignore_patterns = { "node_modules", "%.git/", "dist/", "target/" } },
    },
  },
}
