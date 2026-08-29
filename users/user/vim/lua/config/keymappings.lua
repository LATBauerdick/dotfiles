-- Keymaps.
--
-- Neovim's built-in LSP maps are NOT repeated here:
--   K    hover (created buffer-locally on LspAttach)
--   gO   document symbol
--   grn  rename      gra  code action
--   grr  references  gri  implementation
--
-- The gr* set only exists because mini.operators was moved to uppercase
-- prefixes in plugins/mini.lua. While it claimed `gr`, mini *deleted* those
-- four defaults outright. If its prefixes ever move back to lowercase, these
-- must be re-added here by hand.

local set = vim.keymap.set

-- leave terminal mode
set('t', '<Esc>', [[<C-\><C-n>]])

-- toggle spell checking
set('', '<Leader>s', ':setlocal spell! spelllang=en_us<cr>')

-- execute lua
set('n', '<leader><leader>x', '<cmd>source %<CR>')
set('n', '<leader>x', ':.lua<CR>')
set('v', '<leader>x', ':lua<CR>')

-- LSP
set('n', '<leader>f', function() vim.lsp.buf.format() end)
set('n', 'gd', vim.lsp.buf.definition)
set('n', 'gD', vim.lsp.buf.declaration)
set('i', '<C-s>', vim.lsp.buf.signature_help)
-- NB: `gi` is left as the built-in "insert at last insert position".

-- diagnostics
set('n', '<leader>e', vim.diagnostic.open_float)
set('n', '<leader>ql', vim.diagnostic.setloclist)
set('n', '<leader>qq', vim.diagnostic.setqflist)

-- windows
set('n', '<Leader>2', ':vsplit<CR>')
set('n', '<Leader>1', ':only<CR>')
set('n', '<Leader>w', '<C-w><C-w>')
set('n', '<Leader>o', '<C-w><C-w>')
-- zoom a pane, <leader>= to re-balance
set('n', '<leader>z', ':wincmd _<cr>:wincmd |<cr>')
set('n', '<leader>=', ':wincmd =<cr>')

-- buffers
set('', '<Leader>l', ':ls<CR>:b ')

-- strip all trailing whitespace in the current file
set('n', '<Leader>W', [[:%s/\s\+$//<cr>:let @/=''<CR>]])

-- clear search highlight, but preserve cursor colouring
set('n', '<leader><cr>', ':noh|hi Cursor guibg=red<cr>', { silent = true })

-- + and - to increment and decrement
set('n', '+', '<c-a>')
set('n', '-', '<c-x>')

-- keep search results and jumps centred
for _, k in ipairs { 'n', 'N', '*', '#', 'g*', 'g#', '{', '}', ']s', '[s' } do
  set('n', k, k .. 'zz')
end
set('n', ']j', '<c-o>zz')
set('n', '[j', '<c-i>zz')

-- all change operations go to the black hole register
set('n', 'c', '"_c')
set('n', 'C', '"_C')

-- clone paragraph
set('n', 'cp', 'yap<S-}>p')

-- cursor keys move by display line
set('n', '<up>', 'gk')
set('n', '<down>', 'gj')
set('i', '<up>', '<C-o>gk')
set('i', '<down>', '<C-o>gj')
set('v', '<up>', 'gk', { silent = true })
set('v', '<down>', 'gj', { silent = true })

-- easier start/end of line
set('n', 'B', '^')
set('n', 'E', '$')

-- select whole buffer
set('n', 'vA', 'ggVG')
