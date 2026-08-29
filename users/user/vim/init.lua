-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
-- This is also a good place to setup other settings (vim.opt)
vim.g.mapleader = " "
vim.g.maplocalleader = ','
--vim.g.maplocalleader = "\\"

require("config.settings")

require("config.lazy")

require("config.keymappings")

-- NOTE: background/colorscheme are owned by lua/config/plugins/colors.lua.
-- Do not set background here: this file runs after lazy loads plugins, so a
-- setting here silently overrides the colorscheme's own choice.
