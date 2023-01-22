local M = {}

local float_winid

---toggle floating window
---@param buffer? number buffer id
---@return number|nil winid
function M.toggle_float(buffer)
  buffer = buffer or 0
  if float_winid and vim.api.nvim_win_is_valid(float_winid) then
    local cur_buf = vim.api.nvim_win_get_buf(float_winid)
    if cur_buf == buffer then
      vim.api.nvim_win_close(float_winid, false)
    else
      vim.api.nvim_win_set_buf(float_winid, buffer)
    end
  else
    local function size(max, val)
      return val > 1 and math.min(val, max) or math.floor(max * val)
    end
    local win_opts = {
      relative = 'editor',
      border = 'single',
      width = size(vim.o.columns, 0.8),
      height = size(vim.o.lines, 0.8),
    }
    win_opts.row = math.floor((vim.o.lines - win_opts.height) / 2)
    win_opts.col = math.floor((vim.o.columns - win_opts.width) / 2)
    float_winid = vim.api.nvim_open_win(buffer, true, win_opts)
    vim.wo[float_winid].winhighlight = 'Normal:Normal'
  end
  return float_winid
end

return M
