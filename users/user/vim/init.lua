
-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
-- This is also a good place to setup other settings (vim.opt)
vim.g.mapleader = " "
vim.g.maplocalleader = ','
--vim.g.maplocalleader = "\\"

require("config.settings")

require("config.lazy")

require("config.keymappings")

local x="init done!"
print (x)


