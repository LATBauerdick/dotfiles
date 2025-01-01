return { -- use nvim-cmp
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-buffer", -- source for text in buffer
      "hrsh7th/cmp-path",   -- source for file system paths
      "hrsh7th/cmp-emoji",
      {
        "L3MON4D3/LuaSnip",
        version = "v2.*",
        -- install jsregexp (optional!).
        build = "make install_jsregexp",
      },
      "rafamadriz/friendly-snippets",
      "onsails/lspkind.nvim", -- vs-code like pictograms
    },
    config = function()
      local cmp = require("cmp")
      local lspkind = require("lspkind")
      local luasnip = require("luasnip")
      local has_words_before = function()
        unpack = unpack or table.unpack
        local line, col = unpack(vim.api.nvim_win_get_cursor(0))
        return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
      end

      require("luasnip.loaders.from_vscode").lazy_load()

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },

        -- Supertab
        -- Use <tab> for completion and snippets (supertab).

        mapping = cmp.mapping.preset.insert({
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              -- You could replace select_next_item() with confirm({ select = true }) to get VS Code autocompletion behavior
              cmp.select_next_item()
            elseif vim.snippet.active({ direction = 1 }) then
              vim.schedule(function()
                vim.snippet.jump(1)
              end)
            elseif has_words_before() then
              cmp.complete()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif vim.snippet.active({ direction = -1 }) then
              vim.schedule(function()
                vim.snippet.jump(-1)
              end)
            else
              fallback()
            end
          end, { "i", "s" }),
        }),

        -- mapping = cmp.mapping.preset.insert({
        --   ["<C-d>"] = cmp.mapping.scroll_docs(-4),
        --   ["<C-f>"] = cmp.mapping.scroll_docs(4),
        --   ["<C-Space>"] = cmp.mapping.complete(),
        --   ["<C-e>"] = cmp.mapping.close(),
        --   ["<CR>"] = cmp.mapping.confirm({
        --     behavior = cmp.ConfirmBehavior.Replace,
        --     select = true,
        --   }),
        -- }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "buffer" },
          { name = "path" },
          { name = "emoji" },
        }),
      })

      vim.cmd([[
        set completeopt=menuone,noinsert,noselect
        highlight! default link CmpItemKind CmpItemMenuDefault
      ]])
    end,
  },
}

-- return { -- use blink-cmp
--   {
--     'saghen/blink.cmp',
--     dependencies = 'rafamadriz/friendly-snippets',
--     version = '*',
--     --   --   build = 'nix run .#build-plugin',
--     ---@module 'blink.cmp'
--     ---@type blink.cmp.Config
--     opts = {
--       keymap = { preset = 'super-tab' },
--       -- keymap = { preset = 'enter' },
--       appearance = {
--         nerd_font_variant = 'mono'
--       },
--       sources = {
--         default = { 'lsp', 'path', 'snippets', 'buffer' },
--       },
--     },
--     -- opts_extend = { "sources.default" },
--     completion = {
--       keyword = { range = 'prefix' },
--       documentation = { auto_show = true, auto_show_delay_ms = 500 },
--       ghost_text = { enabled = false },
--     },
--   },
-- }
