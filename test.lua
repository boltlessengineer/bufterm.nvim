local bufterm = require('bufterm')

bufterm.setup({
  use_fallback_buffer = false,
})

local Terminal = require('bufterm.terminal').Terminal

local lazygit = Terminal:new({
  cmd = 'lazygit',
})

vim.keymap.set('n', [[\\]], '<cmd>BufTermEnter<CR>')
vim.keymap.set({ 'n', 't' }, [[<C-f>]], '<cmd>BufTermFloat<CR>')
vim.keymap.set('n', '<space>g', function()
  lazygit:open()
end)
vim.keymap.set('t', '<C-o>', '<cmd>BufTermPrev<CR>')
vim.keymap.set('t', '<C-i>', '<cmd>BufTermNext<CR>')
