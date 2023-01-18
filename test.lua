local bufterm = require('bufterm')
local Terminal = require('bufterm.terminal').Terminal

bufterm.setup({
})

local lazygit = Terminal:new({
  id = 9,
  cmd = 'lazygit',
  on_exit = function (_)
    vim.api.nvim_buf_delete(0, { force = true })
  end
})

vim.keymap.set('n', [[\\]], '<cmd>BufTermEnter<CR>')
vim.keymap.set({ 'n', 't' }, [[<C-\>]], '<cmd>BufTermToggle<CR>')
vim.keymap.set('n', '<space>g', function ()
  lazygit:open()
end)
