return {
  'mrcjkb/haskell-tools.nvim',
  version = '^4', -- Recommended
  ft = { 'haskell', 'lhaskell', 'cabal', 'cabalproject' },
  dependencies = {
    'nvim-lua/plenary.nvim',
  },
  init = function()
    -- Configure haskell-tools using vim.g.haskell_tools BEFORE plugin loads.
    -- Capabilities come from the vim.lsp.config('*') default in lsp.lua.
    vim.g.haskell_tools = {
      hls = {
        on_attach = function(client, bufnr, ht)
          local opts = { noremap = true, silent = true, buffer = bufnr }

          -- Haskell-specific only. K/gd/gD/gi/gr are Neovim 0.11 defaults or
          -- set globally in keymappings.lua; do not redefine them here.
          vim.keymap.set('n', '<space>cl', vim.lsp.codelens.run, opts)
          vim.keymap.set('n', '<space>hs', ht.hoogle.hoogle_signature, opts)
          vim.keymap.set('n', '<space>ea', ht.lsp.buf_eval_all, opts)
          vim.keymap.set('n', '<leader>rr', ht.repl.toggle, opts)
          vim.keymap.set('n', '<leader>rf', function()
            ht.repl.toggle(vim.api.nvim_buf_get_name(0))
          end, opts)
          vim.keymap.set('n', '<leader>rq', ht.repl.quit, opts)
        end,
      },
    }
  end,
}
