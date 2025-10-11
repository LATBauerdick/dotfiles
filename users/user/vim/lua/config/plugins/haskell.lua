return {
  'mrcjkb/haskell-tools.nvim',
  version = '^4', -- Recommended
  ft = { 'haskell', 'lhaskell', 'cabal', 'cabalproject' },
  dependencies = {
    'nvim-lua/plenary.nvim',
    'hrsh7th/cmp-nvim-lsp', -- For LSP capabilities
  },
  init = function()
    -- Configure haskell-tools using vim.g.haskell_tools BEFORE plugin loads
    vim.g.haskell_tools = {
      tools = {
        -- repl = {
        --   handler = 'toggleterm',
        -- },
        -- hover = {
        --   enable = true,
        --   border = {
        --     { "╭", "FloatBorder" },
        --     { "─", "FloatBorder" },
        --     { "╮", "FloatBorder" },
        --     { "│", "FloatBorder" },
        --     { "╯", "FloatBorder" },
        --     { "─", "FloatBorder" },
        --     { "╰", "FloatBorder" },
        --     { "│", "FloatBorder" },
        --   },
        -- },
      },
      hls = {
        on_attach = function(client, bufnr, ht)
          -- Set up keybindings on LSP attach
          local opts = { noremap = true, silent = true, buffer = bufnr }

          -- Haskell-specific keymaps
          vim.keymap.set('n', '<space>cl', vim.lsp.codelens.run, opts)
          vim.keymap.set('n', '<space>hs', ht.hoogle.hoogle_signature, opts)
          vim.keymap.set('n', '<space>ea', ht.lsp.buf_eval_all, opts)
          vim.keymap.set('n', '<leader>rr', ht.repl.toggle, opts)
          vim.keymap.set('n', '<leader>rf', function()
            ht.repl.toggle(vim.api.nvim_buf_get_name(0))
          end, opts)
          vim.keymap.set('n', '<leader>rq', ht.repl.quit, opts)

          -- Standard LSP keymaps (if not set globally)
          vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
          vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
          vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
          vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
          vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
        end,
        capabilities = require('cmp_nvim_lsp').default_capabilities(),
      },
    }
  end,
}

