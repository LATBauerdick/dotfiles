
local indent = 2

vim.cmd 'syntax enable'

vim.opt.compatible = false

-- Set spellfile to location that is guaranteed to exist
vim.opt.spellfile = '~/.vim-spell-en.utf-8.add'

-- Don't redraw while executing macros (good performance config)
vim.opt.lazyredraw = true

-- Softtabs, 2 spaces
vim.opt.tabstop = indent
vim.opt.shiftwidth = indent
vim.opt.softtabstop = indent
vim.opt.expandtab = true
vim.opt.shiftround = true

vim.opt.hidden = true
vim.opt.ignorecase = true

vim.opt.number = true
vim.opt.rnu = true

-- set system clipboard to be default
vim.opt.clipboard = { 'unnamed', 'unnamedplus' } -- was unnamedplus

-- display incomplete command
vim.opt.showcmd = true

-- Automatically :write before running commands
vim.opt.autowrite = true

-- Reload files changed outside vim
vim.opt.autoread = true

vim.opt.linespace = 4
-- highlight the current line
vim.opt.cursorline = true
-- highlight the current column
-- vim.opt.cursorcolumn
-- stop that ANNOYING beeping
vim.opt.visualbell = true

-- Allow usage of mouse in iTerm
vim.opt.ttyfast = true
vim.opt.mouse = 'a'

-- Never have to type /g at the end of search / replace again
vim.opt.gdefault = true

vim.opt.smartcase = true
vim.opt.hlsearch = true
vim.opt.incsearch = true
vim.opt.showmatch = true

-- Make it obvious where 80 characters is
vim.opt.textwidth = 80
-- vim.opt.formatoptions =  'cq'
vim.opt.formatoptions = 'qrn1'
vim.opt.wrapmargin = 0
vim.opt.colorcolumn = '+1'
vim.opt.linebreak = true

-- Numbers
vim.opt.numberwidth = 5

-- Open new split panes to right and bottom, which feels more natural
vim.opt.splitbelow = true
vim.opt.splitright = true

-- ================ Scrolling ========================
-- Start scrolling when we're 8 lines away from margins
vim.opt.scrolloff=8
vim.opt.sidescrolloff=15
vim.opt.sidescroll=1

