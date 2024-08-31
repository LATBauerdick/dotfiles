
local utils = require('utils')

local map = function(key)
  -- get the extra options
  local opts = {noremap = true}
  for i, v in pairs(key) do
    if type(i) == 'string' then opts[i] = v end
  end

  -- basic support for buffer-scoped keybindings
  local buffer = opts.buffer
  opts.buffer = nil

  if buffer then
    vim.api.nvim_buf_set_keymap(0, key[1], key[2], key[3], opts)
  else
    vim.api.nvim_set_keymap(key[1], key[2], key[3], opts)
  end
end

-- map { '', ';', ':' }

-- enable spell checking
map { '', '<Leader>s', ':setlocal spell! spelllang=en_us<cr>', noremap = false }

-- VSplit window
map { 'n', '<Leader>2', ':vsplit<CR>' }
map { 'n', '<Leader>1', ':only<CR>' }
-- go to the other window
map { 'n', '<Leader>w', '<C-w><C-w>' }
map { 'n', '<Leader>o', '<C-w><C-w>' }

map { '', '<Leader>l', ':ls<CR>:b ' }

-- close buffer without closing window
map { '', '<Leader>q', ':bp<bar>sp<bar>bn<bar>bd<CR>', noremap = false }

-- delete buffer without closing pane
map { 'n', '<Leader>bd', ':Bd<cr>' }

-- bind K to grep word under cursor
-- map { 'n', 'K', ':grep! "\b<C-R><C-W>\b"<CR>:cw<CR>' }


-- strip all trailing whitespace in the current file
map { 'n', '<Leader>W', [[:%s/\s\+$//<cr>:let @/=''<CR>]] }

-- quickly edit .vimrc file
map { 'n', '<Leader>ev', '<C-w><C-v><C-l>:e $MYVIMRC<cr>' }

-- Disable highlight when <leader><cr> is pressed
-- but preserve cursor coloring
-- nmap <silent> <leader><cr> :noh\|hi Cursor guibg=red<cr>
map { 'n', '<leader><cr>', ':noh|hi Cursor guibg=red<cr>', silent = true }

-- + and - keys to increment and decrement
map { 'n', '+', '<c-a>' }
map { 'n', '-', '<c-x>' }

-- keep search results at the center of the screen
map { 'n', 'n', 'nzz' }
map { 'n', 'N', 'Nzz' }
map { 'n', '*', '*zz' }
map { 'n', '#', '#zz' }
map { 'n', 'g*', 'g*zz' }
map { 'n', 'g#', 'g#zz' }

-- keep moves centered, too
map { 'n', '{', '{zz' }
map { 'n', '}', '}zz' }
map { 'n', ']c', ']czz' }
map { 'n', '[c', '[czz' }
map { 'n', ']j', '<c-o>zz' }
map { 'n', '[j', '<c-i>zz' }
map { 'n', ']s', ']szz' }
map { 'n', '[s', '[szz' }

-- all change operations are directed to the black hole register.
map { 'n', 'c', '"_c' }
map { 'n', 'C', '"_C' }

-- copy/clone paragraph
map { 'n', 'cp', 'yap<S-}>p' }

-- Quickly close windows
map { 'n', '<leader>x', ':x<cr>' }
map { 'n', '<leader>X', ':q!<cr>' }

-- paste from the system clipboard when in insert mode.
-- map { 'i', '<C-v>', '<C-r>*' }

-- zoom a vim pane, <C-w>= to re-balance
-- nnoremap <leader>_ :wincmd _<cr>:wincmd \|<cr>
-- nnoremap <leader>= :wincmd =<cr>
map { 'n', '<leader>z',   ':wincmd _<cr>:wincmd |<cr>' }
map { 'n', '<leader>=',   ':wincmd =<cr>' }

-- use cursor keys to move display lines
-- nmap <up> gk
-- nmap <down> gj
map { 'n', '<up>',   'gk' }
map { 'n', '<down>', 'gj' }
-- inoremap <Up> <C-o>gk
-- inoremap <Down> <C-o>gj
map { 'i', '<up>',   '<C-o>gk' }
map { 'i', '<down>', '<C-o>gj' }
-- vnoremap <silent> <up> gk
-- vnoremap <silent> <down> gj
map { 'v', '<up>',   'gk', silent = true }
map { 'v', '<down>', 'gj', silent = true }

-- easier go to start and end of line
map { 'n', 'B', '^' }
map { 'n', 'E', '$' }

-- select all text in buffer
map { 'n', 'vA', 'ggVG' }

-- yank to end of line
map { 'n', 'Y', 'y$' }

-- remap for smooth scroll
map { 'n', '<c-u>', ':call smooth_scroll#up(&scroll, 0, 2)<CR>', silent = true }
map { 'n', '<c-d>', ':call smooth_scroll#down(&scroll, 0, 2)<CR>', silent = true }
map { 'n', '<c-b>', ':call smooth_scroll#up(&scroll*2, 0, 4)<CR>', silent = true }
map { 'n', '<c-f>', ':call smooth_scroll#down(&scroll*2, 0, 4)<CR>', silent = true }

-- nnoremap <buffer> <CR> <cmd>lua require'neuron'.enter_link()<CR>
map { 'n', 'gzo', ":lua require'neuron'.enter_link()<CR>", buffer = true }


-- Switch between the last two files
-- nnoremap <leader><leader> <c-^>
map { 'n', '<leader><leader>',   'c-^' }

-- a smart <Tab> Key
-- When the autocomplete menu is visible navigate throught the list of results,
-- otherwise act like a regular <Tab>
local t = function(str)
  return vim.api.nvim_replace_termcodes(str, true, true, true)
end

_G.smart_tab = function()
  if vim.fn.pumvisible() == 1 then
    return t'<C-n>'
  else
    return t'<Tab>'
  end
end

vim.api.nvim_set_keymap ( 'i', '<Tab>', 'v:lua.smart_tab()'
                        , {noremap = true, expr = true}
                        )

utils.map('n', '<C-l>', '<cmd>noh<CR>') -- Clear highlights
-- inoremap kk <esc>
-- utils.map('i', 'kk', '<Esc>')           -- kk to escape

