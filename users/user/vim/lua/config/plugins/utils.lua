return {
  -- 'tpope/vim-surround',
  -- 'tpope/vim-unimpaired',
  -- 'tpope/vim-repeat',
  -- 'tpope/vim-dispatch',
  'jiangmiao/auto-pairs',
  {
    'terryma/vim-smooth-scroll',
    config = function()
      -- remap for smooth scroll
      vim.keymap.set('n', '<c-u>', ':call smooth_scroll#up(&scroll, 0, 2)<CR>')
      vim.keymap.set('n', '<c-d>', ':call smooth_scroll#down(&scroll, 0, 2)<CR>')
      vim.keymap.set('n', '<c-b>', ':call smooth_scroll#up(&scroll*2, 0, 4)<CR>')
      vim.keymap.set('n', '<c-f>', ':call smooth_scroll#down(&scroll*2, 0, 4)<CR>')
    end
  },
  {
    "fraso-dev/nvim-listchars",
    event = "BufEnter",
    config = function()
      require("nvim-listchars").setup({
        save_state = false,
        listchars = {
          trail = "·", -- "-",
          eol = "↲", -- "¬"
          tab = "» ",
          space = "·", --"␣"
          nbsp = "·",
          extends = ">",
          precedes = "<",
        },
        notifications = true,
        exclude_filetypes = {},
        lighten_step = 10,
      })
    end,

  },
}
