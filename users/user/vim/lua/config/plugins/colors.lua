-- Colorschemes.
--
-- catppuccin-mocha is the default, matching ghostty, which pins both modes to
-- Mocha in users/user/ghostty/config:
--   theme = dark:Catppuccin Mocha,light:Catppuccin Mocha
--
-- Solarized stays installed but is not loaded at startup, so it can be
-- switched to at runtime:
--   :Theme catppuccin        (dark, matches ghostty)
--   :Theme solarized-light
--   :Theme solarized-dark
--   <leader>ut               toggle catppuccin <-> solarized-light
--
-- NOTE: do not use vim.g.colors_name to decide what is active. Switching
-- between these two plugins leaves it nil or stale (catppuccin's
-- "OptionSet background" handler clobbers it) even though the highlights
-- applied are correct. Track the choice here instead.

local themes = {
  ['catppuccin']      = { scheme = 'catppuccin', background = 'dark' },
  ['solarized-light'] = { scheme = 'solarized',  background = 'light' },
  ['solarized-dark']  = { scheme = 'solarized',  background = 'dark' },
}

local current = 'catppuccin'

local function apply(name)
  local t = themes[name]
  if not t then
    vim.notify('unknown theme: ' .. tostring(name), vim.log.levels.ERROR)
    return
  end
  if t.scheme == 'solarized' then
    require('lazy').load { plugins = { 'nvim-solarized-lua' } }
  end
  vim.o.background = t.background
  vim.cmd.colorscheme(t.scheme)
  current = name
end

return {
  {
    'catppuccin/nvim',
    name = 'catppuccin',
    priority = 1000, -- load before other plugins so highlights are in place
    config = function()
      vim.o.termguicolors = true
      require('catppuccin').setup {
        flavour = 'mocha',
        background = { light = 'mocha', dark = 'mocha' },
        integrations = {
          gitsigns = true,
          lualine = true,
          mini = true,
          telescope = true,
          treesitter = true,
        },
      }
      apply('catppuccin')

      vim.api.nvim_create_user_command('Theme', function(o)
        apply(o.args)
      end, {
        nargs = 1,
        complete = function()
          return vim.tbl_keys(themes)
        end,
        desc = 'Switch colorscheme',
      })

      vim.keymap.set('n', '<leader>ut', function()
        apply(current == 'catppuccin' and 'solarized-light' or 'catppuccin')
      end, { desc = 'Toggle catppuccin / solarized' })
    end
  },

  -- Installed but not loaded at startup; apply() pulls it in on demand.
  {
    'ishan9299/nvim-solarized-lua',
    lazy = true,
  },
}
