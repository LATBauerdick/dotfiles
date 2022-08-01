-- Type :luafile % to refresh init.lua after making changes

-- Map leader key early
vim.g.mapleader = ','
-- noremap ,, ,
-- noremap \ ,
vim.g.maplocalleader = '\\'

local fn = vim.fn
local execute = vim.api.nvim_command

-- sensible defaults
require('settings')

-- make sure packer.nvim is installed
local execute = vim.api.nvim_command
local fn = vim.fn
local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'

if fn.empty(fn.glob(install_path)) > 0 then
  fn.system({'git', 'clone', 'https://github.com/wbthomason/packer.nvim', install_path})
  execute 'packadd packer.nvim'
end

require('plugins')

require('compe-config')

require('telescope').setup{
  defaults = {
    vimgrep_arguments = {
      'rg',
      '--color=never',
      '--no-heading',
      '--with-filename',
      '--line-number',
      '--column',
      '--smart-case'
    },
    prompt_prefix = "> ",
    selection_caret = "> ",
    entry_prefix = "  ",
    initial_mode = "insert",
    selection_strategy = "reset",
    sorting_strategy = "descending",
    layout_strategy = "horizontal",
    layout_config = {
      horizontal = {
        mirror = false,
      },
      vertical = {
        mirror = false,
      },
    },
    file_sorter =  require'telescope.sorters'.get_fuzzy_file,
    file_ignore_patterns = {},
    generic_sorter =  require'telescope.sorters'.get_generic_fuzzy_sorter,
    winblend = 0,
    border = {},
    borderchars = { '─', '│', '─', '│', '╭', '╮', '╯', '╰' },
    color_devicons = true,
    use_less = true,
    path_display = {},
    set_env = { ['COLORTERM'] = 'truecolor' }, -- default = nil,
    file_previewer = require'telescope.previewers'.vim_buffer_cat.new,
    grep_previewer = require'telescope.previewers'.vim_buffer_vimgrep.new,
    qflist_previewer = require'telescope.previewers'.vim_buffer_qflist.new,

    -- Developer configurations: Not meant for general override
    buffer_previewer_maker = require'telescope.previewers'.buffer_previewer_maker
  }
}

require'telescope'.load_extension('zoxide')
vim.api.nvim_set_keymap(
  "n",
  "<leader>cd",
  ":lua require'telescope'.extensions.zoxide.list{}<CR>",
  {noremap = true, silent = true}
)

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

require'nvim-treesitter.configs'.setup {
  -- A list of parser names, or "all"
  ensure_installed = { "c", "lua", "rust", "haskell" }, -- one of "all" or a list of languages

  -- Install parsers synchronously (only applied to `ensure_installed`)
  sync_install = false,

  -- Automatically install missing parsers when entering buffer
  auto_install = true,

  -- List of parsers to ignore installing (for "all")
  ignore_install = { "javascript" },

  highlight = {
    -- `false` will disable the whole extension
    enable = false,
    disable = { "c", "rust" },
    additional_vim_regex_highlighting = false,
  },
}

-- Send diagnostics to quickfix list
do
  local method = "textDocument/publishDiagnostics"
  local default_handler = vim.lsp.handlers[method]
  vim.lsp.handlers[method] = function(err, method, result, client_id, bufnr,
                                      config)
    default_handler(err, method, result, client_id, bufnr, config)
    local diagnostics = vim.lsp.diagnostic.get_all()
    local qflist = {}
    for bufnr, diagnostic in pairs(diagnostics) do
      for _, d in ipairs(diagnostic) do
        d.bufnr = bufnr
        d.lnum = d.range.start.line + 1
        d.col = d.range.start.character + 1
        d.text = d.message
        table.insert(qflist, d)
      end
    end
    vim.lsp.util.set_qflist(qflist)
  end
end


--language server protocol
require('lsp')

-- Key mappings
require('keymappings')

-- require('toggleterm')

vim.cmd 'source ~/.config/nvim/oldinit.vim'

