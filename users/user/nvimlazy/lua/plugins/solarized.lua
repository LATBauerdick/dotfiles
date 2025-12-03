return {
  -- add Lua-scriptable solarized color scheme
  {
    "maxmx03/solarized.nvim",
    enabled = true,
    opts = {
      -- See: https://github.com/maxmx03/solarized.nvim?tab=readme-ov-file#docs
      palette = "selenized",
      variant = "winter",
    },
    -- config = function(plugin, opts)
    --   -- vim.o.background = "dark"
    --   -- require(plugin.main).setup(opts)
    -- vim.cmd.colorscheme = "solarized"
    -- end,
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "solarized",
    },
  },
}
