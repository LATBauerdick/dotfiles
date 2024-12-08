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
      local custom_solarized = require'lualine.themes.solarized_light'
      custom_solarized.normal.a.bg = '#b58900'
      require('lualine').setup {
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


