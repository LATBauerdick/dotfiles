-- lua/plugins/mini.lua
return {
  {
    'echasnovski/mini.nvim',
    enabled = true,
    config = function()
      require('mini.ai').setup()
      require('mini.surround').setup()
      require('mini.operators').setup()
      require('mini.pairs').setup()
      require('mini.bracketed').setup()
      require('mini.files').setup()
    end
  }
}
