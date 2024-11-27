-- Type :luafile % to refresh init.lua after making changes

-- from https://github.com/nvim-lua/kickstart.nvim

-- Map leader key early
-- vim.g.mapleader = ','
-- vim.g.maplocalleader = '\\'
vim.g.mapleader = ' '
vim.g.maplocalleader = ','
-- vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

-- Install packer
local install_path = vim.fn.stdpath 'data' .. '/site/pack/packer/start/packer.nvim'
local is_bootstrap = false
if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
  is_bootstrap = true
  vim.fn.system { 'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path }
  vim.cmd [[packadd packer.nvim]]
end

require('plugins')

if is_bootstrap then
    require('packer').sync()
end

-- When we are bootstrapping a configuration, it doesn't
-- make sense to execute the rest of the init.lua.
--
-- You'll need to restart nvim, and then it will work.
if is_bootstrap then
  print '=================================='
  print '    Plugins are being installed'
  print '    Wait until Packer completes,'
  print '       then restart nvim'
  print '=================================='
  return
end


-- sensible defaults
require('settings')

-- [[ Highlight on yank ]]
-- See `:help vim.highlight.on_yank()`
-- local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
-- vim.api.nvim_create_autocmd('TextYankPost', {
--   callback = function()
--     vim.highlight.on_yank()
--   end,
--   group = highlight_group,
--   pattern = '*',
-- })

-- Set lualine as statusline
-- See `:help lualine.txt`
local custom_solarized = require'lualine.themes.solarized_light'
custom_solarized.normal.a.bg = '#b58900'
require('lualine').setup {
  options = {
    theme = 'custom_solarized',
    always_show_tabline = true,
  },
  tabline = {
    lualine_a = {'buffers'},
    lualine_b = {},
    lualine_c = {},
    lualine_x = {},
    lualine_y = {},
    lualine_z = {'tabs'}
  },
}


-- Enable Comment.nvim
require('Comment').setup()

-- Gitsigns
-- See `:help gitsigns.txt`
require('gitsigns').setup {
  signs = {
    add = { text = '+' },
    change = { text = '~' },
    delete = { text = '_' },
    topdelete = { text = '‾' },
    changedelete = { text = '~' },
  },
}

require('telescope-config')

require('treesitter-config')

require('compe-config')
-- require('cmp-config')

require('colors')

--setup function for oberblastmeister/neuron.nvim
-- these are all the default values
-- require'neuron'.setup {
--     virtual_titles = true,
--     mappings = true,
--     run = nil, -- function to run when in neuron dir
--     neuron_dir = "~/zk", -- the directory of all of your notes, expanded by default (currently supports only one directory for notes, find a way to detect neuron.dhall to use any directory)
--     leader = "gz", -- the leader key to for all mappings, remember with 'go zettel'
-- }

-- Diagnostic keymaps
-- See `:help vim.diagnostic.*` for documentation
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float)
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist)
-- Send diagnostics to quickfix list
-- do
--   local method = "textDocument/publishDiagnostics"
--   local default_handler = vim.lsp.handlers[method]
--   vim.lsp.handlers[method] = function(err, method, result, client_id, bufnr,
--                                       config)
--     default_handler(err, method, result, client_id, bufnr, config)
--     local diagnostics = vim.lsp.diagnostic.get_all()
--     local qflist = {}
--     for bufnr, diagnostic in pairs(diagnostics) do
--       for _, d in ipairs(diagnostic) do
--         d.bufnr = bufnr
--         d.lnum = d.range.start.line + 1
--         d.col = d.range.start.character + 1
--         d.text = d.message
--         table.insert(qflist, d)
--       end
--     end
--     vim.lsp.util.set_qflist(qflist)
--   end
-- end


--language server protocol
require('lsp-config')

-- Key mappings
require('keymappings')

-- require('toggleterm')

-- vim.cmd 'source ~/.config/nvim/oldinit.vim'
vim.cmd [[


let $NVIM_TUI_ENABLE_TRUE_COLOR=1

" Use par for prettier line formatting
set formatprg=par
let $PARINIT = 'rTbgqR B=.,?_A_a Q=_s>|'


"-----------syntastic---------------------------
" syntastic beginners settings
set statusline+=%#warningmsg#
" set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 0
let g:syntastic_check_on_wq = 1
let g:syntastic_enable_elixir_checker = 1
let g:syntastic_elixir_checkers = "elixir"

"--------------------Ack command------------
nnoremap <leader>a :Ack
let g:ackprg = 'ag --vimgrep'
nnoremap <leader>g :Grepper<cr>
let g:grepper = { 'next_tool': '<leader>g' }
nmap gs  <plug>(GrepperOperator)
xmap gs  <plug>(GrepperOperator)

" --------------------ghcid command
let g:ghcid_command= "/usr/local/bin/ghcid"


"------------- vim-airline----------------------
let g:airline_theme='solarized'
" let g:airline_solarized_bg='dark'
let g:airline_solarized_bg='light'
let g:airline_powerline_fonts = 1
let g:airline#extensions#tabline#enabled = 2
let g:airline#extensions#tabline#fnamemod = ':t'

" easy expansion of the Active File Directory
cnoremap <expr> %% getcmdtype() == ':' ? expand('%:h').'/' : '%%'

" Trigger autoread when changing buffers or coming back to vim in terminal.
au FocusGained,BufEnter * :silent! !

"Set default font in mac vim and gvim
" set guifont=Hack:h14

" Display extra whitespace
set list listchars=tab:»·,trail:·,nbsp:·,extends:>,precedes:<
",tab:»·,eol:¬,space:␣

" highlight non-ascii
syntax match nonascii "[^\x00-\x7F]"
highlight nonascii guibg=Red ctermbg=2

" define Wrap command to set text soft wrapping
command! -nargs=* Wrap set wrap linebreak nolist

" Always use vertical diffs
" set diffopt+=vertical

" NERDtree
map <C-n> :NERDTreeToggle<CR>

" Fuzzy find files
nnoremap <silent> <Leader><space> :<C-u>FZF<CR>
set rtp+=/usr/local/opt/fzf


" Ag will search from project root
let g:ag_working_path_mode="r"

" AUTOCOMMANDS - Do stuff

" Save whenever switching windows or leaving vim. This is useful when running
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

"augroup END

set foldmethod=marker

" persistent undofiles
" let s:undodir = "/tmp/.undodir_" . $USER
" if !isdirectory(s:undodir)
"     call mkdir(s:undodir, "", 0700)
" endif
" let &undodir=s:undodir
" set undofile

" augroup vimrc
"   autocmd!
"   autocmd BufWritePre /tmp/* setlocal noundofile
" augroup END

" func! g:CustomNeuronIDGenerator(title)
"      return a:title
" " substitute(a:title, " ", "-", "g")
" endf
]]

