local M = {}

local conf = require('bufterm.config').options

local function calc_len_pos(val, std)
  if val < 1 then
    return math.ceil(std * val), math.ceil(std * (1 - val) / 2)
  else
    return val, math.ceil((std - val) / 2)
  end
end

local float_winid

---open floating window
---@param buffer? number buffer id
---@return number winid
function M.open_float(buffer)
  buffer = buffer or vim.api.nvim_create_buf(false, false)
  if float_winid and vim.api.nvim_win_is_valid(float_winid) then
    vim.api.nvim_win_set_buf(float_winid, buffer)
  else
    local win_opts = {
      relative = 'editor',
      border = 'single',
    }
    win_opts.width, win_opts.col = calc_len_pos(conf.ui.width, vim.o.columns)
    win_opts.height, win_opts.row = calc_len_pos(conf.ui.height, vim.o.lines)
    float_winid = vim.api.nvim_open_win(buffer, true, win_opts)
    vim.api.nvim_win_set_option(float_winid, 'winhighlight', 'Normal:Normal')
  end
  return float_winid
end

function M.close_float()
  if float_winid and vim.api.nvim_win_is_valid(float_winid) then
    vim.api.nvim_win_close(float_winid, false)
  end
end

---toggle floating window
---@param buffer? number buffer id
---@return number|nil winid
function M.toggle_float(buffer)
  if float_winid and vim.api.nvim_win_is_valid(float_winid) then
    M.close_float()
    return nil
  else
    return M.open_float(buffer)
  end
end

return M
