# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a Neovim configuration written in Lua, designed for functional programming (Haskell and PureScript) development. It's part of a larger NixOS/nix-darwin dotfiles repository managed with Nix flakes.

## Configuration Structure

### Entry Point
- `init.lua` - Main entry point that sets leader keys (`<Space>` and `,`), then loads settings, lazy.nvim plugin manager, and keymappings

### Core Configuration Files (in `lua/config/`)
- `settings.lua` - All vim options, autocmds, and editor behavior configuration
- `keymappings.lua` - All custom keybindings (both legacy `map()` function and modern `vim.keymap.set()`)
- `lazy.lua` - Lazy.nvim bootstrap and plugin loading (imports all plugins from `config.plugins`)

### Plugin Configuration (in `lua/config/plugins/`)
Each plugin has its own file that returns a lazy.nvim plugin spec:
- `lsp.lua` - LSP configuration for lua_ls and purescriptls; handles auto-formatting on save
- `haskell.lua` - Haskell-tools.nvim configuration with GHCi REPL, Hoogle integration, and code lens support
- `purescript.lua` - Syntax support only
- `completion.lua` - nvim-cmp with LuaSnip, multiple sources (LSP, buffer, path, emoji)
- `treesitter.lua` - Syntax highlighting for Haskell, PureScript, and other languages
- `telescope.lua` - Fuzzy finder with ivy theme and custom multigrep
- `lualine.lua`, `mini.lua`, `colors.lua`, `markdown.lua`, `obsidian.lua`, `utils.lua` - Other plugin configs

### Filetype-specific Configuration (in `after/ftplugin/`)
- `haskell.lua` - Sets `shiftwidth=2`; keymaps are in haskell-tools on_attach
- `purescript.lua` - Filetype-specific settings
- `lua.lua` - Lua filetype settings

## Key Conventions

### Leader Keys
- `mapleader` = `<Space>`
- `maplocalleader` = `,`

### Plugin Management
- Uses lazy.nvim for plugin management
- Plugins are lazy-loaded where appropriate (e.g., nvim-cmp on InsertEnter, haskell-tools on ft)
- Plugin specs are modular: each plugin in `lua/config/plugins/*.lua` returns a lazy.nvim spec table

### LSP Setup Pattern
- LSP configuration is in `lsp.lua` for general language servers
- Language-specific tooling (like haskell-tools) is in dedicated files
- Auto-formatting on save is configured via LspAttach autocmd in `lsp.lua`
- Completion capabilities are provided by blink.cmp (in lsp.lua) or nvim-cmp (in completion.lua)

### Haskell Development
The Haskell setup uses haskell-tools.nvim, which wraps haskell-language-server (HLS) with additional features:
- `<space>cl` - Run code lens
- `<space>hs` - Hoogle search for signature under cursor
- `<space>ea` - Evaluate all code snippets
- `<leader>rr` - Toggle GHCi REPL for current package
- `<leader>rf` - Toggle GHCi REPL for current buffer
- `<leader>rq` - Quit REPL

### Important Keybindings
- `<leader>f` - Format buffer with LSP
- `<leader>grn` - LSP rename
- `<leader>gra` - LSP code action
- `<leader>grr` - LSP references
- `<leader>e` - Open diagnostic float
- `<leader>fd` - Telescope find files
- `<leader>fh` - Telescope help tags
- `<leader>en` - Find files in Neovim config dir
- `<leader>w` or `<leader>o` - Switch window
- `<leader>bd` - Delete buffer without closing window

## Testing and Building

This is a configuration repository, not a software project. There are no tests or build commands.

To test changes:
1. Edit configuration files in this directory
2. Reload Neovim or source the file with `<leader><leader>x` (source current file) or `<leader>x` (execute current line/selection as Lua)
3. For plugin changes, restart Neovim or run `:Lazy sync`

The configuration is integrated into the larger NixOS/nix-darwin system via `../../../flake.nix`, which includes nixvim and neovim-nightly-overlay inputs.

## Architecture Notes

### Two Completion Systems
The repository contains configurations for both nvim-cmp (active) and blink.cmp (commented out) in `completion.lua`. Currently nvim-cmp is in use.

### Settings Philosophy
- Extensive vim option configuration in `settings.lua` emphasizing comfort and productivity
- Relative line numbers that toggle to absolute in insert mode or on focus loss
- Persistent undo files in `/tmp/.undodir_$USER`
- Auto-save on focus loss, auto-read on focus gain
- Global substitution by default (`gdefault`)
- System clipboard integration

### Telescope Integration
Custom multigrep implementation in `lua/config/telescope/multigrep.lua` extends Telescope's grep functionality.

## Common Pitfalls

1. **Keybinding conflicts**: This config has many custom keybindings. When adding new mappings, check `keymappings.lua` and plugin on_attach functions for conflicts.

2. **Leader key timing**: Changes to leader keys must happen before lazy.nvim loads, which is why they're set in `init.lua` before requiring anything else.

3. **LSP formatting**: Auto-format on save is configured globally in the LspAttach autocmd. Individual language servers may need `supports_method('textDocument/formatting')` check.

4. **Haskell keymaps**: Haskell-specific keymaps are defined in the haskell-tools on_attach callback, not in the general keymappings file or ftplugin.
