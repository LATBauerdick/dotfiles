-- Set colorscheme
-- vim.o.termguicolors = true
vim.cmd [[colorscheme solarized]]
vim.cmd [[ let g:solarized_termcolors=16 ]]
vim.cmd [[ set background=light ]]

vim.cmd [[
" fixes glitch? in colors when using vim with tmux
" set termguicolors
" This is only necessary if you use "set termguicolors".
" let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
" let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
]]
