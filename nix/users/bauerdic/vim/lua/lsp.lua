
-- HIE / LanguageClient-neovim setup
-- Required for operations modifying multiple buffers like rename.
-- vim.cmd [[
-- let g:LanguageClient_serverCommands = {
--     \ 'rust': ['~/.cargo/bin/rustup', 'run', 'stable', 'rls'],
--     \ 'javascript': ['/usr/local/bin/javascript-typescript-stdio'],
--     \ 'javascript.jsx': ['tcp://127.0.0.1:2089'],
--     \ 'python': ['/usr/local/bin/pyls'],
--     \ 'ruby': ['~/.rbenv/shims/solargraph', 'stdio'],
--     \ }
-- ]]

-- set rtp+=~/.vim/bundle/LanguageClient-neovim

vim.cmd [[
nnoremap <F5> :call LanguageClient_contextMenu()<CR>
map <Leader>lk :call LanguageClient#textDocument_hover()<CR>
map <Leader>lg :call LanguageClient#textDocument_definition()<CR>
map <Leader>lr :call LanguageClient#textDocument_rename()<CR>
map <Leader>lf :call LanguageClient#textDocument_formatting()<CR>
map <Leader>lb :call LanguageClient#textDocument_references()<CR>
map <Leader>la :call LanguageClient#textDocument_codeAction()<CR>
map <Leader>ls :call LanguageClient#textDocument_documentSymbol()<CR>
]]

-- setup language server
vim.cmd [[
source ~/.config/nvim/lsp-config.vim
]]
-- require('lsp-config')
-- set completeopt=menuone,noselect
-- require('compe-config')

-- require('python-lsp')

require'lspconfig'.pyright.setup{}

require('haskell-lsp')

vim.cmd [[
let g:LanguageClient_serverCommands = {
    \ 'nix': ['rnix-lsp']
\ }
]]

