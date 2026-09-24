-- Neo-tree is a Neovim plugin to browse the file system
-- https://github.com/nvim-neo-tree/neo-tree.nvim

vim.pack.add {
  { src = 'https://github.com/nvim-neo-tree/neo-tree.nvim', version = vim.version.range '*' },
  'https://github.com/nvim-lua/plenary.nvim',
  'https://github.com/MunifTanjim/nui.nvim',
}

vim.keymap.set('n', '\\', '<Cmd>Neotree reveal<CR>', { desc = 'NeoTree reveal', silent = true })
vim.keymap.set('n', '<leader>e', '<Cmd>Neotree toggle<CR>', { desc = 'Explorador de arquivos', silent = true })

require('neo-tree').setup {
  -- Sem Nerd Font: ícones em texto/Unicode comum
  default_component_configs = not vim.g.have_nerd_font and {
    indent = { with_expanders = false },
    icon = { folder_closed = '▸', folder_open = '▾', folder_empty = '▹', folder_empty_open = '▿', default = ' ' },
    modified = { symbol = '●' },
    git_status = {
      symbols = {
        added = '+',
        modified = '~',
        deleted = '-',
        renamed = '→',
        untracked = '?',
        ignored = '◌',
        unstaged = '✗',
        staged = '✓',
        conflict = '!',
      },
    },
    diagnostics = { symbols = { error = 'E', warn = 'W', info = 'I', hint = 'H' } },
  } or nil,
  filesystem = {
    window = {
      mappings = {
        ['\\'] = 'close_window',
      },
    },
  },
}
