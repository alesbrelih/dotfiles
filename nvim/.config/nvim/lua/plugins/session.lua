return {
  {
    'folke/persistence.nvim',
    event = 'BufReadPre',
    opts = { options = vim.opt.sessionoptions:get() },
    keys = {
      {
        '<leader>ss',
        function()
          require('persistence').load()
        end,
        mode = 'n',
        desc = '[S]session load',
      },
      {
        '<leader>sd',
        function()
          require('persistence').load { last = true }
        end,
        mode = 'n',
        desc = '[S]session load',
      },
    },
  },
}
