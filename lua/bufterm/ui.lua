local M = {}

local function calc_len_pos(val, std)
  if val < 1 then
    return math.ceil(std * val), math.ceil(std * (1 - val) / 2)
  else
    return val, math.ceil((std - val) / 2)
  end
end

---open floating window
---@param bufnr number|nil buffer id
---@return number winid
---@return number bufnr
function M.open_float(bufnr)
  bufnr = bufnr or vim.api.nvim_create_buf(false, false)
  local width = 0.9
  local height = 0.9
  local win_opts = {
    relative = 'editor',
    border = 'single',
  }
  win_opts.width, win_opts.col = calc_len_pos(width, vim.o.columns)
  win_opts.height, win_opts.row = calc_len_pos(height, vim.o.lines)
  local winid = vim.api.nvim_open_win(bufnr, true, win_opts)
  vim.api.nvim_win_set_option(winid, 'winhighlight', 'Normal:Normal')
  return winid, bufnr
end

return M
