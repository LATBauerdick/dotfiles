-- Set lualine as statusline
-- See `:help lualine.txt`
return {
  {
    'nvim-lualine/lualine.nvim',
    enabled = true,
    dependencies = {
      'kyazdani42/nvim-web-devicons',
      opt = true,
    },
    config = function ()
      require('lualine').setup {
          -- 'auto' follows the active colorscheme (catppuccin-mocha).
          -- Do not use theme = 'catppuccin': no such lualine theme module
          -- exists, and lualine falls back silently instead of erroring.
          options = { theme = 'auto' },
          tabline = {
            lualine_a = {'buffers'},
            lualine_b = {},
            lualine_c = {},
            lualine_x = {},
            lualine_y = {},
            lualine_z = {'tabs'}
          }
      }
    end
  }
}


