local M = {}

---@class BufTermConfig
---@field debug boolean
---@field list_buffers boolean
---@field save_native_terms boolean
---@field fallback_on_exit boolean
---@field start_in_insert boolean
---@field remember_mode boolean
---@field enable_ctrl_w boolean
M.options = {
  debug = false,
  list_buffers = true,
  save_native_terms = true,
  fallback_on_exit = true,
  start_in_insert = true,
  remember_mode = true,
  enable_ctrl_w = true,
}

M.augroup = vim.api.nvim_create_augroup('BufTerm', {})

---setup bufterm plugin config
---@param opts BufTermConfig
function M.set(opts)
  M.options = vim.tbl_deep_extend('force', M.options, opts)
end

return M
