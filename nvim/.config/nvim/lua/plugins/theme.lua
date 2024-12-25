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
        leap = true,
        mason = true,
        fidget = true,
        markdown = true,
        harpoon = true,
        neotree = true,
        gitsigns = true,
        telescope = true,
        treesitter = true,
        treesitter_context = true,
        mini = {
          enabled = true,
          indentscope_color = '', -- catppuccin color (eg. `lavender`) Default: text
        },
        native_lsp = {
          enabled = true,
          virtual_text = {
            errors = { 'italic' },
            hints = { 'italic' },
            warnings = { 'italic' },
            information = { 'italic' },
          },
          underlines = {
            errors = { 'underline' },
            hints = { 'underline' },
            warnings = { 'underline' },
            information = { 'underline' },
          },
          inlay_hints = {
            background = false,
          },
        },

        Special,
      },
    }
  end,
}
