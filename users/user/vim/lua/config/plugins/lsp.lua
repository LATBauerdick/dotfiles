return {
  {
    'saghen/blink.cmp',
  },
  {
    "folke/lazydev.nvim",
    ft = "lua", -- only load on lua files
    dependencies = {
      'hrsh7th/cmp-nvim-lsp', -- For LSP capabilities
    },
    opts = {
      library = {
        -- See the configuration section for more details
        -- Load luvit types when the `vim.uv` word is found
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
      },
    },
    config = function(_, opts)
      require("lazydev").setup(opts)

      -- Configure lua_ls using vim.lsp.config
      vim.lsp.config.lua_ls = {
        cmd = { 'lua-language-server' },
        filetypes = { 'lua' },
        root_markers = { '.luarc.json', '.luarc.jsonc', '.luacheckrc', '.stylua.toml', 'stylua.toml', 'selene.toml', 'selene.yml', '.git' },
        capabilities = require('cmp_nvim_lsp').default_capabilities(),
      }

      -- Enable lua_ls
      vim.lsp.enable('lua_ls')
    end,
  },
  {
    -- PureScript LSP configuration
    name = "purescript-lsp-config",
    dir = vim.fn.stdpath('config'), -- dummy dir since this is just config
    config = function()
      -- Configure purescriptls using vim.lsp.config
      vim.lsp.config.purescriptls = {
        cmd = { 'purescript-language-server', '--stdio' },
        filetypes = { 'purescript' },
        root_markers = { 'spago.dhall', 'spago.yaml', 'psc-package.json', 'bower.json' },
        capabilities = require('cmp_nvim_lsp').default_capabilities(),
      }

      -- Enable purescriptls
      vim.lsp.enable('purescriptls')
    end,
  },
  {
    -- LSP auto-formatting on save
    name = "lsp-format-on-save",
    dir = vim.fn.stdpath('config'), -- dummy dir since this is just config
    config = function()
      vim.api.nvim_create_autocmd('LspAttach', {
        callback = function(ev)
          local client = vim.lsp.get_client_by_id(ev.data.client_id)
          if not client then return end
          if client.supports_method('textDocument/formatting') then
            vim.api.nvim_create_autocmd('BufWritePre', {
              buffer = ev.buf,
              callback = function()
                vim.lsp.buf.format({ bufnr = ev.buf, id = client.id })
              end,
            })
          end
        end,
      })

      -- Create LspInfo command since we're not using nvim-lspconfig
      vim.api.nvim_create_user_command('LspInfo', function()
        local clients = vim.lsp.get_clients({ bufnr = 0 })
        if #clients == 0 then
          print('No LSP clients attached to this buffer')
          return
        end

        for _, client in ipairs(clients) do
          print(string.format('Client: %s (id %d)', client.name, client.id))
          print(string.format('  Root directory: %s', client.root_dir or 'N/A'))
          print(string.format('  Filetypes: %s', table.concat(client.config.filetypes or {}, ', ')))
        end
      end, { desc = 'Display LSP client information' })
    end,
  },
}
