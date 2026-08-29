return {
  {
    'echasnovski/mini.nvim',
    config = function()
      require('mini.ai').setup()
      require('mini.surround').setup()
      require('mini.pairs').setup()
      require('mini.bracketed').setup()
      require('mini.files').setup()

      -- Uppercase prefixes. The mini.operators defaults (gx/gm/gr/gs) shadow
      -- built-ins that are worth keeping -- notably `gx` (open the URL/file
      -- under the cursor) and the whole `gr` LSP prefix. The uppercase forms
      -- only displace `gR` (virtual replace mode) and `gM` (middle of text
      -- line), both far rarer.
      require('mini.operators').setup({
        exchange = { prefix = 'gX' },
        multiply = { prefix = 'gM' },
        replace  = { prefix = 'gR' },
        sort     = { prefix = 'gS' },
      })
    end
  }
}
