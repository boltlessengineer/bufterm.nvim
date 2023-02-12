local bufterm = require('bufterm')

bufterm.setup({
  debug = false,
  terminal = {
    buflisted = false,
  }
})

local Terminal = require('bufterm.terminal').Terminal
local ui       = require('bufterm.ui')

local lazygit = Terminal:new({
  cmd = 'lazygit',
  fallback_on_exit = false,
  termlisted = false,
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
local runner = Terminal:new({
  cmd = function()
    local runner = {
      python = 'python3 %',
      go = 'go run %',
      sh = 'sh %',
      fish = 'fish %',
    }
    local cmd = runner[vim.bo.filetype]
    if not cmd then
      return vim.o.shell
    end
    cmd = cmd:gsub('%%', vim.fn.expand('%'))
    return cmd
  end,
  termlisted = true,
  auto_close = false,
})
local runner_win = ui.Window:new()
vim.keymap.set('n', '<leader>r', function()
  -- re-run process if buffer is visible
  if runner.bufnr and vim.fn.bufwinid(runner.bufnr) > 0 then
    runner:run()
    return
  end
  -- open new window (or get existing window-id)
  local winid = runner_win:open(runner.bufnr)
  -- enter job
  runner:enter(winid)
end)
