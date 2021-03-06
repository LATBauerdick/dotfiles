
" remap leader key early
let mapleader = ","
" Allow the normal use of "," by pressing it twice
noremap ,, ,
noremap \ ,
let maplocalleader = "\\"

lua require 'init'
nnoremap <leader>ff <cmd>Telescope find_files<cr>
nnoremap <leader>fg <cmd>Telescope live_grep<cr>
nnoremap <leader>fb <cmd>Telescope buffers<cr>
nnoremap <leader>fh <cmd>Telescope help_tas<cr>

" Type :so % to refresh .vimrc after making changes

set nocompatible
let $NVIM_TUI_ENABLE_TRUE_COLOR=1

" set system clipboard to be default
set clipboard=unnamedplus

autocmd FileType tex,latex,markdown setlocal spell spelllang=en_us

" enable spell checking
map <leader>s :setlocal spell! spelllang=en_us<cr>

" Set spellfile to location that is guaranteed to exist
set spellfile=$HOME/.vim-spell-en.utf-8.add

set wildmode=longest,list,full

" disable all LSP features in ALE, so ALE doesn't try to provide LSP features already provided by coc.nvim, such as auto-completion
let g:ale_disable_lsp = 1

set hidden

" vim-plug {{{

if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif
call plug#begin('~/.vim/bundle')

Plug 'jgdavey/tslime.vim'
Plug 'Shougo/vimproc.vim', { 'do': 'make' }
Plug 'scrooloose/nerdcommenter'
Plug 'jiangmiao/auto-pairs'
" Plug 'ervandew/supertab'
Plug 'benekastah/neomake'
Plug 'moll/vim-bbye'
Plug 'nathanaelkane/vim-indent-guides'
Plug 'vim-scripts/gitignore'

Plug 'mg979/vim-visual-multi', {'branch': 'master'}

"
" fzf fuzzy file search
"Plug '/usr/local/opt/fzf'
Plug 'junegunn/fzf.vim'
"    Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
"Plug 'BurntSushi/ripgrep
" support for neuron
" Plug 'fiatjaf/neuron.vim'
" Plug 'chiefnoah/neuron-v2.vim'
"  Plug 'alok/notational-fzf-vim'
"  let g:nv_search_paths = ['~/Notes', '~/writing']
"
" grepper
Plug 'mhinz/vim-grepper'
"
" Git
" Plug 'int3/vim-extradite'
Plug 'mhinz/vim-signify'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-rhubarb'
Plug 'junegunn/gv.vim'

" Bars, panels, and files
Plug 'scrooloose/nerdtree'
Plug 'bling/vim-airline'
" Plug 'itchyny/lightline.vim'
"" Plug 'ctrlpvim/ctrlp.vim'
Plug 'majutsushi/tagbar'

" Text manipulation
Plug 'vim-scripts/Align'
Plug 'simnalamburt/vim-mundo'
" Plug 'tpope/vim-commentary'
Plug 'tpope/vim-surround'
Plug 'godlygeek/tabular'
Plug 'michaeljsmith/vim-indent-object'
Plug 'easymotion/vim-easymotion'

" vim sugar for shell commands
Plug 'tpope/vim-eunuch'

" Allow pane movement to jump out of vim into tmux
Plug 'christoomey/vim-tmux-navigator'

Plug 'sbdchd/neoformat'

" Plug 'vim-syntastic/syntastic'
" Plug 'neoclide/coc.nvim', {'branch': 'release'}
" Plug 'dense-analysis/ale'
Plug 'neovim/nvim-lspconfig'

" Haskell

" Plug 'neovimhaskell/haskell-vim'

Plug 'enomsg/vim-haskellConcealPlus'
" for haskellConcealPlus disable double-stroke capitals (does not work on iPad)
let hscoptions="????????????????iBQZDC*"

Plug 'Twinside/vim-hoogle'

" PureScript
Plug 'raichoo/purescript-vim'
"""Plug 'frigoeu/psc-ide-vim'

" rust
Plug 'rust-lang/rust.vim'

Plug 'ledger/vim-ledger'

" Custom bundles
Plug 'terryma/vim-smooth-scroll'
Plug 'sdothum/vim-colors-duochrome'
Plug 'rakr/vim-one'
Plug 'tpope/vim-vinegar'
Plug 'tpope/vim-fireplace'
Plug 'tpope/vim-unimpaired'
Plug 'tpope/vim-sexp-mappings-for-regular-people'
Plug 'guns/vim-sexp'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-surround'
Plug 'vim-airline/vim-airline-themes'
Plug 'mvandiemen/ghostbuster'

Plug 'tpope/vim-dispatch'
Plug 'radenling/vim-dispatch-neovim'

call plug#end()

" }}}


" Use par for prettier line formatting
set formatprg=par
let $PARINIT = 'rTbgqR B=.,?_A_a Q=_s>|'

" Show trailing whitespace
set list
" But only interesting whitespace
if &listchars ==# 'eol:$'
  set listchars=tab:>\ ,trail:-,extends:>,precedes:<,nbsp:+
endif
" set listchars=tab:???\ ,eol:??


" Configure backspace so it acts as it should act
set backspace=eol,start,indent
set whichwrap+=<,>,h,l

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


" VSplit window
nnoremap <leader>2 :vsplit<CR>
nnoremap <leader>1 :only<CR>
" go to the other window
nnoremap <leader>w <C-w><C-w>
nnoremap <leader>o <C-w><C-w>

noremap <leader>l :ls<CR>:b 

" noremap ; :

" strip all trailing whitespace in the current file
nnoremap <leader>W :%s/\s\+$//<cr>:let @/=''<CR>

" Ack command
nnoremap <leader>a :Ack
let g:ackprg = 'ag --vimgrep'
nnoremap <leader>g :Grepper<cr>
let g:grepper = { 'next_tool': '<leader>g' }
nmap gs  <plug>(GrepperOperator)
xmap gs  <plug>(GrepperOperator)

" quickly edit .vimrc file
nnoremap <leader>ev <C-w><C-v><C-l>:e $MYVIMRC<cr>

let g:ghcid_command= "/usr/local/bin/ghcid"

" redefine italics terminal codes so this works well in tmux
set t_ZH=[3m
set t_ZR=[23m

" fixes glitch? in colors when using vim with tmux
if !has('gui_running')
" set t_Co=256
" set notermguicolors
  " set background=light
  " colorscheme solarized
  " let g:solarized_termcolors=16
" comments are italicized
" let g:solarized_termtrans=1
" let g:solarized_contrast="high"
  " highlight Comment cterm=italic

else
" set termguicolors
  set background=light
  colorscheme solarized
  " colorscheme duochrome
endif
"
" This is only necessary if you use "set termguicolors".
let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"

" vim lightline
set noshowmode
let g:lightline = {
      \ 'colorscheme': 'solarized light',
      \ 'active': {
      \   'left': [ [ 'mode', 'paste' ],
      \             [ 'readonly', 'filename', 'modified', 'helloworld' ] ]
      \ },
      \}

" -- vim-airline
let g:airline_theme='solarized'
" let g:airline_solarized_bg='dark'
let g:airline_solarized_bg='light'
let g:airline_powerline_fonts = 1
let g:airline#extensions#tabline#enabled = 2
let g:airline#extensions#tabline#fnamemod = ':t'

" easy expansion of the Active File Directory
cnoremap <expr> %% getcmdtype() == ':' ? expand('%:h').'/' : '%%'

set showcmd       " display incomplete command
set autowrite     " Automatically :write before running commands
set autoread      " Reload files changed outside vim
" Trigger autoread when changing buffers or coming back to vim in terminal.
au FocusGained,BufEnter * :silent! !

" close buffer without closing window
map <leader>q :bp<bar>sp<bar>bn<bar>bd<CR>

"Set default font in mac vim and gvim
" set guifont=Hack:h14
set linespace=4
set cursorline    " highlight the current line
" set cursorcolumn  " highlight the current column
" highlight CursorColumn ctermbg=Yellow cterm=bold guibg=#2b2b2b
set visualbell    " stop that ANNOYING beeping

" Allow usage of mouse in iTerm
set ttyfast
set mouse=a

set gdefault      " Never have to type /g at the end of search / replace again
set ignorecase    " case insensitive searching (unless specified)
set smartcase
set hlsearch
set incsearch
set showmatch
" Disable highlight when <leader><cr> is pressed
" but preserve cursor coloring
nmap <silent> <leader><cr> :noh\|hi Cursor guibg=red<cr>

" Don't redraw while executing macros (good performance config)
set lazyredraw

" Softtabs, 2 spaces
set tabstop=2
set shiftwidth=2
set shiftround
set expandtab

" Display extra whitespace
set list listchars=tab:????,trail:??,nbsp:??,extends:>,precedes:<
",tab:????,eol:??,space:???

" Make it obvious where 80 characters is
set textwidth=80
" set formatoptions=cq
set formatoptions=qrn1
set wrapmargin=0
set colorcolumn=+1
set linebreak

" define Wrap command to set text soft wrapping
command! -nargs=* Wrap set wrap linebreak nolist

" Numbers
set number
set numberwidth=5

" Open new split panes to right and bottom, which feels more natural
set splitbelow splitright

" Auto resize Vim splits to active split
" set winwidth=104
" set winheight=5
" set winminheight=5
" set winheight=999

" ================ Scrolling ========================

set scrolloff=8         "Start scrolling when we're 8 lines away from margins
set sidescrolloff=15
set sidescroll=1

"Toggle relative numbering, and set to absolute on loss of focus or insert mode
set rnu
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

" Use tab to jump between blocks, because it's easier
nnoremap <tab> %
vnoremap <tab> %

" Always use vertical diffs
" set diffopt+=vertical

" NERDtree
map <C-n> :NERDTreeToggle<CR>

" Fuzzy find files
nnoremap <silent> <Leader><space> :<C-u>FZF<CR>
set rtp+=/usr/local/opt/fzf

" HIE / LanguageClient-neovim setup
" Required for operations modifying multiple buffers like rename.
set hidden
let g:LanguageClient_serverCommands = {
    \ 'rust': ['~/.cargo/bin/rustup', 'run', 'stable', 'rls'],
    \ 'javascript': ['/usr/local/bin/javascript-typescript-stdio'],
    \ 'javascript.jsx': ['tcp://127.0.0.1:2089'],
    \ 'python': ['/usr/local/bin/pyls'],
    \ 'ruby': ['~/.rbenv/shims/solargraph', 'stdio'],
    \ }
"""set rtp+=~/.vim/bundle/LanguageClient-neovim

nnoremap <F5> :call LanguageClient_contextMenu()<CR>
map <Leader>lk :call LanguageClient#textDocument_hover()<CR>
map <Leader>lg :call LanguageClient#textDocument_definition()<CR>
map <Leader>lr :call LanguageClient#textDocument_rename()<CR>
map <Leader>lf :call LanguageClient#textDocument_formatting()<CR>
map <Leader>lb :call LanguageClient#textDocument_references()<CR>
map <Leader>la :call LanguageClient#textDocument_codeAction()<CR>
map <Leader>ls :call LanguageClient#textDocument_documentSymbol()<CR>


" delete buffer without closing pane
noremap <leader>bd :Bd<cr>


syntax on

" bind K to grep word under cursor
nnoremap K :grep! "\b<C-R><C-W>\b"<CR>:cw<CR>

" Ag will search from project root
let g:ag_working_path_mode="r"

" Quickly close windows
nnoremap <leader>x :x<cr>
nnoremap <leader>X :q!<cr>

" zoom a vim pane, <C-w>= to re-balance
nnoremap <leader>_ :wincmd _<cr>:wincmd \|<cr>
nnoremap <leader>= :wincmd =<cr>


" resize panes
" nnoremap <silent> <Right> :vertical resize +5<cr>
" nnoremap <silent> <Left> :vertical resize -5<cr>
" nnoremap <silent> <Up> :resize +5<cr>
" nnoremap <silent> <Down> :resize -5<cr>

" Switch between the last two files
nnoremap <leader><leader> <c-^>

" use kk as Esc
inoremap kk <esc>

" use cursor keys to move display lines
nmap <up> gk
nmap <down> gj
inoremap <Up> <C-o>gk
inoremap <Down> <C-o>gj
nnoremap <Up> gk
nnoremap <Down> gj
vnoremap <silent> <up> gk
vnoremap <silent> <down> gj

" remap for smooth scroll
noremap <silent> <c-u> :call smooth_scroll#up(&scroll, 0, 2)<CR>
noremap <silent> <c-d> :call smooth_scroll#down(&scroll, 0, 2)<CR>
noremap <silent> <c-b> :call smooth_scroll#up(&scroll*2, 0, 4)<CR>
noremap <silent> <c-f> :call smooth_scroll#down(&scroll*2, 0, 4)<CR>

" define move keys for Colemak
" noremap h k
" noremap j h
" noremap k j

" AUTOCOMMANDS - Do stuff

" Save whenever switching windows or leaving vim. This is useful when running
" the tests inside vim without having to save all files first.
au FocusLost,WinLeave * :silent! wa

" automatically rebalance windows on vim resize
autocmd VimResized * :wincmd =

"update dir to current file
autocmd BufEnter * silent! cd %:p:h

augroup vimrcEx
  autocmd!

  " When editing a file, always jump to the last known cursor position.
  " Don't do it for commit messages, when the position is invalid, or when
  " inside an event handler (happens when dropping a file on gvim).
  autocmd BufReadPost *
    \ if &ft != 'gitcommit' && line("'\"") > 0 && line("'\"") <= line("$") |
    \   exe "normal g`\"" |
    \ endif
augroup END

"augroup END

set foldmethod=marker

" persistent undofiles
set undofile
augroup vimrc
  autocmd!
  autocmd BufWritePre /tmp/* setlocal noundofile
augroup END

" func! g:CustomNeuronIDGenerator(title)
"      return a:title
" " substitute(a:title, " ", "-", "g")
" endf

" setup language server
source $HOME/.config/nvim/lsp-config.vim
" set completeopt=menuone,noselect
" luafile ~/.config/nvim/lua/compe-config.lua

" lua require 'python-lsp'
lua << EOF
require'lspconfig'.pyright.setup{}
EOF

luafile ~/.config/nvim/lua/haskell-lsp.lua

highlight Comment cterm=italic

