local M = {}

local conf = require('bufterm.config').options

local function calc_len_pos(val, std)
  if val < 1 then
    return math.ceil(std * val), math.ceil(std * (1 - val) / 2)
  else
    return val, math.ceil((std - val) / 2)
  end
end

---open floating window
---@param buffer? number buffer id
---@return number winid
function M.open_float(buffer)
  buffer = buffer or vim.api.nvim_create_buf(false, false)
  local win_opts = {
    relative = 'editor',
    border = 'single',
  }
  win_opts.width, win_opts.col = calc_len_pos(conf.ui.width, vim.o.columns)
  win_opts.height, win_opts.row = calc_len_pos(conf.ui.height, vim.o.lines)
  local winid = vim.api.nvim_open_win(buffer, true, win_opts)
  vim.api.nvim_win_set_option(winid, 'winhighlight', 'Normal:Normal')
  return winid
end

return M
