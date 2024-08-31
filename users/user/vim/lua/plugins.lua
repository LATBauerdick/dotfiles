vim.cmd [[packadd packer.nvim]]

-- paq plugin manager https://github.com/savq/paq-nvim/
local fn = vim.fn
local install_path = fn.stdpath('data') .. '/site/pack/paqs/start/paq-nvim'
if fn.empty(fn.glob(install_path)) > 0 then
  fn.system({'git', 'clone', '--depth=1', 'https://github.com/savq/paq-nvim.git', install_path})
end

-- lots of my plugins, usint vim-plug
-- vim-plug {{{
    vim.cmd [[
let data_dir = has('nvim') ? stdpath('data') . '/site' : '~/.vim'
if empty(glob(data_dir . '/autoload/plug.vim'))
  silent execute '!curl -fLo '.data_dir.'/autoload/plug.vim --create-dirs  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif
call plug#begin(stdpath('data') . '/plugged')
]]
    local Plug = vim.fn['plug#']


    Plug 'altercation/vim-colors-solarized'
    Plug 'jiangmiao/auto-pairs'
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
Plug 'mhinz/vim-signify'
Plug 'int3/vim-extradite'
Plug 'scrooloose/nerdtree'
Plug 'majutsushi/tagbar'
Plug 'vim-scripts/Align'
Plug 'simnalamburt/vim-mundo'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-eunuch'
Plug 'godlygeek/tabular'
Plug 'michaeljsmith/vim-indent-object'
Plug 'easymotion/vim-easymotion'
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
    -- Plug 'aiya000/vim-ghcid-quickfix'
Plug 'raichoo/purescript-vim'
Plug 'rust-lang/rust.vim'
Plug 'ledger/vim-ledger'
Plug 'terryma/vim-smooth-scroll'
-- Plug 'sdothum/vim-colors-duochrome'
-- Plug 'altercation/vim-colors-solarized'
-- Plug 'frankier/neovim-colors-solarized-truecolor-only'
-- Plug 'lifepillar/vim-solarized8'
Plug 'rakr/vim-one'
Plug 'tpope/vim-vinegar'
Plug 'tpope/vim-fireplace'
Plug 'tpope/vim-unimpaired'
Plug 'tpope/vim-sexp-mappings-for-regular-people'
Plug 'guns/vim-sexp'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-surround'
Plug 'bling/vim-airline'
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

return require('packer').startup(function(use)
  -- Package manager
  use 'wbthomason/packer.nvim'

  use 'glepnir/dashboard-nvim'

  use 'hrsh7th/nvim-compe'

-- Useful status updates for LSP
  use {
    'j-hui/fidget.nvim',
    -- tag = 'legacy',
    config = function()
      require("fidget").setup {
        -- options
      }
    end,
  }

  use { -- LSP Configuration & Plugins
    'neovim/nvim-lspconfig',
    requires = {
      -- Automatically install LSPs to stdpath for neovim
      'williamboman/mason.nvim',
      'williamboman/mason-lspconfig.nvim',

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

  --  use 'lukas-reineke/indent-blankline.nvim' -- Add indentation guides even on blank lines
  use 'numToStr/Comment.nvim' -- "gc" to comment visual regions/lines
  use 'tpope/vim-sleuth' -- Detect tabstop and shiftwidth automatically

  use 'jvgrootveld/telescope-zoxide'
  use 'sudormrfbin/cheatsheet.nvim'
  use 'nvim-lua/popup.nvim'
    -- use 'nvim-lualine/lualine.nvim' -- Fancier statusline

    -- use 'altercation/vim-colors-solarized'
    -- use 'frankier/neovim-colors-solarized-truecolor-only'
    -- use 'sdothum/vim-colors-duochrome'

    -- use 'tpope/vim-commentary'
    -- use 'tpope/vim-eunuch'
    -- use 'tpope/vim-vinegar'
    -- use 'tpope/vim-fireplace'
    -- use 'tpope/vim-unimpaired'
    -- use 'tpope/vim-sexp-mappings-for-regular-people'
    -- use 'tpope/vim-repeat'
    -- use 'tpope/vim-surround'
    -- use 'tpope/vim-dispatch'

    -- use 'bling/vim-airline'
    -- use 'vim-airline/vim-airline-themes'

    -- use 'jgdavey/tslime.vim'
    -- use { 'Shougo/vimproc.vim', run = 'make', cond = vim.fn.executable 'make' == 1 }
    -- use 'scrooloose/nerdcommenter'
    -- use 'jiangmiao/auto-pairs'
    -- use 'benekastah/neomake'
    -- use 'moll/vim-bbye'
    -- use 'nathanaelkane/vim-indent-guides'
    -- use 'vim-scripts/gitignore'
    -- use 'mg979/vim-visual-multi'
    -- use 'junegunn/fzf.vim'
    -- use 'mhinz/vim-grepper'
    -- use 'mhinz/vim-signify'
    -- use 'int1/vim-extradite'
    -- use 'scrooloose/nerdtree'
    -- use 'majutsushi/tagbar'
    -- use 'vim-scripts/Align'
    -- use 'simnalamburt/vim-mundo'
    -- use 'godlygeek/tabular'
    -- use 'michaeljsmith/vim-indent-object'
    -- use 'easymotion/vim-easymotion'
    -- use 'christoomey/vim-tmux-navigator'
    -- use 'sbdchd/neoformat'
    -- use 'ujihisa/unite-haskellimport'
    -- use 'Shougo/unite.vim'
    -- use 'neovimhaskell/haskell-vim'
    -- use 'enomsg/vim-haskellConcealPlus'
    -- use 'Twinside/vim-hoogle'
    -- use 'aiya000/vim-ghcid-quickfix'
    -- use 'raichoo/purescript-vim'
    -- use 'rust-lang/rust.vim'
    -- use 'ledger/vim-ledger'
    -- use 'terryma/vim-smooth-scroll'
    -- use 'rakr/vim-one'
    -- use 'guns/vim-sexp'
    -- use 'mvandiemen/ghostbuster'
    -- use 'radenling/vim-dispatch-neovim'
    -- use 'knubie/vim-kitty-navigator'
    -- use 'akinsho/toggleterm.nvim'


   -- Fuzzy Finder (files, lsp, etc)
  use { 'nvim-telescope/telescope.nvim', branch = '0.1.x', requires = { 'nvim-lua/plenary.nvim' } }

  -- Fuzzy Finder Algorithm which requires local dependencies to be built. Only load if `make` is available
  use { 'nvim-telescope/telescope-fzf-native.nvim', run = 'make', cond = vim.fn.executable 'make' == 1 }

  use({
    "epwalsh/obsidian.nvim",
    tag = "*",  -- recommended, use latest release instead of latest commit
    requires = {
      -- Required.
      "nvim-lua/plenary.nvim",
    },
    config = function()
      require("obsidian").setup({
        workspaces = {
          {
            name = "personal",
            path = "~/Zettelkasten",
          },
          {
            name = "music",
            path = "~/Zettelkasten/_AlbumPlayed",
          },
        },
        follow_url_func = function(url)
          -- Open the URL in the default web browser.
          vim.fn.jobstart({"open", url})  -- Mac OS
        end,
        -- force ':ObsidianOpen' to bring the app to the foreground.
        open_app_foreground = true,
        ui = {
          enable = true,  -- set to false to disable all additional syntax features
          update_debounce = 200,  -- update delay after a text change (in milliseconds)
          -- Define how various check-boxes are displayed
          checkboxes = {
            -- NOTE: the 'char' value has to be a single character, and the highlight groups are defined below.
            [" "] = { char = "󰄱", hl_group = "ObsidianTodo" },
            ["x"] = { char = "", hl_group = "ObsidianDone" },
            [">"] = { char = "", hl_group = "ObsidianRightArrow" },
            ["~"] = { char = "󰰱", hl_group = "ObsidianTilde" },
            -- Replace the above with this if you don't have a patched font:
            -- [" "] = { char = "☐", hl_group = "ObsidianTodo" },
            -- ["x"] = { char = "✔", hl_group = "ObsidianDone" },

            -- You can also add more custom ones...
          },
          -- Use bullet marks for non-checkbox lists.
          bullets = { char = "•", hl_group = "ObsidianBullet" },
          external_link_icon = { char = "", hl_group = "ObsidianExtLinkIcon" },
          -- Replace the above with this if you don't have a patched font:
          -- external_link_icon = { char = "", hl_group = "ObsidianExtLinkIcon" },
          reference_text = { hl_group = "ObsidianRefText" },
          highlight_text = { hl_group = "ObsidianHighlightText" },
          tags = { hl_group = "ObsidianTag" },
          hl_groups = {
            -- The options are passed directly to `vim.api.nvim_set_hl()`. See `:help nvim_set_hl`.
            ObsidianTodo = { bold = true, fg = "#f78c6c" },
            ObsidianDone = { bold = true, fg = "#89ddff" },
            ObsidianRightArrow = { bold = true, fg = "#f78c6c" },
            ObsidianTilde = { bold = true, fg = "#ff5370" },
            ObsidianBullet = { bold = true, fg = "#89ddff" },
            ObsidianRefText = { underline = true, fg = "#c792ea" },
            ObsidianExtLinkIcon = { fg = "#c792ea" },
            ObsidianTag = { italic = true, fg = "#89ddff" },
            ObsidianHighlightText = { bg = "#75662e" },
          },
        },
      })
    end,
  })

  -- -- Add custom plugins to packer from ~/.config/nvim/lua/custom/plugins.lua
  -- local has_plugins, plugins = pcall(require, 'custom.plugins')
  -- if has_plugins then
  --   plugins(use)
  -- end

  end
)

