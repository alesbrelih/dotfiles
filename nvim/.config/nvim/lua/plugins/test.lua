return {
  {
    'vim-test/vim-test',
    dependencies = {
      'preservim/vimux',
    },
    keys = {
      {
        '<leader>tn',
        '<cmd>TestNearest<cr>',
        mode = 'n',
        desc = '[T]est [N]earest',
      },
      {
        '<leader>tf',
        '<cmd>TestFile<cr>',
        mode = 'n',
        desc = '[T]est [F]ile',
      },
      {
        '<leader>tl',
        '<cmd>TestLast<cr>',
        mode = 'n',
        desc = '[T]est [l]last',
      },
    },
    config = function(_, _)
      vim.cmd 'let test#strategy = "vimux"'
    end,
  },
}
