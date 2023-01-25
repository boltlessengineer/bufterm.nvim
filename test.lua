local bufterm = require('bufterm')

bufterm.setup({
  debug = true,
  use_fallback_buffer = false,
})

local Terminal = require('bufterm.terminal').Terminal
local ui       = require('bufterm.ui')

local lazygit = Terminal:new({
  cmd = 'lazygit',
  fallback_on_exit = false,
  list = false,
})

vim.keymap.set('t', '<C-o>', '<cmd>BufTermPrev<CR>')
vim.keymap.set('t', '<C-i>', '<cmd>BufTermNext<CR>')
vim.keymap.set('t', '<tab>', '<tab>')
vim.keymap.set('n', [[\\]], '<cmd>BufTermEnter<CR>')
vim.keymap.set('n', '<space>g', function()
  lazygit:spawn()
  ui.toggle_float(lazygit.bufnr)
end)
vim.keymap.set({ 'n', 't' }, [[<C-t>]], function ()
  local term = require('bufterm.terminal').get_recent_term()
  if not term then
    term = Terminal:new()
    term:spawn()
  end
  ui.toggle_float(term.bufnr)
end)
