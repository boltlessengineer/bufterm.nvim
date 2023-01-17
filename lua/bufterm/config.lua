local M = {}

---@class BufTermConfig
---@class list_buffers boolean
M.options = {
  list_buffers = true,
}

---setup bufterm plugin config
---@param opts BufTermConfig
function M.set(opts)
  M.options = vim.tbl_deep_extend('force', M.options, opts)
end

return M
