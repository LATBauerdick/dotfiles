vim.cmd [[packadd packer.nvim]]

-- paq plugin manager https://github.com/savq/paq-nvim/
local fn = vim.fn
local install_path = fn.stdpath('data') .. '/site/pack/paqs/start/paq-nvim'
if fn.empty(fn.glob(install_path)) > 0 then
  fn.system({'git', 'clone', '--depth=1', 'https://github.com/savq/paq-nvim.git', install_path})
end

-- vim-plug {{{
-- alternative vim-plug version
vim.cmd [[
let data_dir = has('nvim') ? stdpath('data') . '/site' : '~/.vim'
if empty(glob(data_dir . '/autoload/plug.vim'))
  silent execute '!curl -fLo '.data_dir.'/autoload/plug.vim --create-dirs  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif
call plug#begin(stdpath('data') . '/plugged')
]]
local Plug = vim.fn['plug#']
-- vim.call('plug#begin', stdpath('data') . '/plugged')
--  Plug 'tpope/vim-dispatch'
--  Plug ('mg979/vim-visual-multi', {branch = 'master'})
Plug 'jgdavey/tslime.vim'
Plug ('Shougo/vimproc.vim', { ['do'] = vim.fn['make']})
Plug 'scrooloose/nerdcommenter'
Plug 'jiangmiao/auto-pairs'
Plug 'benekastah/neomake'
Plug 'moll/vim-bbye'
Plug 'nathanaelkane/vim-indent-guides'
Plug 'vim-scripts/gitignore'
Plug ('mg979/vim-visual-multi', {branch = 'master'})
Plug 'junegunn/fzf.vim'
Plug 'mhinz/vim-grepper'
Plug 'tpope/vim-fugitive'
Plug 'int3/vim-extradite'
Plug 'scrooloose/nerdtree'
Plug 'bling/vim-airline'
Plug 'majutsushi/tagbar'
Plug 'vim-scripts/Align'
Plug 'simnalamburt/vim-mundo'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-surround'
Plug 'godlygeek/tabular'
Plug 'michaeljsmith/vim-indent-object'
Plug 'easymotion/vim-easymotion'
Plug 'tpope/vim-eunuch'
Plug 'christoomey/vim-tmux-navigator'
Plug 'sbdchd/neoformat'
-- Plug 'vim-syntastic/syntastic'
-- Plug ('neoclide/coc.nvim', {branch = 'release'})
-- Plug 'dense-analysis/ale'
Plug 'ujihisa/unite-haskellimport'
Plug 'Shougo/unite.vim'
-- Plug ('Shougo/deoplete.nvim', { do = ':UpdateRemotePlugins' })
Plug 'neovimhaskell/haskell-vim'
Plug 'enomsg/vim-haskellConcealPlus'
Plug 'Twinside/vim-hoogle'
Plug 'raichoo/purescript-vim'
Plug 'rust-lang/rust.vim'
Plug 'ledger/vim-ledger'
Plug 'terryma/vim-smooth-scroll'
Plug 'sdothum/vim-colors-duochrome'
Plug 'altercation/vim-colors-solarized'
Plug 'frankier/neovim-colors-solarized-truecolor-only'
Plug 'lifepillar/vim-solarized8'
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
Plug 'knubie/vim-kitty-navigator'
Plug 'akinsho/toggleterm.nvim' --, tag = 'v1.*'


vim.call('plug#end')
-- }}}

vim.cmd [[
let hscoptions="𝐌𝐄𝐓𝐒iBQZDC*"
]]


return require('packer').startup(
  function()
    use 'hrsh7th/nvim-compe'
    use 'wbthomason/packer.nvim'
-- telescope
    use {
        'nvim-telescope/telescope.nvim',
      requires = {{'nvim-lua/popup.nvim'}, {'nvim-lua/plenary.nvim'}}
    }
    use 'jvgrootveld/telescope-zoxide'
    use 'sudormrfbin/cheatsheet.nvim'
    -- use 'oberblastmeister/neuron.nvim'
    use 'nvim-lua/popup.nvim'

    use 'nvim-treesitter/nvim-treesitter' --  We recommend updating the parsers on update
    use 'neovim/nvim-lspconfig'
  end
)


