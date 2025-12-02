return {
  -- add Lua-scriptable solarized color scheme
  {
    "maxmx03/solarized.nvim",
    enabled = true,
    branch = "main",
    lazy = false,
    name = "solarized",
    main = "solarized",
    priority = 1000,
    -- Display colors in a new buffer with command: `:Solarized colors`
    -- See: https://www.lazyvim.org/configuration/plugins#%EF%B8%8F-customizing-plugin-specs
    opts = {
      -- See: https://github.com/maxmx03/solarized.nvim/blob/main/lua/solarized/palette.lua
      -- palette = "selenized",
      -- variant = "spring",
      -- See: https://github.com/maxmx03/solarized.nvim?tab=readme-ov-file#default-config
      styles = {
        keywords = { bold = false },
      },
    },
    config = function(plugin, opts)
      vim.o.background = "dark"
      require(plugin.main).setup(opts)
      vim.cmd.colorscheme = "solarized"
    end,
  },
}
