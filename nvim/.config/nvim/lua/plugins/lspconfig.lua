return {
  'neovim/nvim-lspconfig',
  dependencies = {
    { 'williamboman/mason.nvim', config = true }, -- NOTE: Must be loaded before dependants
    'williamboman/mason-lspconfig.nvim',
    'WhoIsSethDaniel/mason-tool-installer.nvim',
    { 'j-hui/fidget.nvim', opts = {} },
    { 'folke/neodev.nvim', opts = {} },
  },
  config = function()
    vim.api.nvim_create_autocmd('LspAttach', {
      group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
      callback = function(event)
        local map = function(keys, func, desc)
          vim.keymap.set('n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
        end

        map('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
        map('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
        map('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
        map('<leader>D', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')
        map('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
        map('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')
        map('<leader>cr', vim.lsp.buf.rename, '[C]ode [R]ename')
        map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')
        map('<leader>cd', vim.diagnostic.open_float, 'Line Diagnostics')
        map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

        local client = vim.lsp.get_client_by_id(event.data.client_id)
        if client and client.server_capabilities.documentHighlightProvider then
          local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
          vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
            buffer = event.buf,
            group = highlight_augroup,
            callback = vim.lsp.buf.document_highlight,
          })

          vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
            buffer = event.buf,
            group = highlight_augroup,
            callback = vim.lsp.buf.clear_references,
          })
        end

        if client and client.server_capabilities.inlayHintProvider and vim.lsp.inlay_hint then
          map('<leader>uh', function()
            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
          end, '[T]oggle Inlay [H]ints')
        end
      end,
    })

    vim.api.nvim_create_autocmd('LspDetach', {
      group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
      callback = function(event)
        vim.lsp.buf.clear_references()
        vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event.buf }
      end,
    })

    local capabilities = vim.lsp.protocol.make_client_capabilities()
    capabilities = vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())

    local servers = {
      taplo = {
        keys = {
          {
            'K',
            function()
              if vim.fn.expand '%:t' == 'Cargo.toml' and require('crates').popup_available() then
                require('crates').show_popup()
              else
                vim.lsp.buf.hover()
              end
            end,
            desc = 'Show Crate Documentation',
          },
        },
      },
      marksman = {},
      jsonls = {
        -- lazy-load schemastore when needed
        on_new_config = function(new_config)
          new_config.settings.json.schemas = new_config.settings.json.schemas or {}
          vim.list_extend(new_config.settings.json.schemas, require('schemastore').json.schemas())
        end,
        settings = {
          json = {
            format = {
              enable = true,
            },
            validate = { enable = true },
          },
        },
      },
      yamlls = {
        -- Have to add this for yamlls to understand that we support line folding
        capabilities = {
          textDocument = {
            foldingRange = {
              dynamicRegistration = false,
              lineFoldingOnly = true,
            },
          },
        },
        -- lazy-load schemastore when needed
        on_new_config = function(new_config)
          new_config.settings.yaml.schemas = vim.tbl_deep_extend('force', new_config.settings.yaml.schemas or {}, require('schemastore').yaml.schemas())
        end,
        settings = {
          redhat = { telemetry = { enabled = false } },
          yaml = {
            keyOrdering = false,
            format = {
              enable = true,
            },
            validate = true,
            schemaStore = {
              -- Must disable built-in schemaStore support to use
              -- schemas from SchemaStore.nvim plugin
              enable = false,
              -- Avoid TypeError: Cannot read properties of undefined (reading 'length')
              url = '',
            },
          },
        },
      },
      gitlab_ci_ls = {
        cmd = { '/Users/ales/personal/gitlab-lsp/target/debug/gitlab-ci-ls' },
        init_options = {
          cache = '~/.cache/gitlab-ci-ls/',
          log_path = '~/.cache/gitlab-ci-ls/log/gitlab-ci-ls.log',
        },
      },
      dockerls = {},
      docker_compose_language_service = {},
      helm_ls = {},
      gopls = {
        settings = {
          gopls = {
            gofumpt = true,
            codelenses = {
              gc_details = false,
              generate = true,
              regenerate_cgo = true,
              run_govulncheck = true,
              test = true,
              tidy = true,
              upgrade_dependency = true,
              vendor = true,
            },
            hints = {
              assignVariableTypes = true,
              compositeLiteralFields = true,
              compositeLiteralTypes = true,
              constantValues = true,
              functionTypeParameters = true,
              parameterNames = true,
              rangeVariableTypes = true,
            },
            analyses = {
              fieldalignment = true,
              nilness = true,
              unusedparams = true,
              unusedwrite = true,
              useany = true,
            },
            usePlaceholders = true,
            completeUnimported = true,
            staticcheck = true,
            directoryFilters = { '-.git', '-.vscode', '-.idea', '-.vscode-test', '-node_modules' },
            semanticTokens = true,
          },
        },
      },
      tsserver = {
        keys = {
          {
            '<leader>co',
            function()
              vim.lsp.buf.code_action {
                apply = true,
                context = {
                  only = { 'source.organizeImports.ts' },
                  diagnostics = {},
                },
              }
            end,
            desc = 'Organize Imports',
          },
          {
            '<leader>cR',
            function()
              vim.lsp.buf.code_action {
                apply = true,
                context = {
                  only = { 'source.removeUnused.ts' },
                  diagnostics = {},
                },
              }
            end,
            desc = 'Remove Unused Imports',
          },
        },
        ---@diagnostic disable-next-line: missing-fields
        settings = {
          completions = {
            completeFunctionCalls = true,
          },
        },
      },
      lua_ls = {
        settings = {
          Lua = {
            completion = {
              callSnippet = 'Replace',
            },
            hint = { enable = true },
          },
        },
      },
    }

    require('mason').setup()

    local ensure_installed = vim.tbl_keys(servers or {})
    vim.list_extend(ensure_installed, {
      'stylua', -- Used to format Lua code
      'goimports',
      'gofumpt',
      'hadolint',
      'helm-ls',
      'markdownlint',
      'marksman',
      'codelldb',
      'gitlab-ci-ls',
      'tsserver',
    })

    require('mason-tool-installer').setup { ensure_installed = ensure_installed }

    require('mason-lspconfig').setup {
      handlers = {
        function(server_name)
          local server = servers[server_name] or {}
          server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
          require('lspconfig')[server_name].setup(server)
        end,
      },
    }
  end,
}
