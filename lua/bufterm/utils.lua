local M = {}

local conf = require('bufterm.config').options

local log_file_path = './bufterm.log'

function M.log(msg)
  if not conf.debug then return end
  local log_file = io.open(log_file_path, 'a')
  if not log_file then
    return
  end
  io.output(log_file)
  io.write(msg .. '\n')
  io.close(log_file)
end

if conf.debug then
  local tmp_group = vim.api.nvim_create_augroup('TmpTerminal', { clear = true })
  vim.api.nvim_create_autocmd({
    "TermOpen",
    "TermClose",
    "TermEnter",
    "TermLeave",
    "BufEnter",
    "BufLeave",
    "BufDelete",
  }, {
    group = tmp_group,
    pattern = "term://*",
    callback = vim.schedule_wrap(function(args)
      local new_buf = vim.api.nvim_get_current_buf()
      M.log(string.format('%-11s (%d) -> %d', args.event, args.buf, new_buf))
      vim.cmd.checktime()
    end)
  })
  vim.api.nvim_create_autocmd('ModeChanged', {
    group = tmp_group,
    pattern = "c:ntT",
    callback = vim.schedule_wrap(function(args)
      local new_buf = vim.api.nvim_get_current_buf()
      M.log(string.format('%-11s (%d) -> %d', args.event, args.buf, new_buf))
      vim.cmd.checktime()
    end)
  })
end

return M
