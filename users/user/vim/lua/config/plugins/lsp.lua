-- Completion + LSP.
--
-- blink.cmp replaces the whole nvim-cmp stack (nvim-cmp, cmp-buffer, cmp-path,
-- cmp-emoji, cmp-nvim-lsp, lspkind, LuaSnip, friendly-snippets): it has LSP,
-- path, snippet and buffer sources built in.
--
-- LSP servers are configured with vim.lsp.config / vim.lsp.enable (0.11+), so
-- nvim-lspconfig is not needed. Capabilities are set once via the '*' wildcard
-- rather than repeated per server.

return {
  {
    'saghen/blink.cmp',
    -- Pin to a v1 tag, not '*'. blink ships a Rust fuzzy matcher and infers
    -- which prebuilt binary to download from the checked-out git tag; on a
    -- bare commit it refuses to download and hard-errors at startup. There is
    -- no cargo on this machine, so building from source is not an option.
    version = '1.*',
    lazy = false, -- owns the LSP setup below, so it must load at startup
    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
      keymap = { preset = 'super-tab' },
      appearance = { nerd_font_variant = 'mono' },
      sources = {
        default = { 'lsp', 'path', 'snippets', 'buffer' },
      },
      completion = {
        documentation = { auto_show = true, auto_show_delay_ms = 500 },
        ghost_text = { enabled = false },
      },
    },
    config = function(_, opts)
      require('blink.cmp').setup(opts)

      -- One global capabilities default for every server.
      vim.lsp.config('*', {
        capabilities = require('blink.cmp').get_lsp_capabilities(),
      })

      vim.lsp.config.purescriptls = {
        cmd = { 'purescript-language-server', '--stdio' },
        filetypes = { 'purescript' },
        root_markers = { 'spago.dhall', 'spago.yaml', 'psc-package.json', 'bower.json' },
      }
      vim.lsp.enable('purescriptls')

      -- Format on save, for servers that can.
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('lsp-format-on-save', { clear = true }),
        callback = function(ev)
          local client = vim.lsp.get_client_by_id(ev.data.client_id)
          if not client then return end
          if client:supports_method('textDocument/formatting') then
            vim.api.nvim_create_autocmd('BufWritePre', {
              buffer = ev.buf,
              callback = function()
                vim.lsp.buf.format({ bufnr = ev.buf, id = client.id })
              end,
            })
          end
        end,
      })

      -- nvim-lspconfig normally provides :LspInfo; we are not using it.
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

  {
    'folke/lazydev.nvim',
    ft = 'lua', -- only load on lua files
    opts = {
      library = {
        -- Load luvit types when the `vim.uv` word is found
        { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
      },
    },
    config = function(_, opts)
      require('lazydev').setup(opts)

      vim.lsp.config.lua_ls = {
        cmd = { 'lua-language-server' },
        filetypes = { 'lua' },
        root_markers = {
          '.luarc.json', '.luarc.jsonc', '.luacheckrc',
          '.stylua.toml', 'stylua.toml', 'selene.toml', 'selene.yml', '.git',
        },
      }
      vim.lsp.enable('lua_ls')
    end,
  },
}
