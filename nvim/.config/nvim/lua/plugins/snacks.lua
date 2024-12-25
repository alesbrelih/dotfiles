return {
  {
    'folke/snacks.nvim',
    ---@type snacks.Config
    opts = {
      lazygit = {
        -- your lazygit configuration comes here
        -- or leave it empty to use the default settings
        -- refer to the configuration section below
      },
      bigfile = {
        -- your bigfile configuration comes here
        -- or leave it empty to use the default settings
        -- refer to the configuration section below
      },
    },
    config = function()
      vim.api.nvim_create_autocmd('User', {
        pattern = 'MiniFilesActionRename',
        callback = function(event)
          require('snacks').rename.on_rename_file(event.data.from, event.data.to)
        end,
      })
    end,
    keys = {
      {
        '<leader>gg',
        function()
          require('snacks').lazygit()
        end,
      },
    },
  },
}
