return {
  {
    'ishan9299/nvim-solarized-lua',
    config = function()
      vim.o.termguicolors = true
      vim.cmd [[colorscheme solarized]]
      -- vim.cmd [[ set background=light ]]
      vim.cmd [[ set background=dark ]]
    end
  }
}
