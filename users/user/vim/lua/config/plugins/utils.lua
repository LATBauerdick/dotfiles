
return {
  'tpope/vim-surround',
  'tpope/vim-unimpaired',
  'tpope/vim-repeat',
  'tpope/vim-dispatch',
  'jiangmiao/auto-pairs',
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
        exclude_filetypes = {  },
        lighten_step = 10,
      })
    end,

  },
}
