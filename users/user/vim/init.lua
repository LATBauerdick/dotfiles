
-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
-- This is also a good place to setup other settings (vim.opt)
vim.g.mapleader = " "
vim.g.maplocalleader = ','
--vim.g.maplocalleader = "\\"

require("config.settings")

require("config.lazy")

-- vim.cmd 'syntax enable'

require("config.keymappings")

local x="init done!"
print (x)

vim.cmd [[

"" define Wrap command to set text soft wrapping
"command! -nargs=* Wrap set wrap linebreak nolist

" easy expansion of the Active File Directory
"cnoremap <expr> %% getcmdtype() == ':' ? expand('%:h').'/' : '%%'

" Trigger autoread when changing buffers or coming back to vim in terminal.
au FocusGained,BufEnter * :silent! !

" Save whenever switching windows or leaving vim.
" "This is useful when running
" the tests inside vim without having to save all files first.
au FocusLost,WinLeave * :silent! wa

" automatically rebalance windows on vim resize
autocmd VimResized * :wincmd =

augroup vimrcEx
  autocmd!

  " When editing a file, always jump to the last known cursor position.
  " Don't do it for commit messages, when the position is invalid, or when
  " inside an event handler (happens when dropping a file on gvim).
  autocmd BufReadPost * if &ft != 'gitcommit' && line("'\"") > 0 && line("'\"") <= line("$") |   exe "normal g`\"" | endif
augroup END

]]


-- Highlight when yanking
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function ()
    vim.highlight.on_yank()
  end,
})
