local bufterm = require('bufterm')
local Terminal = require('bufterm.terminal').Terminal

bufterm.setup({
  use_fallback_buffer = false,
})

local lazygit = Terminal:new({
  id = 9,
  cmd = 'lazygit',
})

vim.keymap.set('n', [[\\]], '<cmd>BufTermEnter<CR>')
vim.keymap.set({ 'n', 't' }, [[<C-\>]], '<cmd>BufTermFloat<CR>')
vim.keymap.set('n', '<space>g', function()
  lazygit:open()
end)
vim.keymap.set('t', '<C-o>', '<cmd>BufTermPrev<CR>')
vim.keymap.set('t', '<C-i>', '<cmd>BufTermNext<CR>')
vim.keymap.set('t', [[<C-[>]], [[<Plug>(term-pre-normal-mode)<C-\><C-n>]])
