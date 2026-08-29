local opt = vim.opt
local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- spellfile: must be a real path, '~' is not expanded in this option
opt.spellfile = vim.fn.expand('~/.vim-spell-en.utf-8.add')

opt.wildmode = { 'longest', 'list', 'full' }

-- Softtabs, 2 spaces
local indent = 2
opt.tabstop = indent
opt.shiftwidth = indent
opt.softtabstop = indent
opt.expandtab = true
opt.shiftround = true

opt.conceallevel = 1
opt.hidden = true

-- Show whitespace (replaces the nvim-listchars plugin)
opt.list = true
opt.listchars = {
  trail = '·',
  eol = '↲',
  tab = '» ',
  space = '·',
  nbsp = '·',
  extends = '>',
  precedes = '<',
}

-- system clipboard by default
opt.clipboard = 'unnamedplus'

opt.showcmd = true
opt.autowrite = true -- :write before running commands
opt.autoread = true  -- reload files changed outside vim
opt.visualbell = true

-- never have to type /g at the end of search / replace again
opt.gdefault = true

-- search
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = true
opt.incsearch = true
opt.showmatch = true
opt.inccommand = 'split'

-- make it obvious where 80 characters is
opt.textwidth = 80
opt.formatoptions = 'qrn1'
opt.wrapmargin = 0
opt.colorcolumn = '+1'
opt.linebreak = true

-- numbers: relative while working, absolute when unfocused or inserting
opt.numberwidth = 5
opt.number = true
opt.relativenumber = true

local numbers = augroup('relative-numbers', { clear = true })
autocmd({ 'FocusGained', 'InsertLeave' }, {
  group = numbers,
  callback = function() vim.opt.relativenumber = true end,
})
autocmd({ 'FocusLost', 'InsertEnter' }, {
  group = numbers,
  callback = function() vim.opt.relativenumber = false end,
})

-- open new splits to right and bottom, which feels more natural
opt.splitbelow = true
opt.splitright = true

-- scrolling
opt.scrolloff = 8
opt.sidescrolloff = 15
opt.sidescroll = 1

-- persistent undo
local undodir = '/tmp/.undodir_' .. (vim.env.USER or 'nvim')
vim.fn.mkdir(undodir, 'p', 0700)
opt.undodir = undodir
opt.undofile = true

opt.backspace = { 'eol', 'start', 'indent' }
opt.whichwrap:append '<,>,h,l'

-- spelling on for prose filetypes
autocmd('FileType', {
  group = augroup('prose-spell', { clear = true }),
  pattern = { 'tex', 'latex', 'markdown' },
  callback = function()
    vim.opt_local.spell = true
    vim.opt_local.spelllang = 'en_us'
  end,
})

-- pick up external edits when refocusing
autocmd({ 'FocusGained', 'BufEnter' }, {
  group = augroup('auto-checktime', { clear = true }),
  command = 'silent! checktime',
})

-- save whenever switching windows or leaving vim, so tests can run against
-- the current state without saving everything by hand first
autocmd({ 'FocusLost', 'WinLeave' }, {
  group = augroup('auto-save', { clear = true }),
  command = 'silent! wa',
})

-- rebalance windows on resize
autocmd('VimResized', {
  group = augroup('auto-balance', { clear = true }),
  command = 'wincmd =',
})

-- jump to the last known cursor position, except for commit messages
autocmd('BufReadPost', {
  group = augroup('last-position', { clear = true }),
  callback = function(ev)
    if vim.bo[ev.buf].filetype == 'gitcommit' then return end
    local mark = vim.api.nvim_buf_get_mark(ev.buf, '"')
    if mark[1] > 0 and mark[1] <= vim.api.nvim_buf_line_count(ev.buf) then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- highlight on yank
autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = augroup('highlight-yank', { clear = true }),
  callback = function() vim.hl.on_yank() end,
})

-- no line numbers in terminal buffers
autocmd('TermOpen', {
  group = augroup('custom-term-open', { clear = true }),
  callback = function()
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
  end,
})
