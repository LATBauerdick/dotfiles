vim.opt.compatible = false

-- Set spellfile to location that is guaranteed to exist
vim.opt.spellfile = '~/.vim-spell-en.utf-8.add'

-- make sure spelling is on for markdown etc
vim.cmd [[autocmd FileType tex,latex,markdown setlocal spell spelllang=en_us]]

vim.opt.wildmode = { 'longest', 'list', 'full' }

-- Softtabs, 2 spaces
local indent = 2
vim.opt.tabstop = indent
vim.opt.shiftwidth = indent
vim.opt.softtabstop = indent
vim.opt.expandtab = true
vim.opt.shiftround = true

vim.opt.conceallevel = 1

-- Show trailing whitespace
vim.opt.list = true
vim.opt.hidden = true

-- set system clipboard to be default
vim.opt.clipboard = 'unnamedplus' --  was { 'unnamed', 'unnamedplus' }

-- display incomplete command
vim.opt.showcmd = true

-- Automatically :write before running commands
vim.opt.autowrite = true

-- Reload files changed outside vim
vim.opt.autoread = true

vim.opt.linespace = 4
-- highlight the current line
-- vim.opt.cursorline = true
-- highlight the current column
-- vim.opt.cursorcolumn
-- stop that ANNOYING beeping
vim.opt.visualbell = true

-- Never have to type /g at the end of search / replace again
vim.opt.gdefault = true

-- search options
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = true
vim.opt.incsearch = true
vim.opt.showmatch = true
-- see :h icm
vim.opt.icm = 'split'

-- Make it obvious where 80 characters is
vim.opt.textwidth = 80
-- vim.opt.formatoptions =  'cq'
vim.opt.formatoptions = 'qrn1'
vim.opt.wrapmargin = 0
vim.opt.colorcolumn = '+1'
vim.opt.linebreak = true

-- Numbers
vim.opt.numberwidth = 5

vim.opt.number = true
vim.opt.rnu = true

-- Toggle relative numbering, and set to absolute on loss of focus or insert mode
vim.cmd [[
function! ToggleNumbersOn()
    set nu!
    set rnu
endfunction
function! ToggleRelativeOn()
    set rnu!
    set nu
endfunction
autocmd FocusLost * call ToggleRelativeOn()
autocmd FocusGained * call ToggleRelativeOn()
autocmd InsertEnter * call ToggleRelativeOn()
autocmd InsertLeave * call ToggleRelativeOn()
]]

-- Open new split panes to right and bottom, which feels more natural
vim.opt.splitbelow = true
vim.opt.splitright = true

---------------------Scrolling-----------------------
-- Start scrolling when we're 8 lines away from margins
vim.opt.scrolloff = 8
vim.opt.sidescrolloff = 15
vim.opt.sidescroll = 1

-- persistent undofiles
vim.opt.undofile = true
vim.cmd [[
let s:undodir = "/tmp/.undodir_" . $USER
if !isdirectory(s:undodir)
    call mkdir(s:undodir, "", 0700)
endif
let &undodir=s:undodir
set undofile
]]

-- comments italic
vim.cmd [[ highlight Comment cterm=italic ]]
-- redefine italics terminal codes so this works well in tmux
vim.cmd [[
set t_ZH=
set t_ZR=
]]

-- Configure backspace so it acts as it should act
vim.cmd [[
set backspace=eol,start,indent
set whichwrap+=<,>,h,l
]]

-- update dir to current file
-- vim.cmd [[
-- autocmd BufEnter * silent! cd %:p:h
-- ]]

-- define Wrap command to set text soft wrapping
-- vim.cmd [[
-- command! -nargs=* Wrap set wrap linebreak nolist
-- ]]
--
-- easy expansion of the Active File Directory
-- vim.cmd [[
-- cnoremap <expr> %% getcmdtype() == ':' ? expand('%:h').'/' : '%%'
-- ]]
--
-- trigger autoread when changing buffers or coming back to vim in terminal
vim.cmd [[
au FocusGained,BufEnter * :silent! !
]]

-- Save whenever switching windows or leaving vim
-- This is useful when running
-- the tests inside vim without having to save all files first
vim.cmd [[
au FocusLost,WinLeave * :silent! wa
]]

-- automatically rebalance windows on vim resize
vim.cmd [[
autocmd VimResized * :wincmd =
]]

-- When editing a file, always jump to the last known cursor position.
-- Don't do it for commit messages, when the position is invalid, or when
-- inside an event handler (happens when dropping a file on gvim).
vim.cmd [[
augroup vimrcEx
  autocmd!

  autocmd BufReadPost * if &ft != 'gitcommit' && line("'\"") > 0 && line("'\"") <= line("$") |   exe "normal g`\"" | endif
augroup END

]]

-- Highlight when yanking
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})
-- Terminal
vim.api.nvim_create_autocmd('TermOpen', {
  group = vim.api.nvim_create_augroup('custom-term-open', { clear = true }),
  callback = function()
    vim.opt.number = false
    vim.opt.relativenumber = false
  end,
})
