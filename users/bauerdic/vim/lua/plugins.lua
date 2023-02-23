vim.cmd [[packadd packer.nvim]]

-- paq plugin manager https://github.com/savq/paq-nvim/
local fn = vim.fn
local install_path = fn.stdpath('data') .. '/site/pack/paqs/start/paq-nvim'
if fn.empty(fn.glob(install_path)) > 0 then
  fn.system({'git', 'clone', '--depth=1', 'https://github.com/savq/paq-nvim.git', install_path})
end

-- vim-plug {{{
-- }}}

vim.cmd [[
let hscoptions="𝐌𝐄𝐓𝐒iBQZDC*"
]]

return require('packer').startup(
  function(use)
  -- Package manager
    use 'hrsh7th/nvim-compe'

    use 'wbthomason/packer.nvim'

    use { -- LSP Configuration & Plugins
      'neovim/nvim-lspconfig',
      requires = {
        -- Automatically install LSPs to stdpath for neovim
        'williamboman/mason.nvim',
        'williamboman/mason-lspconfig.nvim',

        -- Useful status updates for LSP
        'j-hui/fidget.nvim',

        -- Additional lua configuration, makes nvim stuff amazing
        'folke/neodev.nvim',
      },
    }

    use { -- Autocompletion
      'hrsh7th/nvim-cmp',
      requires = { 'hrsh7th/cmp-nvim-lsp', 'L3MON4D3/LuaSnip', 'saadparwaiz1/cmp_luasnip' },
    }

    use { -- Highlight, edit, and navigate code
      'nvim-treesitter/nvim-treesitter',
      run = function()
        pcall(require('nvim-treesitter.install').update { with_sync = true })
      end,
    }

    use { -- Additional text objects via treesitter
      'nvim-treesitter/nvim-treesitter-textobjects',
      after = 'nvim-treesitter',
    }

    -- Git related plugins
    use 'tpope/vim-fugitive'
    use 'tpope/vim-rhubarb'
    use 'lewis6991/gitsigns.nvim'

    -- use 'navarasu/onedark.nvim' -- Theme inspired by Atom
    use 'altercation/vim-colors-solarized'
    -- use 'frankier/neovim-colors-solarized-truecolor-only'
    -- use 'sdothum/vim-colors-duochrome'
    -- use 'nvim-lualine/lualine.nvim' -- Fancier statusline
    use 'lukas-reineke/indent-blankline.nvim' -- Add indentation guides even on blank lines
    use 'numToStr/Comment.nvim' -- "gc" to comment visual regions/lines
    use 'tpope/vim-sleuth' -- Detect tabstop and shiftwidth automatically

    use 'tpope/vim-commentary'
    use 'tpope/vim-eunuch'
    use 'tpope/vim-vinegar'
    use 'tpope/vim-fireplace'
    use 'tpope/vim-unimpaired'
    use 'tpope/vim-sexp-mappings-for-regular-people'
    use 'tpope/vim-repeat'
    use 'tpope/vim-surround'
    use 'tpope/vim-dispatch'

    use 'bling/vim-airline'
    use 'vim-airline/vim-airline-themes'

    use 'jgdavey/tslime.vim'
    use { 'Shougo/vimproc.vim', run = 'make', cond = vim.fn.executable 'make' == 1 }
    use 'scrooloose/nerdcommenter'
    use 'jiangmiao/auto-pairs'
    use 'benekastah/neomake'
    use 'moll/vim-bbye'
    use 'nathanaelkane/vim-indent-guides'
    use 'vim-scripts/gitignore'
    use 'mg979/vim-visual-multi'
    use 'junegunn/fzf.vim'
    use 'mhinz/vim-grepper'
    use 'mhinz/vim-signify'
    use 'int3/vim-extradite'
    use 'scrooloose/nerdtree'
    use 'majutsushi/tagbar'
    use 'vim-scripts/Align'
    use 'simnalamburt/vim-mundo'
    use 'godlygeek/tabular'
    use 'michaeljsmith/vim-indent-object'
    use 'easymotion/vim-easymotion'
    use 'christoomey/vim-tmux-navigator'
    use 'sbdchd/neoformat'
    use 'ujihisa/unite-haskellimport'
    use 'Shougo/unite.vim'
    use 'neovimhaskell/haskell-vim'
    use 'enomsg/vim-haskellConcealPlus'
    use 'Twinside/vim-hoogle'
    use 'raichoo/purescript-vim'
    use 'rust-lang/rust.vim'
    use 'ledger/vim-ledger'
    use 'terryma/vim-smooth-scroll'
    use 'rakr/vim-one'
    use 'guns/vim-sexp'
    use 'mvandiemen/ghostbuster'
    use 'radenling/vim-dispatch-neovim'
    use 'knubie/vim-kitty-navigator'
    use 'akinsho/toggleterm.nvim'

    use 'jvgrootveld/telescope-zoxide'
    use 'sudormrfbin/cheatsheet.nvim'
    use 'nvim-lua/popup.nvim'

    -- Fuzzy Finder (files, lsp, etc)
    use { 'nvim-telescope/telescope.nvim', branch = '0.1.x', requires = { 'nvim-lua/plenary.nvim' } }

    -- Fuzzy Finder Algorithm which requires local dependencies to be built. Only load if `make` is available
    use { 'nvim-telescope/telescope-fzf-native.nvim', run = 'make', cond = vim.fn.executable 'make' == 1 }

    -- -- Add custom plugins to packer from ~/.config/nvim/lua/custom/plugins.lua
    -- local has_plugins, plugins = pcall(require, 'custom.plugins')
    -- if has_plugins then
    --   plugins(use)
    -- end

  end
)

