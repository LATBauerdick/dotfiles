vim.cmd [[packadd packer.nvim]]

-- paq plugin manager https://github.com/savq/paq-nvim/
local fn = vim.fn
local install_path = fn.stdpath('data') .. '/site/pack/paqs/start/paq-nvim'
if fn.empty(fn.glob(install_path)) > 0 then
  fn.system({'git', 'clone', '--depth=1', 'https://github.com/savq/paq-nvim.git', install_path})
end

--require "paq" {
--    "savq/paq-nvim";                  -- Let Paq manage itself
---- paq-nvim {{{
--    -- {"lervag/vimtex", opt=true};      -- Use braces when passing options
--    'jgdavey/tslime.vim';
--    {'Shougo/vimproc.vim', ['do'] = 'make'};
--    'wellle/targets.vim';
--    'scrooloose/nerdcommenter';
--    'jiangmiao/auto-pairs';
---- Plug 'ervandew/supertab'
--    'benekastah/neomake';
--    'moll/vim-bbye';
--    'nathanaelkane/vim-indent-guides';
--    'vim-scripts/gitignore';

--    { 'mg979/vim-visual-multi', branch = 'master' };
----
---- fzf fuzzy file search
----  Plug '/usr/local/opt/fzf'
--    'junegunn/fzf.vim';
----    Plug ('junegunn/fzf', { ['do'] = '{ -> fzf#install() }' })
----Plug 'BurntSushi/ripgrep
---- support for neuron
---- Plug 'fiatjaf/neuron.vim'
---- Plug 'chiefnoah/neuron-v2.vim'
----  Plug 'alok/notational-fzf-vim'
----  let g:nv_search_paths = ['~/Notes', '~/writing']
----
---- grepper
--    'mhinz/vim-grepper';
----
---- Git
---- Plug 'int3/vim-extradite'
--    'mhinz/vim-signify';
--    'tpope/vim-fugitive';
--    'tpope/vim-rhubarb';
--    'junegunn/gv.vim';

---- Bars, panels, and files
--    'scrooloose/nerdtree';
--    'bling/vim-airline';
---- Plug 'itchyny/lightline.vim'
---- Plug 'ctrlpvim/ctrlp.vim'
--    'majutsushi/tagbar';

---- Text manipulation
--    'vim-scripts/Align';
--    'simnalamburt/vim-mundo';
--    'tpope/vim-commentary';
--    'tpope/vim-surround';
--    'godlygeek/tabular';
--    'michaeljsmith/vim-indent-object';
--    'easymotion/vim-easymotion';

---- vim sugar for shell commands
--    'tpope/vim-eunuch';

---- Allow pane movement to jump out of vim into tmux
--    'christoomey/vim-tmux-navigator';

--    'sbdchd/neoformat';

---- Plug 'vim-syntastic/syntastic'
---- Plug 'neoclide/coc.nvim', {'branch': 'release'}
---- Plug 'dense-analysis/ale'
--    'neovim/nvim-lspconfig';

---- Haskell

--    {'ndmitchell/ghcid', ['rtp'] = 'plugins/nvim' };
----  'neovimhaskell/haskell-vim';

--    'enomsg/vim-haskellConcealPlus';
---- for haskellConcealPlus disable double-stroke capitals (does not work on iPad)

--    'Twinside/vim-hoogle';

---- PureScript
--    'raichoo/purescript-vim';
----Plug 'frigoeu/psc-ide-vim'

---- rust
--    'rust-lang/rust.vim';
---- ledger
--    'ledger/vim-ledger';

---- Custom bundles
--    'terryma/vim-smooth-scroll';
--    'sdothum/vim-colors-duochrome';
--    'rakr/vim-one';
--    'tpope/vim-vinegar';
--    'tpope/vim-fireplace';
--    'tpope/vim-unimpaired';
--    'tpope/vim-sexp-mappings-for-regular-people';
--    'guns/vim-sexp';
--    'tpope/vim-repeat';
--    'tpope/vim-surround';
--    'vim-airline/vim-airline-themes';
--    'mvandiemen/ghostbuster';

--    'tpope/vim-dispatch';
--    'radenling/vim-dispatch-neovim';

--    'altercation/vim-colors-solarized';
--    'shaunsingh/nord.nvim';
--    'nanotee/zoxide.vim';
---- }}}
--}

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


