vim.api.nvim_create_user_command('ConformToggle', function(args)
  if args.bang then
    -- ConformToggle! will disable formatting just for this buffer
    vim.b.disable_autoformat = not (vim.b.disable_autoformat or false)
  else
    vim.g.disable_autoformat = not (vim.g.disable_autoformat or false)
  end
end, {
  desc = 'Conform toggle autoformat-on-save',
  bang = true,
})

return {
  'stevearc/conform.nvim',
  lazy = false,
  keys = {
    {
      '<leader>cf',
      function()
        require('conform').format { async = true, lsp_fallback = true }
      end,
      mode = '',
      desc = '[F]ormat buffer',
    },
    {
      '<leader>ufa',
      '<cmd>ConformToggle<cr>',
      mode = '',
      desc = '[U]I auto[F]ormat toggle [A]ll buffers',
    },
    {
      '<leader>ufc',
      '<cmd>ConformToggle!<cr>',
      mode = '',
      desc = '[U]I auto[F]ormat toggle [C]urrent buffer',
    },
  },
  opts = {
    notify_on_error = false,
    format_on_save = function(bufnr)
      -- add ability to disable autoformat
      print(vim.inspect(vim.g.disable_autoformat))
      print(vim.inspect(vim.b[bufnr].disable_autoformat))
      if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
        return
      end

      -- Disable "format_on_save lsp_fallback" for languages that don't
      -- have a well standardized coding style. You can add additional
      -- languages here or re-enable it for the disabled ones.
      local disable_filetypes = { c = true, cpp = true }
      return {
        timeout_ms = 500,
        lsp_fallback = not disable_filetypes[vim.bo[bufnr].filetype],
      }
    end,
    formatters_by_ft = {
      ['lua'] = { 'stylua' },
      ['go'] = { 'goimports', 'gofumpt' },
      ['javascript'] = { 'prettier' },
      ['javascriptreact'] = { 'prettier' },
      ['typescript'] = { 'prettier' },
      ['typescriptreact'] = { 'prettier' },
      ['vue'] = { 'prettier' },
      ['css'] = { 'prettier' },
      ['scss'] = { 'prettier' },
      ['less'] = { 'prettier' },
      ['html'] = { 'prettier' },
      ['json'] = { 'prettier' },
      ['jsonc'] = { 'prettier' },
      ['yaml'] = { 'prettier' },
      ['markdown'] = { 'prettier' },
      ['markdown.mdx'] = { 'prettier' },
      ['graphql'] = { 'prettier' },
      ['handlebars'] = { 'prettier' },
      ['sh'] = { 'shfmt' },
    },
  },
}
