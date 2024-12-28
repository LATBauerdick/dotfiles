return { -- use blink-cmp
  {
    'saghen/blink.cmp',
    dependencies = 'rafamadriz/friendly-snippets',
    version = '*',
    --   --   build = 'nix run .#build-plugin',
    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
      keymap = { preset = 'super-tab' },
      -- keymap = { preset = 'enter' },
      appearance = {
        nerd_font_variant = 'mono'
      },
      sources = {
        default = { 'lsp', 'path', 'snippets', 'buffer' },
      },
    },
    -- opts_extend = { "sources.default" },
    completion = {
      keyword = { range = 'prefix' },
      documentation = { auto_show = true, auto_show_delay_ms = 500 },
      ghost_text = { enabled = false },
    },
  },
}
-- return {
--
--   { -- Autocompletion
--     'hrsh7th/nvim-cmp',
--     dependencies = { 'saadparwaiz1/cmp_luasnip' },
--     config = require("config.plugins.overrides.autocompletion").cmpsetup,
--   },
--   { "hrsh7th/cmp-buffer", },
--   { "hrsh7th/cmp-path", },
--   { "hrsh7th/cmp-cmdline", },
--   { "hrsh7th/cmp-nvim-lua", },
-- }
