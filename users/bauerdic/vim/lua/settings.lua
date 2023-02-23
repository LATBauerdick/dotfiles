
local indent = 2

vim.cmd 'syntax enable'

vim.opt.compatible = false

-- Set spellfile to location that is guaranteed to exist
vim.opt.spellfile = '~/.vim-spell-en.utf-8.add'

-- make sure spelling is on for markdown etc
vim.cmd [[autocmd FileType tex,latex,markdown setlocal spell spelllang=en_us]]

vim.opt.wildmode = {'longest','list','full'}

-- Don't redraw while executing macros (good performance config)
vim.opt.lazyredraw = true

-- Softtabs, 2 spaces
vim.opt.tabstop = indent
vim.opt.shiftwidth = indent
vim.opt.softtabstop = indent
vim.opt.expandtab = true
vim.opt.shiftround = true


-- Show trailing whitespace
vim.opt.list = true
-- But only interesting whitespace
vim.cmd [[
if &listchars ==# 'eol:$'
  set listchars=tab:>\ ,trail:-,extends:>,precedes:<,nbsp:+
endif
]]
-- set listchars=tab:▸\ ,eol:¬

vim.opt.hidden = true

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
vim.opt.scrolloff=8
vim.opt.sidescrolloff=15
vim.opt.sidescroll=1

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
set t_ZH=[3m
set t_ZR=[23m
]]

-- Configure backspace so it acts as it should act
vim.cmd [[
set backspace=eol,start,indent
set whichwrap+=<,>,h,l
]]

-- update dir to current file
vim.cmd [[
autocmd BufEnter * silent! cd %:p:h
]]

