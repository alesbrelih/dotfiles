return {
  'catppuccin/nvim',
  priority = 1000,
  init = function()
    vim.cmd.colorscheme 'catppuccin'
  end,
  config = function(_, _)
    require('catppuccin').setup {
      flavour = 'frappe',
      integrations = {
        cmp = true,
        mason = true,
        fidget = true,
        native_lsp = true,
        markdown = true,
        harpoon = true,
        neotree = true,
        gitsigns = true,
        telescope = true,
        mini = {
          enabled = true,
          indentscope_color = '', -- catppuccin color (eg. `lavender`) Default: text
        },
      },
    }
  end,
}
