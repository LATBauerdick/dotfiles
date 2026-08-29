return {
  {
    "nvim-treesitter/nvim-treesitter",
    -- Pin to master. The `main` branch is the v2 rewrite, which drops the
    -- `nvim-treesitter.configs` module used below and configures parsers
    -- differently. Without this pin a fresh install resolves to main and
    -- errors on startup.
    branch = "master",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = {
          'haskell', 'purescript', 'markdown', 'markdown_inline', 'c',
          'lua', 'vim', 'vimdoc', 'query', 'elixir', 'heex', 'javascript', 'html',
        },
        sync_install = false,
        highlight = { enable = true },
        indent = { enable = true },
      })
    end
  }
}
