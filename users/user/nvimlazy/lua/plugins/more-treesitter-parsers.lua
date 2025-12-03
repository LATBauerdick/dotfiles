-- add more treesitter parsers
return {
  "nvim-treesitter/nvim-treesitter",
  opts = {
    ensure_installed = {
      "bash",
      "haskell",
      "html",
      "javascript",
      "json",
      "lua",
      "markdown",
      "markdown_inline",
      "purescript",
      "python",
      "query",
      "regex",
      "tsx",
      "typescript",
      "vim",
      "yaml",
    },
  },
}
